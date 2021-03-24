#!/bin/bash

# Requirements: plink2 is in the path
# --- Parameters

# Input genotypes (with plink input flag)
INPUT="--pfile INPUT"

# name of output
OUTPUT=""

# ancestry reference data directory
REF="./ref"

# ---

par="no-mean-imputation"

# Native
plink2 $INPUT --score $REF/SNPWT.NA.score 1 2 5 $par --out $OUTPUT.NA.$CHR.PC1
plink2 $INPUT --score $REF/SNPWT.NA.score 1 2 6 $par --out $OUTPUT.NA.$CHR.PC2
plink2 $INPUT --score $REF/SNPWT.NA.score 1 2 7 $par --out $OUTPUT.NA.$CHR.PC3

# Continental
plink2 $INPUT --score $REF/SNPWT.CO.score 1 2 5 $par --out $OUTPUT.CO.$CHR.PC1
plink2 $INPUT --score $REF/SNPWT.CO.score 1 2 6 $par --out $OUTPUT.CO.$CHR.PC2

# African American
plink2 $INPUT --score $REF/SNPWT.AA.score 1 2 5 $par --out $OUTPUT.AA.$CHR.PC1

# European
plink2 $INPUT --score $REF/SNPWT.EA.score 1 2 5 $par --out $OUTPUT.EA.$CHR.PC1
plink2 $INPUT --score $REF/SNPWT.EA.score 1 2 6 $par --out $OUTPUT.EA.$CHR.PC2
