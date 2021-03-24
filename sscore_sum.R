### Merging ancestry scores from multiple file
### Run as `R --slave --args [file listing *sscore files] < score_sum.R`

args=commandArgs(T)
lst=args[1]


c = 1
for ( f in lst ) {
        cur = read.table( f , as.is=T,head=T,comment='')
        if ( c == 1 ) {
            tbl = cur
            tbl$SCORE1_AVG = tbl$SCORE1_AVG * tbl$NAMED_ALLELE_DOSAGE_SUM
        } else {
            tbl$NMISS_ALLELE_CT = tbl$NMISS_ALLELE_CT + cur$NMISS_ALLELE_CT
            tbl$NAMED_ALLELE_DOSAGE_SUM = tbl$NAMED_ALLELE_DOSAGE_SUM + cur$NAMED_ALLELE_DOSAGE_SUM
            tbl$SCORE1_AVG = tbl$SCORE1_AVG + cur$SCORE1_AVG * cur$NAMED_ALLELE_DOSAGE_SUM
        }
	c = c + 1
}

tbl$SCORE1_AVG = tbl$SCORE1_AVG / tbl$NAMED_ALLELE_DOSAGE_SUM
write.table(tbl , quote=F , row.names=F , col.names=T , sep='\t' )
