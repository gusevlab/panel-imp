#!/bin/bash

# Requirements: plink2 in the path
# --- Parameters

# Input VCF file
INPUT=""

# Output file prefix
OUTPUT=""

# ---

# Convert to plink format (properly handling dosages)
plink2 --vcf $INPUT dosage=DS --out $OUT --double-id

# Correct SNP identifier issues by replacing identifier with position
mv $OUTPUT.pvar $OUTPUT.pvar.bk
cat $OUTPUT.pvar.bk | awk '{ if(substr($1,1,1) != "#") $3 = $1":"$2; print $0 }' | tr ' ' '\t' > $OUTPUT.pvar

# Extract SNP information
cat $OUTPUT.pvar | awk 'substr($1,1,1) != "#" { print $3,$NF }' | tr ';' '\t' | tr '=' '\t' > $OUTPUT.info

# Perform basic QC on minor allele frequency and imputation accuracy
cat $OUT.info | awk '$3 > 0.01 && $3 < 0.99 && $5 > 0.4 { print $1 }' > $OUT.HQ.extract
