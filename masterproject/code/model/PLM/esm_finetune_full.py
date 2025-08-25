from transformers import (
    EsmForSequenceClassification,
    EsmTokenizer,
    TrainingArguments,
    Trainer,
    TrainerCallback,
    EarlyStoppingCallback,
    get_cosine_schedule_with_warmup
)
from datasets import Dataset
import torch
import numpy as np
from sklearn.metrics import r2_score, mean_squared_error
import json
import matplotlib.pyplot as plt
import random
from collections import defaultdict
import torch.nn as nn
import os
from torch.nn import HuberLoss

# Custom callback to monitor GPU memory usage
class GPUUsageCallback(TrainerCallback):
    def on_step_end(self, args, state, control, **kwargs):
        if torch.cuda.is_available() and state.global_step % 10 == 0:
            mem_allocated = torch.cuda.memory_allocated(0) / 1024**2
            mem_reserved = torch.cuda.memory_reserved(0) / 1024**2
            print(f"[Step {state.global_step}] GPU Memory Allocated: {mem_allocated:.2f} MB | Reserved: {mem_reserved:.2f} MB")

# Custom Huber loss
class HuberLoss(nn.Module):
    def __init__(self, delta=1.0):
        super().__init__()
        self.delta = delta

    def forward(self, input, target):
        error = input - target
        is_small_error = torch.abs(error) <= self.delta
        squared_loss = 0.5 * error**2
        linear_loss = self.delta * (torch.abs(error) - 0.5 * self.delta)
        return torch.where(is_small_error, squared_loss, linear_loss).mean()

# Load dataset
with open("train_data_final.json", "r") as f:
    all_data = json.load(f)

# Group by strain_id and split into train/validation/test sets 
strain_to_samples = defaultdict(list)
for sample in all_data:
    sample["label"] = float(np.log(sample["label"]))  # 做 log 转换
    strain_to_samples[sample["strain_id"]].append(sample)

strain_ids = list(strain_to_samples.keys())
random.seed(42)
random.shuffle(strain_ids)

n_total = len(strain_ids)
train_end = int(n_total * 0.7)
val_end = int(n_total * 0.85)

train_strains = set(strain_ids[:train_end])
val_strains = set(strain_ids[train_end:val_end])
test_strains = set(strain_ids[val_end:])

train_examples, val_examples, test_examples = [], [], []
for strain_id, samples in strain_to_samples.items():
    if strain_id in train_strains:
        train_examples.extend(samples)
    elif strain_id in val_strains:
        val_examples.extend(samples)
    else:
        test_examples.extend(samples)

train_dataset = Dataset.from_list(train_examples)
val_dataset = Dataset.from_list(val_examples)
test_dataset = Dataset.from_list(test_examples)

# load model and tokenizer


tokenizer = EsmTokenizer.from_pretrained("facebook/esm2_t30_150M_UR50D")
model = EsmForSequenceClassification.from_pretrained(
    "facebook/esm2_t30_150M_UR50D",
    num_labels=1,
    problem_type="regression"
)


# Tokenization function
def tokenize_function(example):
    tokens = tokenizer(
        example["sequence"],
        truncation=True,
        padding="max_length",
        max_length=1024,
    )
    tokens["labels"] = example["label"]
    return tokens

tokenized_train = train_dataset.map(tokenize_function, batched=False)
tokenized_eval = val_dataset.map(tokenize_function, batched=False)
tokenized_test = test_dataset.map(tokenize_function, batched=False)

# Training arguments
training_args = TrainingArguments(
    output_dir="./esm_regression_results",
    evaluation_strategy="epoch",
    per_device_train_batch_size=32,
    auto_find_batch_size=True,
    num_train_epochs=6,
    save_strategy="epoch",
    resume_from_checkpoint=True,
    logging_dir="./logs",
    logging_steps=10,
    fp16=True,
    report_to="none",
    load_best_model_at_end=True,
    metric_for_best_model="r2",
    warmup_ratio=0.1,
    weight_decay=0.01,
    greater_is_better=True,
    lr_scheduler_type="cosine"
)

# evaluation matrix
def compute_metrics(preds):
    y_true_log = preds.label_ids
    y_pred_log = preds.predictions.squeeze()

    # 还原回真实温度
    y_true = np.exp(y_true_log)
    y_pred = np.exp(y_pred_log)

    return {
        "r2": r2_score(y_true, y_pred),
        "mse": mean_squared_error(y_true, y_pred),
        "mae": np.mean(np.abs(y_true - y_pred))
    }



# Initialize Trainer
class CustomTrainer(Trainer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.loss_fct = HuberLoss()  

    def compute_loss(self, model, inputs, return_outputs=False):
        labels = inputs.pop("labels")
        outputs = model(**inputs)
        logits = outputs.logits.squeeze()
        
        loss = self.loss_fct(logits, labels)  
        return (loss, outputs) if return_outputs else loss

trainer = CustomTrainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_eval,
    compute_metrics=compute_metrics,
    callbacks=[GPUUsageCallback(), EarlyStoppingCallback(early_stopping_patience=2)]
)



# Train the model
trainer.train()

# Evaluate on train set
train_metrics = trainer.evaluate(eval_dataset=tokenized_train)
print("Training results:")
print(train_metrics)

# Evaluate on validation set
val_metrics = trainer.evaluate()
print("Validation results:")
print(val_metrics)

# Evaluate on test set
test_metrics = trainer.evaluate(eval_dataset=tokenized_test)
print("Test results:")
print(test_metrics)

# Save model and tokenizer
trainer.save_model("esm_finetuned_model")
tokenizer.save_pretrained("esm_finetuned_model")

# Initialize containers
train_losses_by_epoch = []
val_losses_by_epoch = []
train_losses_by_step = []
steps_by_step = []

# Extract loss records
for log in trainer.state.log_history:
    if "loss" in log and "step" in log and "epoch" in log:
        train_losses_by_step.append(log["loss"])
        steps_by_step.append(log["step"])
    if "loss" in log and "epoch" in log and "step" not in log:
        train_losses_by_epoch.append((log["epoch"], log["loss"]))
    if "eval_loss" in log and "epoch" in log:
        val_losses_by_epoch.append((log["epoch"], log["eval_loss"]))

# plot
plt.figure(figsize=(10, 6))
if train_losses_by_epoch and val_losses_by_epoch:
    epochs_train, train_vals = zip(*train_losses_by_epoch)
    epochs_val, val_vals = zip(*val_losses_by_epoch)
    plt.plot(epochs_train, train_vals, label="Train Loss", marker='o', linestyle='-')
    plt.plot(epochs_val, val_vals, label="Validation Loss", marker='s', linestyle='--')
    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.title("Training & Validation Loss by Epoch")
    plt.legend()
    plt.grid(True)
    plt.savefig("loss_epoch_combined_curve.png")
    print("Combined epoch-based loss curve saved as 'loss_epoch_combined_curve.png'")
else:
    print("No sufficient loss records to plot combined curve.")

# plot- training loss by step
plt.figure(figsize=(10, 6))
if train_losses_by_step:
    plt.plot(steps_by_step, train_losses_by_step, label="Train Loss (Step)", color="green")
    plt.xlabel("Step")
    plt.ylabel("Loss")
    plt.title("Training Loss by Step")
    plt.grid(True)
    plt.legend()
    plt.savefig("loss_step_curve.png")
    print("Step-based training loss curve saved as 'loss_step_curve.png'")
else:
    print("No step-level training loss found.")
