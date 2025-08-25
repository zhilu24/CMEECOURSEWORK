from transformers import (
    EsmForSequenceClassification,
    EsmTokenizer,
    TrainingArguments,
    Trainer,
    TrainerCallback,
    EarlyStoppingCallback,
)
from datasets import Dataset
from peft import LoraConfig, get_peft_model, TaskType
import torch
import numpy as np
from sklearn.metrics import r2_score, mean_squared_error
import json
import matplotlib.pyplot as plt
import random
from collections import defaultdict
import torch.nn as nn
import os

# GPU memory monitor
class GPUUsageCallback(TrainerCallback):
    def on_step_end(self, args, state, control, **kwargs):
        if torch.cuda.is_available() and state.global_step % 10 == 0:
            mem_allocated = torch.cuda.memory_allocated(0) / 1024**2
            mem_reserved = torch.cuda.memory_reserved(0) / 1024**2
            print(f"[Step {state.global_step}] GPU Allocated: {mem_allocated:.2f} MB | Reserved: {mem_reserved:.2f} MB")

# Huber Loss
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

# Load data & split by strain with 70:15:15
with open("train_data_final.json", "r") as f:
    all_data = json.load(f)

strain_to_samples = defaultdict(list)
for sample in all_data:
    sample["label"] = float(np.log(sample["label"]))  # log transform
    strain_to_samples[sample["strain_id"]].append(sample)

strain_ids = list(strain_to_samples.keys())
random.seed(42)
random.shuffle(strain_ids)

n_total = len(strain_ids)
train_end = int(n_total * 0.70)
val_end = int(n_total * 0.85)  # 70% train, 15% validation, 15% test

train_strains = set(strain_ids[:train_end])
val_strains = set(strain_ids[train_end:val_end])
test_strains = set(strain_ids[val_end:])

train_examples, val_examples, test_examples = [], [], []
for sid, samples in strain_to_samples.items():
    if sid in train_strains:
        train_examples.extend(samples)
    elif sid in val_strains:
        val_examples.extend(samples)
    else:
        test_examples.extend(samples)

train_dataset = Dataset.from_list(train_examples)
val_dataset = Dataset.from_list(val_examples)
test_dataset = Dataset.from_list(test_examples)

# Load tokenizer and model
tokenizer = EsmTokenizer.from_pretrained("facebook/esm2_t30_150M_UR50D")
base_model = EsmForSequenceClassification.from_pretrained(
    "facebook/esm2_t30_150M_UR50D",
    num_labels=1,
    problem_type="regression"
)

# Apply LoRA adapter (PEFT)
# ESM attention linear layer names are typically "query", "key", "value"
lora_config = LoraConfig(
    task_type=TaskType.SEQ_CLS,
    r=16,
    lora_alpha=32,
    lora_dropout=0.1,
    bias="none",
    target_modules=["query", "key", "value"]
)
model = get_peft_model(base_model, lora_config)
model.print_trainable_parameters()  # verify only LoRA parameters are trainable

# Tokenization
def tokenize_function(example):
    tokens = tokenizer(
        example["sequence"],
        truncation=True,
        padding="max_length",
        max_length=1024,
    )
    tokens["labels"] = float(example["label"])
    return tokens

tokenized_train = train_dataset.map(tokenize_function, batched=False)
tokenized_eval = val_dataset.map(tokenize_function, batched=False)
tokenized_test = test_dataset.map(tokenize_function, batched=False)

# Metrics
def compute_metrics(preds):
    y_true_log = preds.label_ids
    y_pred_log = preds.predictions.squeeze()

    # invert back to real temperature
    y_true = np.exp(y_true_log)
    y_pred = np.exp(y_pred_log)

    return {
        "r2": r2_score(y_true, y_pred),
        "mse": mean_squared_error(y_true, y_pred),
        "mae": np.mean(np.abs(y_true - y_pred))
    }

# Training arguments (PEFT-friendly)
training_args = TrainingArguments(
    output_dir="./esm_regression_results_lora",
    evaluation_strategy="epoch",
    save_strategy="epoch",
    save_total_limit=2,
    per_device_train_batch_size=32,
    auto_find_batch_size=True,
    num_train_epochs=6,
    logging_dir="./logs",
    logging_steps=10,
    fp16=True,
    report_to="none",
    load_best_model_at_end=True,
    metric_for_best_model="r2",
    greater_is_better=True,
    warmup_ratio=0.1,
    weight_decay=0.01,
    lr_scheduler_type="cosine",
    learning_rate=2e-4,
)

# Custom Trainer (HuberLoss)
class CustomTrainer(Trainer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.loss_fct = HuberLoss(delta=1.0)

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

# Train & evaluate
trainer.train()

# Training set
train_metrics = trainer.evaluate(eval_dataset=tokenized_train)
print("Training results:")
print(train_metrics)

# Validation set
val_metrics = trainer.evaluate()
print("Validation results:")
print(val_metrics)

# Test set
test_metrics = trainer.evaluate(eval_dataset=tokenized_test)
print("Test results:")
print(test_metrics)

# Save model
# trainer.save_model saves the base model + PEFT wrapper (including adapter config)
trainer.save_model("esm_finetuned_lora")
tokenizer.save_pretrained("esm_finetuned_lora")

# Log aggregation and plotting
train_losses_by_epoch = []
val_losses_by_epoch = []
train_losses_by_step = []
steps_by_step = []

for log in trainer.state.log_history:
    if "loss" in log and "step" in log and "epoch" in log:
        train_losses_by_step.append(log["loss"])
        steps_by_step.append(log["step"])
    if "loss" in log and "epoch" in log and "step" not in log:
        train_losses_by_epoch.append((log["epoch"], log["loss"]))
    if "eval_loss" in log and "epoch" in log:
        val_losses_by_epoch.append((log["epoch"], log["eval_loss"]))

# Plot by epoch
plt.figure(figsize=(10, 6))
if train_losses_by_epoch and val_losses_by_epoch:
    epochs_train, train_vals = zip(*train_losses_by_epoch)
    epochs_val, val_vals = zip(*val_losses_by_epoch)
    plt.plot(epochs_train, train_vals, label="Train Loss", marker='o', linestyle='-')
    plt.plot(epochs_val, val_vals, label="Validation Loss", marker='s', linestyle='--')
    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.title("Training & Validation Loss by Epoch (LoRA)")
    plt.legend()
    plt.grid(True)
    plt.savefig("loss_epoch_combined_curve.png")
    print("Combined epoch-based loss curve saved as 'loss_epoch_combined_curve.png'")
else:
    print("No sufficient loss records to plot combined curve.")

# Plot by step
plt.figure(figsize=(10, 6))
if train_losses_by_step:
    plt.plot(steps_by_step, train_losses_by_step, label="Train Loss (Step)")
    plt.xlabel("Step")
    plt.ylabel("Loss")
    plt.title("Training Loss by Step (LoRA)")
    plt.grid(True)
    plt.legend()
    plt.savefig("loss_step_curve.png")
    print("Step-based training loss curve saved as 'loss_step_curve.png'")
else:
    print("No step-level training loss found.")
