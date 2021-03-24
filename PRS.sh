#!/bin/bash

# Requirements: plink2 and zcat in the path
# --- Parameters

# Input genotype data (with plink format flag)
INPUT="--pfile INPUT"

# Input PRS weights file (gzipped), example:
PRS="ref/BreastCancer_Zhang2020.score.gz"

# Output file name
OUTPUT=""

# ---

COL_SNP=`zcat $INPUT | head -n1 | tr '\t' '\n' | awk '{ print NR,$0 }' | grep -w SNP | awk '{ print $1 }'`
COL_A1=`zcat $INPUT | head -n1 | tr '\t' '\n' | awk '{ print NR,$0 }' | grep -w A1 | awk '{ print $1 }'`
COL_Z=`zcat $INPUT | head -n1 | tr '\t' '\n' | awk '{ print NR,$0 }' | grep -w Z | awk '{ print $1 }'`
COL_P=`zcat $INPUT | head -n1 | tr '\t' '\n' | awk '{ print NR,$0 }' | grep -w P | awk '{ print $1 }'`

for P in 0 1 2 3 4 5 6 7; do
	zcat $PRS | awk -v p=$P -v PCOL=$COL_P '$PCOL < 5 * 10^(-1*p)' > $OUTPUT.CUR.score
	plink2 $INPUT --score $OUTPUT.CUR.score $COL_SNP $COL_A1 $COL_Z --out $OUTPUT.PV$P
	rm $OUTPUT.CUR.score
done
