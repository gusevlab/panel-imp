# 👁️ panel-imp

**Imputation workflow for targeted panels (typically from tumors)**

## Preliminaries

For imputation: install [STITCH](https://github.com/rwdavies/STITCH), and ensure that R, samtools, htslib, and vcftools can be called from the command line. Download 1000 Genomes reference data from [IMPUTE2](https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.html), which must include `*hap.gz` and `*legend.gz` files. 

A containerized version of STITCH is also available [here](https://hub.docker.com/r/stefangroha/stitch_gcs).

For other analyses: insure plink2 can be called from the command line.

## Imputation

*Impute germline variants directly from a list of sequenced BAM files.*

`IMPUTE.sh` uses the following parameters to perform imputation:
* DIR: The directory where outputs will be generated
* BAM_FILES: A file containing the list of BAMs to analyze
* BAM_NAMES: A file containing the names of the BAM files in the same order
* REF_POSFILE: A file listing the target sites to impute (an example is provided in `ref/`)
* REF_SAMPLE: A link to the reference sample file (an example is provided in `ref/`)
* REF_LEGEND: A link to the reference legend file
* REF_HAP: A link to the reference hap file

One run of the script will impute all input BAM files for the designated region. For the manuscript analysis 567 x 5MB batches were used and a list batch sizes is provided in `ref/IMPUTE.batches`.

The **output** is an imputed VCF file and diagnostic information. After imputation is completed, `MERGE.sh` can be used to merge all files (or all files from a given chromosome).

*Imputation parameters were kindly shared by Siyang Liu (BGI) based on work in [Liu et al. Cell, 2018](https://pubmed.ncbi.nlm.nih.gov/30290141/).*

## Quality Control

*Perform basic quality control on imputed genotypes*

`QC.sh` takes as `INPUT` the imputed VCF file and as `OUTPUT` the output file prefix. Executing the script will: run plink to convert the input VCF into a plink format file, correct variant identifiers to positions, extract SNP information, and perform basic quality control using the allele frequency and INFO score.

The **output** is a plink format file of all genotypes, an `HQ.extract` file with the QC passing variants.

## Ancestry

*Project imputed data into reference ancestry components*

`ANC.sh` takes as `INPUT` the plink format file (with appropriate plink flag), as `OUTPUT` the output file prefix, and as `REF` the directory containing reference ancestry scores (files are provided in `ref/`). Executing the script will: run multiple iterations of plink to project the input data into the ancestry component space of the reference data. The input is expected to include the entire genome (but see `sscore_sum.R` for combining across files).

The following **outputs** are generated: 3 NA (Native American) scores corresponding to EUR+AFR+EAS+NA populations; 2 CO (Continental) scores corresponding to EUR+AFR populations; 1 AA (African American) score corresponding to AA admixture; 2 EA (European) scores corresponding to North/South Europe and Ashkenazi populations. Each ancestry projection is in a plink format `*.sscore` file with one row per individual.

*All scores were derived from SNPWEIGHTS source files [here](https://cdn1.sph.harvard.edu/wp-content/uploads/sites/181/2014/05/SNPweights2.1.tar.gz) as described in [Chen et al. 2013 Bioinformatics](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3661048/).*

## Polygenic Risk

*Infer polygenic risk scores for imputed data*

`PRS.sh` takes as `INPUT` the plink format file (with appropriate plink flag), as `OUTPUT` the output file prefix, and as `PRS` the risk score weights (example file provided in `ref/BreastCancer_Zhang2020.score.gz` and must contain the labeled columns SNP, A1, Z, and P). Executing the script will: build multiple risk scores with increasing p-value thresholds and predict into the target data. The input is expected to include the entire genome (but see `sscore_sum.R` for combining across files). The output is a plink format `*.sscore` file with the risk score for each individual.

*The example risk score used here was derived from the breast cancer GWAS of [Zhang et al. Nature Genetics, 2020](https://pubmed.ncbi.nlm.nih.gov/32424353/).*
