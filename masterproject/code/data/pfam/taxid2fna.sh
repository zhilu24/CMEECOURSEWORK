#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/bin:$PATH

# Download NCBI genome for a given TaxID and save .fna to labelled_genomes_new/

# Change to the working directory
cd /Users/zhangzhilu/Desktop/finalproject_2/temperature_and_ph/code/ || {
  echo "Error: Failed to change to data directory."
  exit 1
}

# Input check
taxid="${1:-}"
if [[ -z "$taxid" ]]; then
  echo "Usage: $0 <taxid>"
  exit 1
fi

# Check required tools
if ! command -v datasets >/dev/null 2>&1; then
  echo "Error: 'datasets' CLI not found."
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: 'unzip' not found."
  exit 1
fi

# Create a temporary directory
tmpdir=$(mktemp -d "tempfiles_${taxid}_XXXX") || {
  echo "Error: Failed to create temporary directory."
  exit 1
}

# Download genome for the TaxID
if ! datasets download genome taxon "$taxid" --reference --filename "${taxid}_genomes.zip"; then
  echo "Error: Failed to download genome for taxid $taxid."
  rm -rf "$tmpdir"
  exit 1
fi

# Unzip the downloaded archive
if ! unzip -q "${taxid}_genomes.zip" -d "$tmpdir"; then
  echo "Error: Failed to unzip downloaded genome."
  rm -rf "$tmpdir" "${taxid}_genomes.zip"
  exit 1
fi

# Locate the genome directory (GCF*)
data_dir=$(find "$tmpdir"/ncbi_dataset/data -type d -name "GCF*" | head -n 1)
if [[ -z "$data_dir" ]]; then
  echo "Error: No genome directory found for taxid $taxid."
  rm -rf "$tmpdir" "${taxid}_genomes.zip"
  exit 1
fi

# Find a .fna file
fna_path=$(find "$data_dir" -maxdepth 1 -name "*.fna" | head -n 1)
if [[ -z "$fna_path" ]]; then
  echo "Error: No .fna file found for taxid $taxid."
  rm -rf "$tmpdir" "${taxid}_genomes.zip"
  exit 1
fi

# Prepare destination and move the .fna file with a new name
dest_dir="../data/labelled_genomes_new"
mkdir -p "$dest_dir" || {
  echo "Error: Failed to create destination directory."
  rm -rf "$tmpdir" "${taxid}_genomes.zip"
  exit 1
}

gcf_id=$(basename "$fna_path")
if ! mv "$fna_path" "${dest_dir}/${taxid}_${gcf_id}"; then
  echo "Error: Failed to move .fna file."
  rm -rf "$tmpdir" "${taxid}_genomes.zip"
  exit 1
fi

# Cleanup temporary files
rm -rf "$tmpdir" "${taxid}_genomes.zip" || {
  echo "Warning: Failed to clean up temporary files."
}
