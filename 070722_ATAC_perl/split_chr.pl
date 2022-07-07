use File::Basename;
use FindBin;

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
$year += 1900;
$mon++;

#########################################################################################
#Main
#########################################################################################
$name = basename($ARGV[0],'.txt');
$dir = $FindBin::Bin;
mkdir "${dir}/${name}";

open("DATA", $ARGV[0]);
$chr = "chr1";
open("OUT",">${dir}/${name}/${chr}.txt");

$header = <DATA>;
print OUT $header;

while(<DATA>){
    $line = $_;
    @data = &getline($line);
    
    if($chr eq $data[0] or $data[0] eq ""){
        #print $line."\n";
        print OUT $line."\n";
    }else{
    
        print OUT "\n";;
        print OUT "出力日時：$year年$mon月$mday日 $hour時$min分$sec秒";
        
        $chr = $data[0];
        
        if($chr !~ /^chr/){last;}
        
        open("OUT",">${dir}/${name}/${chr}.txt");
        print OUT $header;
        print $line."\n";
        print OUT $line."\n";
    }   
}

########################################################################
#サブルーチン
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
