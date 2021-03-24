#!/bin/bash

# Requirements: STITCH.R is in the path and works
# --- Parameters:

# Where to put data:
DIR="./"

# File containing list of BAMs to analyze
BAM_FILES=""
# File containing list of sample identifiers (in the same order as BAM_FILES)
BAM_NAMES=""

# Locus positions:
CHR=""
P0=""
P1=""

# STITCH references
REF_POSFILE="HRC.r1-1.GRCh37.wgs.mac5.sites.${CHR}.EUR_AF01.posfile"
REF_FASTA="Homo_sapiens_assembly19.fasta"
REF_SAMPLE="1000GP_Phase3.sample"
REF_LEGEND="1000GP_Phase3_chr${CHR}.legend.gz"
REF_HAP="1000GP_Phase3_chr${CHR}.hap.gz"

# ---

mkdir ${DIR}/chr${CHR}_${P0}_${P1}

time Rscript STITCH.R \
${DIR}/chr${CHR}_${P0}_${P1}/ \
$BAM_FILES \
$REF_FASTA \
$REF_POSFILE \
10 1240 6 40 $P0 $P1 ${CHR} 250000 \
$REF_SAMPLE $REF_LEGEND $REF_HAP \
$BAM_NAMES
