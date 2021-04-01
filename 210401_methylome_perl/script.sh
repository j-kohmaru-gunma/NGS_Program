#! /bin/bash

dir=`dirname $0`
cd $dir

samples=()
samples+=("Day0.cpg")
samples+=("Day2-DFO24h.cpg")
samples+=("Day2-noDFO.cpg")
samples+=("Day8-DFO48h.cpg")
samples+=("Day8-noDFO.cpg")

perl TSS_filter.pl \
testdata/TSS.sort.bed.txt \
testdata/${samples[0]}.methyl.bedGraph.chr1.txt \
testdata/${samples[0]}.cover.bedGraph.chr1.txt \
testdata/${samples[1]}.methyl.bedGraph.chr1.txt \
testdata/${samples[1]}.cover.bedGraph.chr1.txt \
testdata/${samples[2]}.methyl.bedGraph.chr1.txt \
testdata/${samples[2]}.cover.bedGraph.chr1.txt \
testdata/${samples[3]}.methyl.bedGraph.chr1.txt \
testdata/${samples[3]}.cover.bedGraph.chr1.txt \
testdata/${samples[4]}.methyl.bedGraph.chr1.txt \
testdata/${samples[4]}.cover.bedGraph.chr1.txt

rm input.txt
rm input_cov.txt
for i in `seq 0 4`
do
    echo "output/${samples[$i]}.methyl.bedGraph.chr1.txt.tss±1000.bdg.txt" >> input.txt
    echo "output/${samples[$i]}.cover.bedGraph.chr1.txt.tss±1000.bdg.txt" >> input_cov.txt
done

perl Coverage_filter.pl -i input.txt -c input_cov.txt -min 5 -max 1000 -o output/All_methyl_cov5-1000.bdg

perl TSS_count.pl testdata/TSS.sort.bed.txt output/All_methyl_cov5-1000.bdg 