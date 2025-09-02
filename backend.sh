#!/bin/bash
# Parse arguments

OUTPUT_DIR=$1

# Define HLA region and reference genome
#REGION=chr6:25000000-35000000
refgenome="./hg38.fa"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

for CRAM_FILE in ./uploads/*; do
# Get the base name from the CRAM file
BASE_NAME=$(basename $CRAM_FILE )
SAMPLE=$(basename "$CRAM_FILE" | cut -d. -f1)

# Define intermediate and final output file paths
BAM_FILE=$OUTPUT_DIR/${BASE_NAME}.bam
SORTED_BAM=$OUTPUT_DIR/sorted_${BASE_NAME}.bam

# Step 1: Convert CRAM to BAM for the specified region
echo "Processing $CRAM_FILE..."
./samtools-env/bin/samtools  view -b -T $refgenome -o $BAM_FILE $CRAM_FILE 

# Step 2: Sort the BAM file
./samtools-env/bin/samtools  sort $BAM_FILE -o $SORTED_BAM

# Step 3: Index the sorted BAM file
./samtools-env/bin/samtools  index $SORTED_BAM
echo "Finished processing $CRAM_FILE. Output: $SORTED_BAM"

# Step 4: Change directory
cd ./hlaenv/opt/hla-la/src

# Step 5: Call HLA-PRG-LA
./HLA-LA.pl --BAM $SORTED_BAM --graph PRG_MHC_GRCh38_withIMGT --maxThreads 32 --samtools_bin ../../../../samtools-env/bin/samtools --bwa_bin ../../../../bwa-env/bin/bwa --picard_sam2fastq_bin ../../../../picard-tools-1.117/SamToFastq.jar --sampleID $SAMPLE --workingDir $OUTPUT_DIR

cd ../../../..
done

echo "All files have been processed. Results stored in: $OUTPUT_DIR"

# Step 6: Call the R script for data tidying
./Renv/bin/Rscript Data_tidying.R $OUTPUT_DIR
echo "Completed Analysis for all files. Analysis stored in $OUTPUT_DIR"