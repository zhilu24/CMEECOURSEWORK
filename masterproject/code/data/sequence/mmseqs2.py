import subprocess
import os
import sys
from glob import glob

import subprocess
import os
import sys
from glob import glob


def run_mmseqs2(faa_file, output_dir="../../data/filtered_output", threads=4, min_seq_id=0.25):
    # Ensure the input file exists
    if not os.path.exists(faa_file):
        raise FileNotFoundError(f"Input file '{faa_file}' not found.")

    # Prepare per-file temporary workspace and output path
    basename = os.path.basename(faa_file).replace(".faa", "")
    tmp_dir = f"./tmp_{basename}"
    os.makedirs(tmp_dir, exist_ok=True)
    os.makedirs(output_dir, exist_ok=True)

    # Define MMseqs2 paths
    db_path = os.path.join(tmp_dir, "db")              # createdb result
    cluster_path = os.path.join(tmp_dir, "clusterRes") # cluster mapping
    rep_seq_path = os.path.join(tmp_dir, "rep_seq")    # representatives sub-DB
    output_faa = os.path.join(output_dir, f"{basename}_filtered.faa")  # final FASTA

    # Build MMseqs2 database from the input FASTA
    subprocess.run(["mmseqs", "createdb", faa_file, db_path], check=True)

    # Cluster sequences using identity and coverage thresholds
    subprocess.run([
        "mmseqs", "cluster", db_path, cluster_path, tmp_dir,
        "--min-seq-id", str(min_seq_id),
        "-c", "0.8",
        "--threads", str(threads)
    ], check=True)

    # Extract representative sequences (one per cluster) into a sub-database
    subprocess.run(["mmseqs", "createsubdb", cluster_path, db_path, rep_seq_path], check=True)

    # Convert representatives to FASTA
    print(f"Converting representative sequences to FASTA -> {output_faa}")
    subprocess.run(["mmseqs", "convert2fasta", rep_seq_path, output_faa], check=True)

    print("Done -- Output written to:", output_faa)

    # Clean up the temporary directory
    subprocess.run(["rm", "-rf", tmp_dir])


# Batch driver: process all .faa files in a given directory
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python mmseqs_batch.py /path/to/folder_with_faa_files [output_dir]")
        sys.exit(1)

    input_dir = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) >= 3 else "../../data/filtered_output"

    # Discover all .faa files
    faa_files = glob(os.path.join(input_dir, "*.faa"))

    if not faa_files:
        print("No .faa files found in", input_dir)
        sys.exit(1)

    print(f"Found {len(faa_files)} .faa files. Processing...")

    # Process each file independently; failures do not stop the batch
    for faa_file in faa_files:
        try:
            run_mmseqs2(faa_file, output_dir)
        except Exception as e:
            print(f"Failed to process {faa_file}: {e}")
