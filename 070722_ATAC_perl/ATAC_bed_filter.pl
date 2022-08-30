use File::Basename;
use FindBin;
@datalist = [];

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
$year += 1900;
$mon++;

open(BED, $ARGV[0]);
#########################################################################################
# Extract methylation levels and read depth for individual CpGs located within bed regions
#########################################################################################

for($i=1;$i<@ARGV;$i++){

    $name = basename($ARGV[$i],'.bedGraph');
    $dir = $FindBin::Bin;

    open(DATA, $ARGV[$i]);
    
    mkdir $dir."/output"; 
    open(OUT, ">".$dir."/output/".$name."_".$ARGV[0].".bdg");

    $count = 0;
    $text = "";
    $pointer=0;
    
    seek(BED,0,0);
    while (<BED>){

        $line = $_;
        @tssdata = &getline($line);
        $chr = $tssdata[0];

        $start = $tssdata[1];
        $end = $tssdata[2];
        
        #Skip chrN_random and LAMBDA
        if($chr =~ /random$/ or $chr =~ /^LAMBDA/){
            next;
        }
        
        print $line."\r";
        
        $flg = 0;
        
        seek(DATA,$pointer,0);
        while (<DATA>){
            $line = $_;
            @data = &getline($line);
        
            if($data[0] eq $chr and $data[1] >= $start and $data[1] < $end){
                $flg=1;
                print OUT $line."\n";

            }elsif($data[0] eq $chr and $data[1] >= $end){
                last;
                
            }elsif($flg==1){
                last;
                
            }elsif($data[0] gt $chr){
                last;
            }
            
            $pointer = tell(DATA);
        }
    }
    
    print OUT "\n";;
    print OUT "Output Date:$year/$mon/$mday $hour:$min:$sec";
}

########################################################################
# Subroutine
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
