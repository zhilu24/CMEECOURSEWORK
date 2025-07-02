from pathlib import Path
from Bio import SeqIO
import pyrodigal
import multiprocessing

def sci_to_conf(evalue_str: str) -> float:
    """Convert E-value (scientific notation) to confidence threshold (0–100)."""
    val = float(evalue_str)
    if not 0 < val < 1:
        raise ValueError("E-value must be between 0 and 1 (exclusive)")
    return 100 * (1 - val)

def process_single_file(args):
    """Process a single .fna file: predict proteins with confidence filter."""
    fna_file, output_dir, conf_threshold = args
    gene_finder = pyrodigal.GeneFinder(meta=True)

    record = next(SeqIO.parse(fna_file, "fasta"))
    genes = gene_finder.find_genes(str(record.seq))

    output_faa = output_dir / f"{Path(fna_file).stem}_proteins.faa"
    count = 0
    with open(output_faa, "w") as out_f:
        for i, gene in enumerate(genes, 1):
            if gene.confidence() >= conf_threshold:
                protein_seq = gene.translate()
                out_f.write(f">gene{i}_{Path(fna_file).stem}\n{protein_seq}\n")
                count += 1

    print(f"✅ {Path(fna_file).name}: Saved {count} confident proteins.")
    return output_faa

def translate_all_fna_parallel(input_dir, output_dir, evalue="1e-3", nproc=4):
    """Run protein prediction on all .fna files in parallel."""
    input_dir = Path(input_dir)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    conf_threshold = sci_to_conf(evalue)
    fna_files = sorted(input_dir.glob("*.fna"))
    args_list = [(str(fna), output_dir, conf_threshold) for fna in fna_files]

    print(f"🔧 Starting translation of {len(fna_files)} files with {nproc} processes...")

    with multiprocessing.Pool(processes=nproc) as pool:
        results = pool.map(process_single_file, args_list)

    print("🎉 All files processed.")
    return results

def main():
    translate_all_fna_parallel(
        input_dir="../data/labelled_genomes",
        output_dir="../data/translated_proteins",
        evalue="1e-3",
        nproc=4
    )

if __name__ == "__main__":
    main()
