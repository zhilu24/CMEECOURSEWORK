import os
import json
import random
from collections import defaultdict

import numpy as np
import torch
from tqdm import tqdm
from transformers import EsmTokenizer, EsmForSequenceClassification
from peft import PeftModel  # pip install peft

# CONFIG
BASE_MODEL_NAME = "facebook/esm2_t30_150M_UR50D"  
LORA_PATH = "./lora_finetuned_model"

INPUT_JSON = "train_data_final.json"
OUT_TRAIN_JSON = "cls_embeddings_train.json"
OUT_TEST_JSON  = "cls_embeddings_test.json"

BATCH_SIZE = 32
MAX_LEN = 1024
SEED = 42

# UTILS
def set_seed(seed: int = 42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)

def load_lora_model_and_tokenizer(base_model_name: str, lora_path: str):
    """
    1) Load the base ESM model
    2) Inject LoRA weights
    Tokenizer: prefer the one under lora_path if present; otherwise use the base tokenizer.
    """
    has_tok_files = any(
        os.path.exists(os.path.join(lora_path, f))
        for f in ["tokenizer.json", "vocab.txt", "tokenizer_config.json"]
    )
    if has_tok_files:
        tokenizer = EsmTokenizer.from_pretrained(lora_path)
    else:
        tokenizer = EsmTokenizer.from_pretrained(base_model_name)

    base_model = EsmForSequenceClassification.from_pretrained(
        base_model_name,
        num_labels=1,
        problem_type="regression",
    )

    model = PeftModel.from_pretrained(base_model, lora_path)

    model.eval()
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    return tokenizer, model, device

def extract_cls_embeddings(examples, tokenizer, model, device,
                           batch_size=64, max_length=1024, desc="Embedding"):
    """
    Extract the last-layer [CLS] vector from the LoRA-augmented model.
    """
    results = []
    for i in tqdm(range(0, len(examples), batch_size), desc=desc):
        batch = examples[i:i+batch_size]
        sequences  = [s["sequence"] for s in batch]
        strain_ids = [str(s["strain_id"]) for s in batch]
        labels     = [s.get("label", None) for s in batch]

        inputs = tokenizer(
            sequences,
            return_tensors="pt",
            padding="longest",
            truncation=True,
            max_length=max_length
        ).to(device)

        with torch.no_grad():
            # Key: run the PEFT model forward and request hidden states
            outputs = model(**inputs, output_hidden_states=True)
            # Take the [CLS] token (position 0) from the last hidden layer
            cls_batch = outputs.hidden_states[-1][:, 0, :].cpu().numpy()

        for sid, y, cls_vec in zip(strain_ids, labels, cls_batch):
            results.append({
                "strain_id": sid,
                "label": y,
                "cls_embedding": cls_vec.tolist()
            })
    return results

# MAIN
def main():
    set_seed(SEED)

    tokenizer, model, device = load_lora_model_and_tokenizer(BASE_MODEL_NAME, LORA_PATH)

    # Read data and split by strain (apply log transform to labels first)
    with open(INPUT_JSON, "r") as f:
        all_data = json.load(f)

    strain_to_samples = defaultdict(list)
    for sample in all_data:
        s = dict(sample)
        s["label"] = float(np.log(s["label"]))  # change back to raw value if you do not want log
        strain_to_samples[str(s["strain_id"])].append(s)

    strain_ids = list(strain_to_samples.keys())
    random.shuffle(strain_ids)

    n_total   = len(strain_ids)
    train_end = int(n_total * 0.70)
    val_end   = int(n_total * 0.85)

    train_strains = set(strain_ids[:train_end])
    val_strains   = set(strain_ids[train_end:val_end])
    test_strains  = set(strain_ids[val_end:])

    train_all_examples, test_examples = [], []
    for sid, samples in strain_to_samples.items():
        if sid in test_strains:
            test_examples.extend(samples)
        else:
            train_all_examples.extend(samples)

    print(f"#strains -> train_all: {len(train_strains) + len(val_strains)}, test: {len(test_strains)}")
    print(f"#seqs    -> train_all: {len(train_all_examples)}, test: {len(test_examples)}")

    # Extract CLS embeddings (with LoRA active)
    train_embeds = extract_cls_embeddings(
        train_all_examples, tokenizer, model, device,
        batch_size=BATCH_SIZE, max_length=MAX_LEN, desc="Embedding train+val"
    )
    test_embeds = extract_cls_embeddings(
        test_examples, tokenizer, model, device,
        batch_size=BATCH_SIZE, max_length=MAX_LEN, desc="Embedding test"
    )

    with open(OUT_TRAIN_JSON, "w") as f:
        json.dump(train_embeds, f, indent=2)
    with open(OUT_TEST_JSON, "w") as f:
        json.dump(test_embeds, f, indent=2)

    print(f"Done. Saved {len(train_embeds)} train(+val) embeddings -> {OUT_TRAIN_JSON}")
    print(f"Done. Saved {len(test_embeds)} test embeddings       -> {OUT_TEST_JSON}")

if __name__ == "__main__":
    main()
