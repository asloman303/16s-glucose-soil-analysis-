import pandas as pd
import os
import argparse

def combine_kraken_reports(reports_dir, metadata_file, rank, output_file):
    """
    Parses multiple Kraken report files and combines them into a single
    abundance table based on a specified taxonomic rank.

    Args:
        reports_dir (str): Path to the directory containing Kraken report files.
        metadata_file (str): Path to the metadata CSV file.
        rank (str): The taxonomic rank to aggregate counts at (e.g., 'G' for genus, 'S' for species).
        output_file (str): Path to save the combined abundance table CSV.
    """
    # --- 1. Read metadata to get sample IDs ---
    try:
        metadata = pd.read_csv(metadata_file)
        sample_ids = metadata['SampleID'].tolist()
        print(f"Found {len(sample_ids)} sample IDs in '{metadata_file}'")
    except FileNotFoundError:
        print(f"Error: Metadata file not found at '{metadata_file}'")
        return

    # --- 2. Parse each Kraken report file ---
    all_samples_data = []
    for sample_id in sample_ids:
        report_filename = f"{sample_id}.report"
        report_path = os.path.join(reports_dir, report_filename)

        if not os.path.exists(report_path):
            print(f"Warning: Report file not found for sample '{sample_id}' at '{report_path}'. Skipping.")
            continue

        sample_counts = {}
        with open(report_path, 'r') as f:
            for line in f:
                parts = line.strip().split('\t')
                if len(parts) < 6:
                    continue

                reads_at_taxon = int(parts[2].strip())
                rank_code = parts[3].strip()
                taxon_name = parts[5].strip()

                if rank_code == rank:
                    sample_counts[taxon_name] = reads_at_taxon
        
        sample_series = pd.Series(sample_counts, name=sample_id)
        all_samples_data.append(sample_series)

    if not all_samples_data:
        print("Error: No report files were successfully processed. Aborting.")
        return

    # --- 3. Combine all sample data into a single DataFrame ---
    abundance_df = pd.concat(all_samples_data, axis=1)
    abundance_df = abundance_df.fillna(0).astype(int)

    # --- 4. Save the final table ---
    abundance_df.to_csv(output_file)
    print(f"\nSuccessfully created abundance table at '{output_file}'")
    print(f"Table contains {abundance_df.shape[0]} taxa and {abundance_df.shape[1]} samples.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Combine Kraken reports into an abundance table.")
    parser.add_argument('-d', '--reports_dir', required=True, help="Directory containing your Kraken report files.")
    parser.add_argument('-m', '--metadata_file', required=True, help="Path to your metadata.csv file.")
    parser.add_argument('-r', '--rank', required=True, help="Taxonomic rank to summarize (e.g., 'G' for Genus, 'S' for Species).")
    parser.add_argument('-o', '--output_file', required=True, help="Name of the output CSV file for the abundance table.")
    
    args = parser.parse_args()
    
    combine_kraken_reports(
        reports_dir=args.reports_dir,
        metadata_file=args.metadata_file,
        rank=args.rank,
        output_file=args.output_file
    )
