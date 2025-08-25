import json
from collections import defaultdict
import numpy as np

def process_embeddings(input_file, output_file):
    # Load the embedding file 
    with open(input_file, "r") as f:
        all_embeddings = json.load(f)

    # Aggregate multiple embeddings for each strain_id 
    strain_to_vecs = defaultdict(list)
    for item in all_embeddings:
        strain_id = str(item["strain_id"])  # ensure it's a string
        vec = np.array(item["cls_embedding"])
        strain_to_vecs[strain_id].append(vec)

    # Compute the mean vector per strain 
    strain_avg_embeddings = []
    for strain_id, vec_list in strain_to_vecs.items():
        avg_vec = np.mean(vec_list, axis=0)
        strain_avg_embeddings.append({
            "strain_id": strain_id,
            "cls_embedding": avg_vec.tolist()
        })

    # Save as a new JSON file 
    with open(output_file, "w") as f:
        json.dump(strain_avg_embeddings, f, indent=2)

    print(f"{input_file} processed. {len(strain_avg_embeddings)} strains total. Saved to '{output_file}'")


# Process train and test separately
process_embeddings("cls_embeddings_train.json", "cls_avg_by_strain_train.json")
process_embeddings("cls_embeddings_test.json", "cls_avg_by_strain_test.json")
