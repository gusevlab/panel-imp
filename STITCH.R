#! R
#!/usr/bin/env Rscript
library("STITCH")

args=commandArgs(T)
outputdir=args[1]
bamlist=args[2]
ref=args[3]
human_posfile=args[4]
human_K=as.numeric(args[5])
human_nGen=as.numeric(args[6])
nCores=as.numeric(args[7])
niterations=as.numeric(args[8])
regionStart=as.numeric(args[9])
regionEnd=as.numeric(args[10])
chr=as.character(args[11])
buffer=as.numeric(args[12])
human_reference_sample_file=as.character(args[13])
human_reference_legend_file=as.character(args[14])
human_reference_haplotype_file=as.character(args[15])
sampleNames_file=as.character(args[16])
options(scipen = 20)
originalRegionName=paste(chr,regionStart,regionEnd,sep=".")
output_format <- "bgvcf"
tempdir=outputdir
environment <- "server" 

#setwd(outputdir)
#sessionInfo("STITCH")

STITCH(
  bamlist = bamlist,
  reference = ref,
  outputdir = outputdir,
  output_format = output_format,
  method = "diploid",
  regionStart = regionStart,
  regionEnd = regionEnd,
  regenerateInput = TRUE,
  originalRegionName = originalRegionName,
  buffer = buffer,
  B_bit_prob = 8,
  niterations = niterations,
  chr = chr,
  inputBundleBlockSize = 100,
  reference_populations = c("ACB","ASW","BEB","CDX","CEU","CHB","CHS","CLM","ESN","FIN","GBR","GIH","GWD","IBS","ITU","JPT","KHV","LWK","MSL","MXL","PEL","PJL","POP","PUR","STU","TSI","YRI"),
  reference_haplotype_file = human_reference_haplotype_file,
  reference_sample_file = human_reference_sample_file,
  reference_legend_file = human_reference_legend_file,
  shuffleHaplotypeIterations = NA,
  refillIterations = NA,
  genfile = "",
  posfile = human_posfile, 
  K = human_K, 
  tempdir = tempdir, 
  sampleNames_file = sampleNames_file,
  #gridWindowSize = gridsize,
  nCores = nCores,
  nGen = human_nGen
)
