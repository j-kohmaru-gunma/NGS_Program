use File::Basename;
use FindBin;

#########################################################################################
#Open output files
#########################################################################################
$dir = $FindBin::Bin;
mkdir "$dir/output";

open(OUT, ">$dir/output/TSS_count_result.txt");
open(OUT2, ">$dir/output/TSS_methyl_result.txt");

#########################################################################################
#Generate Index for efficient search
#########################################################################################
$chr = "";
$pos = 0;
$count = 0;
$tmp_pointer = 0;
open(IN, $ARGV[1]);
open(POINT, ">$dir/output/file_pointer.txt");
while (<IN>){

    $line = $_;
    @data = &getline($line);
    
    print $line;
    
    if($count%1000==0){
        print "$data[0]\t$data[1]\t$tmp_pointer\n";
        print POINT "$data[0]\t$data[1]\t$tmp_pointer\n";
    }
    
    $tmp_pointer = tell(IN);
    $count++;
}

#########################################################################################
#Extract CpG methylation levels for each TSS
#########################################################################################
print OUT "chr\tstart\tend\tstrand\ttranscript_id\tgene_id\t";
print OUT "D2(-)<-0.25\tD2(+)<-0.25\tD8(-)<-0.25\tD8(+)<-0.25\t";
print OUT "D2(-)<-0.5\tD2(+)<-0.5\tD8(-)<-0.5\tD8(+)<-0.5\n";

print OUT2 "chr\tstart\tend\tstrand\ttranscript_id\tgene_id\t";
print OUT2 "chr\tstart\tend\tD0\tD2(-)\tD8(-)\tD2(+)\tD8(+)\tdistance_from_TSS\n";

open(TSS, $ARGV[0]);
while (<TSS>){

    @diff = (0,0,0,0,0,0,0,0);

    $line = $_;
    print $line;
    @tssdata = &getline($line);

    #Specify a 1kb upstream region from TSS based on strandness of a gene
    $chr = $tssdata[0];
    if($tssdata[3] eq "+"){
        $start = $tssdata[1] - 1000 - 1;
        $end = $tssdata[1] - 1;
    }else{
        $start = $tssdata[2];
        $end = $tssdata[2] + 1000;
    }
    
    #Output TSS information
    $tssinfo = "$chr\t".($start+1)."\t$end\t$tssdata[3]\t$tssdata[4]\t$tssdata[5]";
    print OUT "$tssinfo\t";

    #Using Index, find the file pointer just before TSS
    open(POINT, "$dir/output/file_pointer.txt");
    $pointer = 0;
    $flg=0;
    while(<POINT>){
        $line = $_;
        @data = &getline($line);
        if($chr eq $data[0]){
            $flg=1;
        }
        if($chr eq $data[0] and $start < $data[1]){
            last;
        }
        if($chr ne $data[0] and $flg==1){
            last;
        }
        $pointer = $data[2];
    }
    seek(IN,$pointer,0);
    
    
    #Counting methylation 
    while(<IN>){
        
        $line = $_;
        @data = &getline($line);

        if(($chr eq $data[0] and $end < $data[1]) or $chr ne $data[0]){
            last;
        }
    
        if($chr eq $data[0] and $start <= $data[1] and $end > $data[1]){
        
            if($tssdata[3] eq "+"){
                $dist = ($end - $data[1]);
            }else{
                $dist = ($data[1] - $start + 1);
            }
            
            print OUT2 "$tssinfo\t$data[0]\t".($data[1]+1)."\t".($data[2]+1)."\t$data[3]\t$data[4]\t$data[5]\t$data[6]\t$data[7]\t$dist\n";
            
            $tssinfo = "\t\t\t\t\t";
            
            #Count if difference in methylation levels is "-0.25 or less" or "-0.5 or less"
            if($data[4] - $data[3] <= -0.25){$diff[0]++;}   #D2(-)
            if($data[5] - $data[3] <= -0.25){$diff[1]++;}   #D8(-)
            if($data[6] - $data[3] <= -0.25){$diff[2]++;}   #D2(+)
            if($data[7] - $data[3] <= -0.25){$diff[3]++;}   #D8(+)
            if($data[4] - $data[3] <= -0.5){$diff[4]++;}   #D2(-)
            if($data[5] - $data[3] <= -0.5){$diff[5]++;}   #D8(-)
            if($data[6] - $data[3] <= -0.5){$diff[6]++;}   #D2(+)
            if($data[7] - $data[3] <= -0.5){$diff[7]++;}   #D8(+)
            
        }
    
    }
    
    #Output the methylation counting data
    print OUT "$diff[0]";
    print OUT "\t$diff[2]";
    print OUT "\t$diff[1]";
    print OUT "\t$diff[3]";
    print OUT "\t$diff[4]";
    print OUT "\t$diff[6]";
    print OUT "\t$diff[5]";
    print OUT "\t$diff[7]";
    print OUT "\n";

}

########################################################################
#Subroutine
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
