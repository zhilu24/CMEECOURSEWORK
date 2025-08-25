import json
import torch
import numpy as np
from transformers import EsmForSequenceClassification, EsmTokenizer
from sklearn.metrics import r2_score, mean_squared_error
import matplotlib.pyplot as plt
from collections import defaultdict
from tqdm import tqdm
import random
from datasets import Dataset
from peft import AutoPeftModelForSequenceClassification
from peft import PeftModel

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# model and tokenizer paths
MODEL_DIR = "esm_finetuned_lora" 
BASE = "facebook/esm2_t30_150M_UR50D" 

tokenizer = EsmTokenizer.from_pretrained(BASE)
base_model = EsmForSequenceClassification.from_pretrained(
    BASE,
    num_labels=1,                    
    problem_type="regression",       
)
model = PeftModel.from_pretrained(base_model, MODEL_DIR)
model.eval().to(device)

# Load dataset
with open("train_data_final.json", "r") as f:
    all_data = json.load(f)

# Group by strain_id and split into train/validation/test sets
strain_to_samples = defaultdict(list)
for sample in all_data:
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

# Prediction function
def predict_strain_level(dataset, title="Train"):
    strain_preds = defaultdict(list)
    strain_labels = {}

    for sample in tqdm(dataset, desc=f"Predicting {title} set"):
        sequence = sample["sequence"]
        label = sample["label"]
        strain_id = sample["strain_id"]

        inputs = tokenizer(sequence, padding="max_length", truncation=True, max_length=1024, return_tensors="pt")
        inputs = {k: v.to(device) for k, v in inputs.items()}

        with torch.no_grad():
            outputs = model(**inputs)
        pred_log = outputs.logits.squeeze().item()

        pred = np.exp(pred_log)
        true = np.exp(label)
        
        strain_preds[strain_id].append(pred)
        strain_labels[strain_id] = label

    y_true, y_pred = [], []
    for strain_id, preds in strain_preds.items():
        mean_pred = float(np.mean(preds))
        true_label = strain_labels[strain_id]
        y_true.append(true_label)
        y_pred.append(mean_pred)

    r2 = r2_score(y_true, y_pred)
    mse = mean_squared_error(y_true, y_pred)
    rmse = np.sqrt(mse)

    print(f"\n📊 {title} Species-level Evaluation:")
    print(f"R² Score: {r2:.4f}")
    print(f"RMSE: {rmse:.2f}")

    # Plot with RMSE and R² text
    plt.figure(figsize=(6.5, 6.5))
    plt.scatter(y_true, y_pred, alpha=0.6, color="dodgerblue", edgecolor="k", linewidth=0.3)
    plt.plot([min(y_true), max(y_true)], [min(y_true), max(y_true)], 'r--', linewidth=1)

    plt.xlabel("Measured OGT (°C)")
    plt.ylabel("Predicted OGT (°C)")
    plt.title(f"{title} dataset")

    # Add text box with RMSE and R²
    plt.text(min(y_true) + 2, max(y_true) - 10,
             f"RMSE = {rmse:.2f}\nR² = {r2:.3f}",
             fontsize=12, fontweight='bold',
             bbox=dict(facecolor='white', edgecolor='gray', boxstyle='round,pad=0.5'))

    plt.grid(True, linestyle="--", alpha=0.5)
    plt.tight_layout()
    plt.savefig(f"{title.lower()}_species_level_ogt_scatter.png", dpi=300)
    plt.show()

    return r2, rmse

# Run predictions
r2_val, rmse_val = predict_strain_level(val_dataset, title="Validation")
r2_test, rmse_test = predict_strain_level(test_dataset, title="Test")

# Final summary
print("\n===== Summary =====")
print(f"Validation R²: {r2_val:.4f} | RMSE: {rmse_val:.2f}")
print(f"Test R²:       {r2_test:.4f} | RMSE: {rmse_test:.2f}")