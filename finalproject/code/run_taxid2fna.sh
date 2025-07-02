#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/bin:$PATH

# ---------------------------------------------------------------------------
# Frome a CSV file, extract taxids and Run taxid2fna.sh for more NCBI TaxIDs.
# Prints a "Processing TaxID …" line to the console, but redirects all
# script output (stdout + stderr) into one combined log file.
# ---------------------------------------------------------------------------


if [[ "$#" -eq 0 ]]; then
  echo "Usage: $0 <taxid1> [taxid2 taxid3 ...]" >&2
  exit 1
fi

script_dir="/Users/zhangzhilu/Desktop/finalproject_2/temperature_and_ph/code"
runlog_dir="/Users/zhangzhilu/Desktop/finalproject_2/temperature_and_ph/data/logs"
mkdir -p "$runlog_dir"

successes=()
failures=()

# Timestamped log file
log_file="${runlog_dir}/taxid2fna_$(date +%Y%m%d_%H%M%S).log"

cd "$script_dir"
source ~/anaconda3/bin/activate opt_env

for taxid in "$@"; do
  echo "→ Processing TaxID ${taxid}"
  if ./taxid2fna.sh "${taxid}" >>"$log_file" 2>&1; then
    successes+=("${taxid}")
  else
    failures+=("${taxid}")
    echo "⚠️ taxid2fna.sh failed for TaxID ${taxid}" >>"$log_file"
  fi
done

echo "✓ Finished. Full log: \"$log_file\""
echo "✅ Success: ${successes[*]:-None}"
echo "❌ Failed: ${failures[*]:-None}"

conda deactivate 2>/dev/null || true
