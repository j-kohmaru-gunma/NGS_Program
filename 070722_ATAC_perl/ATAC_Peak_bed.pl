use File::Basename;
use FindBin;
use POSIX qw(floor ceil);

#########################################################################################
# Extract regions around ATAC-Seq peaks
#########################################################################################

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
$year += 1900;
$mon++;

for($i=1;$i<@ARGV;$i++){

    $name = basename($ARGV[$i],'.bed');
    $dir = $FindBin::Bin;

    open(DATA, $ARGV[$i]);
    
    open(OUT, ">".$dir."/".$name.".peak±".${ARGV[0]}.".bed");

    while (<DATA>){

        $line = $_;
        @safdata = &getline($line);
        $chr = $safdata[1];
        $center = floor(($safdata[2] + $safdata[3])/2);
        
        $start = $center - $ARGV[0];
        $end = $center + $ARGV[0];
        print OUT $chr."\t".$start."\t".$end."\t".$safdata[0]."\n";
        
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
