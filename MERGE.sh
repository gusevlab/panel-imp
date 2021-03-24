#!/bin/bash

# Requirements: bcftools and plink in the path
# --- Parameters

# List of VCFs to merge
MERGE_LIST=""

# Name of output file
OUTPUT=""

# ---

# Index each of the files if needed:
cat $MERGE_LIST | while read line; do
if [ ! -f $line.tbi ]; then
tabix $line
fi
done

bcftools concat -a -f $MERGE_LIST -Oz -o $OUTPUT.vcf.gz
tabix $OUTPUT.vcf.gz
