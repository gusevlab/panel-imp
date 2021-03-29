version 1.0

#############
### Workflow
#############
workflow STITCH {
    input {
        ### INPUTS ###
        # file with positions which are processed in parallel
        File pos_parallel
        # list of bams that need to be imputed
        File bamlist
        # list of sample names
        File bamlist_names
        # reference fasta
        File ref_fasta
        # position file of SNPs
        File posfile_list
        # Number of ancestral haplotypes in the model (we use 10)
        Int human_K
        # Controls recombination rate between sequenced samples and ancestral
        # haplotypes (we use 1240)
        Int human_nGen
        # number of cores (for each parallel imputation)
        Int nCores
        # number of iterations (we use 40)
        Int niterations
        # buffer of region to perform imputation over (imputation run start-buffer
        # to stop+buffer (we use 250000)
        Int buffer
        # human reference legend file
        File reference_legend_file_list
        # human reference haplotype file
        File reference_haplotype_file_list
        # human reference sample file
        File reference_sample_file
    }
    

    ### CALLS ###
    Array[String] chr_pos = read_lines(pos_parallel)
    Array[String] posfile_array = read_lines(posfile_list)
    Array[String] reference_legend_file_array = read_lines(reference_legend_file_list)
    Array[String] reference_haplotype_file_array = read_lines(reference_haplotype_file_list)

    # Array has to be sorted by chromosome number!
    Int length_posarray = length(chr_pos)
    scatter(i in range(length_posarray)) {  
        Int chr=sub(chr_pos[i],"([0-9]{1,2}) .*","$1")
        Int regionStart=sub(chr_pos[i],"[0-9]{1,2} ([0-9]*).*","$1")
        Int regionEnd=sub(chr_pos[i],".* ([0-9]*)$","$1")

        Int index=chr-1
        File posfile=posfile_array[index] 
        File reference_legend_file=reference_legend_file_array[index] 
        File reference_haplotype_file=reference_haplotype_file_array[index] 

        call run_imputation {
            input:
                bamlist=bamlist,
                bamlist_names=bamlist_names,
                ref_fasta=ref_fasta,
                posfile=posfile,
                human_K=human_K,
                human_nGen=human_nGen,
                nCores=nCores,
                niterations=niterations,
                buffer=buffer,
                reference_legend_file=reference_legend_file,
                reference_haplotype_file=reference_haplotype_file,
                reference_sample_file=reference_sample_file,
                chr=chr,
                regionStart=regionStart,
                regionEnd=regionEnd,
                # disk_size = disk_size
        }
    }
    call merge_vcf { input: files=run_imputation.output_file }
    output {
        File vcf=merge_vcf.merged
    }
}

#############
### Tasks
#############
task run_imputation {
    ### INPUTS ###
    input {
        # list of bams that need to be imputed
        File bamlist
        # list of sample names
        File bamlist_names
        # reference fasta
        File ref_fasta
        # position file of SNPs
        File posfile
        # Number of ancestral haplotypes in the model (we use 10)
        Int human_K
        # Controls recombination rate between sequenced samples and ancestral
        # haplotypes (we use 1240)
        Int human_nGen
        # number of cores (for each parallel imputation)
        Int nCores
        # number of iterations (we use 40)
        Int niterations
        # buffer of region to perform imputation over (imputation run start-buffer
        # to stop+buffer (we use 250000)
        Int buffer
        # human reference legend file
        File reference_legend_file
        # human reference haplotype file
        File reference_haplotype_file
        # human reference sample file
        File reference_sample_file
        # Chromosome
        Int chr
        # position start for imputation
        Int regionStart
        # position end for imputation
        Int regionEnd
    }

    command {
        export GCS_OAUTH_TOKEN=`gcloud auth application-default print-access-token` && \
        /usr/bin/time -v /STITCH/STITCH.R --outputdir=./ \
                          --bamlist=${bamlist} \
                          --reference=${ref_fasta} \
                          --posfile=${posfile} \
                          --K=${human_K} \
                          --nGen=${human_nGen} \
                          --nCores=${nCores} \
                          --niterations=${niterations} \
                          --regionStart=${regionStart} \
                          --regionEnd=${regionEnd} \
                          --chr=${chr} \
                          --buffer=${buffer} \
                          --reference_legend_file=${reference_legend_file} \
                          --reference_haplotype_file=${reference_haplotype_file} \
                          --reference_sample_file=${reference_sample_file} \
                          --reference_populations='c("ACB","ASW","BEB","CDX","CEU","CHB","CHS","CLM","ESN","FIN","GBR","GIH","GWD","IBS","ITU","JPT","KHV","LWK","MSL","MXL","PEL","PJL","POP","PUR","STU","TSI","YRI")' \
                          --sampleNames_file=${bamlist_names} \
                          --method=diploid \
                          --regenerateInput=TRUE \
                          --inputBundleBlockSize=100 \
                          --shuffleHaplotypeIterations=NA \
                          --refillIterations=NA \
                          --output_format=bgvcf \
                          --B_bit_prob=8
    }
    
    output {
        File output_file = "stitch.${chr}.${regionStart}.${regionEnd}.vcf.gz"
    }
    runtime {
        docker: "stefangroha/stitch_gcs:0.2"
        memory: "40 GB"
        cpu: nCores
        maxRetries: 3
        disks: "local-disk 20 HDD"
    }
}

task merge_vcf {
    ### INPUTS ###
    input {
        # Array of vcf files
        Array[File] files
    }
    
    command <<<
        echo "Sorting files"
        for file in ~{sep=' ' files};do echo $file; done | awk '{split($1,a,".")}{print $1, a[2], a[3]}' | sort -n -k2,2 -k3,3 | cut -d" " -f1 > sorted.files        
        echo "Indexing files"
        for file in ~{sep=' ' files}
        do
            /STITCH/bcftools index $file
        done
        echo "Concatenating files"
        /STITCH/bcftools concat -o stitch.complete.vcf.gz -Oz -f sorted.files
    >>>
    
    output {
        File merged = "stitch.complete.vcf.gz"
    }
    runtime {
        docker: "stefangroha/stitch_gcs:0.2"
        memory: "10 GB"
        disks: "local-disk 50 HDD"
    }
}
