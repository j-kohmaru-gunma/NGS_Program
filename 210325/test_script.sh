cd testdata

perl ../TSS_filter TSS.sort.bed test.CpG.bedGraph

perl ../Coverage_filter.pl -i input.txt -c input_cov.txt -min 5 -max 1000 -o All_methyl_cov5-1000.bdg

perl ../TSS_count.pl output/All_methyl_cov5-1000.bdg 
