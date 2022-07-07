#! /bin/bash

dir=`dirname $0`
cd $dir

# Saf file setting
saf="　1_2_3_4_5_6_7_8_9_10_q0.00000001_IDR0.05_merge.saf"

# Sample name setting
samples=()
samples+=("Day0.cpg")
samples+=("Day2-DFO24h.cpg")
samples+=("Day2-noDFO.cpg")
samples+=("Day8-DFO48h.cpg")
samples+=("Day8-noDFO.cpg")

for i in 250 500 1000
do

    if [ 1 -eq 1 ] ; then
        # Saf convert bed files around ATAC peak center +/-250,500,1000bp
        perl ATAC_Peak_bed.pl ${i} $saf\

        # Filtering data BED range
        perl ATAC_bed_filter.pl \
        ${saf}.peak±${i}.bed \
        data/${samples[0]}.methyl.bedGraph \
        data/${samples[0]}.cover.bedGraph \
        data/${samples[1]}.methyl.bedGraph \
        data/${samples[1]}.cover.bedGraph \
        data/${samples[2]}.methyl.bedGraph \
        data/${samples[2]}.cover.bedGraph \
        data/${samples[3]}.methyl.bedGraph \
        data/${samples[3]}.cover.bedGraph \
        data/${samples[4]}.methyl.bedGraph \
        data/${samples[4]}.cover.bedGraph
    fi
    

    if [ 1 -eq 1 ] ; then
        rm input_${i}.txt
        rm cov_${i}.txt
    
        for j in `seq 0 4`
        do
            echo "output/${samples[$j]}.methyl_${saf}.peak±${i}.bed.bdg" >> input_${i}.txt
            echo "output/${samples[$j]}.cover_${saf}.peak±${i}.bed.bdg" >> cov_${i}.txt
        done
        
        # Filtering data by coverage condition
        perl Coverage_filter.pl -i input_${i}.txt -c cov_${i}.txt -min 5 -max 1000 -o output/All_methyl_cov5-1000±${i}.bdg
    fi
        
    if [ 1 -eq 1 ] ; then
        # Counting DNA Methylation around TSS
        perl methyl_count.pl ${saf}.peak±${i}.bed output/All_methyl_cov5-1000±${i}.bdg -o methyl_result±${i}
        
        perl split_chr.pl output/methyl_result±${i}.txt
    fi
    
done
