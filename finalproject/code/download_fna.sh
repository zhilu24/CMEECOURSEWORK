#!/bin/bash

# 设置输入 CSV 文件名（请按需修改）
CSV_FILE="../data/optimum_data_mean_species.csv"

# 设置输出目录
OUTPUT_DIR="../data/genomes_fna"
mkdir -p "$OUTPUT_DIR"

# 提取 taxid 列（忽略表头），循环下载
tail -n +2 "$CSV_FILE" | cut -d',' -f2 | while read taxid
do
    if [[ -n "$taxid" ]]; then
        echo "📥 Downloading genome for TaxID: $taxid"
        # 下载并解压（使用 dehydrated 模式只下载所需内容）
        datasets download genome taxon "$taxid" --dehydrated --filename "$OUTPUT_DIR/${taxid}.zip"
        
        unzip -o "$OUTPUT_DIR/${taxid}.zip" -d "$OUTPUT_DIR/${taxid}"
        rm "$OUTPUT_DIR/${taxid}.zip"
        
        echo "✅ Finished: $taxid"
    fi
done

echo "🎉 All genomes downloaded to $OUTPUT_DIR/"
