
use Getopt::Long;           #For command line options
use File::Basename;
use FindBin;
use Math::Round;

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
$year += 1900;
$mon++;

#########################################################################################
#Open output files
#########################################################################################

GetOptions(
'output=s' => \$outputname,
);

#########################################################################################
#Open output files
#########################################################################################
$dir = $FindBin::Bin;
mkdir "$dir/output";

open(OUT, ">$dir/output/${outputname}.txt");
open(OUT2, ">$dir/output/${outputname}_average.txt");

#########################################################################################
#Generate Index for efficient search
#########################################################################################
$chr = "";
$pos = 0;
$count = 0;
open(IN, $ARGV[1]);
open(POINT, ">$dir/output/file_pointer.txt");
$in_line = <IN>;
$tmp_pointer = tell(IN);
while (<IN>){

    $line = $_;
    @data = &getline($line);
    
    if($count%1000==0){
        #print "$data[0]\t$data[1]\t$tmp_pointer\n";
        print POINT "$data[0]\t$data[1]\t$tmp_pointer\n";
    }
    
    $tmp_pointer = tell(IN);
    $count++;
}

#########################################################################################
#Extract CpG methylation levels for each TSS
#########################################################################################



open(ATAC, $ARGV[0]);
seek(IN,0,0);

$in_line = <IN>;
$in_line =~ s/(\r\n|\r|\n)$//g;
print OUT "chr\tstart\tend\tATAC_peak\t${in_line}\n";
print OUT2 "ATAC_peak\t${in_line}\tCpGs\n";

while (<ATAC>){

    $line = $_;
    #print $line;
    @atacdata = &getline($line);

    if(@atacdata<=1){last;}

    #
    $chr = $atacdata[0];
    $start = $atacdata[1];
    $end = $atacdata[2];
    $label = $atacdata[3];

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
    
    #print "$chr\t$start - $end\t$pointer\n";
    #print OUT "$info\n";
    
    #Counting methylation 
    $count=0;
    @datacount = (0,0,0,0,0,0,0,0);
    while(<IN>){
        
        $line = $_;
        @data = &getline($line);

        if(($chr eq $data[0] and $end < $data[1]) or $chr lt $data[0]){
            last;
        }
    
        if($chr eq $data[0] and $start <= $data[1] and $end > $data[1]){
            print OUT "$chr\t$start\t$end\t$label\t${line}\n";  
            $count++;
            for($i=3;$i<@data;$i++){$datacount[$i] += $data[$i];}
        }
    }
    if($count>0){
        for($i=3;$i<7;$i++){$datacount[$i] = round($datacount[$i]/$count*100)/100;}
    }
    print OUT2 "$label\t$chr\t$start\t$end\t$datacount[3]\t$datacount[4]\t$datacount[5]\t$datacount[6]\t$datacount[7]\t$count\n";  
}

print OUT "\n";;
print OUT "出力日時：$year年$mon月$mday日 $hour時$min分$sec秒";

print OUT2 "\n";;
print OUT2 "出力日時：$year年$mon月$mday日 $hour時$min分$sec秒";

########################################################################
#Subroutine
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
