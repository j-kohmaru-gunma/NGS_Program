###########################################################
# Usage
###########################################################
#perl Coverage_filter_200929.pl -max <Max Coverage> -min <min coverage> -c <Coverage._File_list.txt>  -i <Input_File_list.txt> -o <Output name>

###########################################################
# Module
###########################################################
use Getopt::Long;
use FindBin;
use List::Util qw(max min);

###########################################################
# Main
###########################################################

$min = 5;
$max = 1000;
$outputname = "";
$dir = $FindBin::Bin;

GetOptions(
'input=s' => \$inputfile,
'cov=s' => \$covfile,
'output=s' => \$outputname,
'min=i' => \$min,
'max=i' => \$max
);

if($outputname eq ""){
    $outputname = $dir."/".$min."-".$max."_covfilter.bdg.txt";
}

print "\n";
print "--------------------------------------\n";
print "min\t：$min\n";
print "Max\t：$max\n";
print "Output\t：".$outputname."\n";
print "--------------------------------------\n";
print "\n";


open(INPUT, $inputfile);
open(COV, $covfile);


print "input file\n";
@in_arr=();
while(<INPUT>){
    $line = $_;
    print $line;
    $line =~ s/(\r\n|\r|\n)$//g;
    push(@in_arr,$line);
}
print "\n";


print "coverage file\n";
@cov_arr=();
while(<COV>){
    $line = $_;
    print $line;
    $line =~ s/(\r\n|\r|\n)$//g;
    push(@cov_arr,$line);
}
print "\n";

$inlen = @in_arr;
$covlen = @cov_arr;
if($inlen  != $covlen){
    print "Error!\n";
    print "Input files and Coverage files are different number.\n";
    print "$inlen\t!=\t$covlen\n";
    exit(0);
}

for($i=0;$i<@in_arr;$i++){
    $hdl = "IN".$i;
    open($hdl, $in_arr[$i]);
}
for($i=0;$i<@cov_arr;$i++){
    $hdl = "COV".$i;
    open($hdl, $cov_arr[$i]);
}


open(OUT, ">".$outputname);
open(DUM, $in_arr[0]);

$count=0;
$text = "";

while (<DUM>){

    @metharray = ();
    for($i=0;$i<@in_arr;$i++){
        $hdl = "IN".$i;
        $line = <$hdl>;
        @data = &getline($line);
        push(@metharray,sprintf("%.2f",$data[3]));
    }
    @covarray = ();
    for($i=0;$i<@cov_arr;$i++){
        $hdl = "COV".$i;
        $line = <$hdl>;
        @data = &getline($line);
        push(@covarray,$data[3]);
    }
    
    $covmin = min @covarray;
    $covmax = max @covarray;
    $methmin = min @metharray;
    $methmax = max @metharray;
    
    if($covmin >= $min and $covmax <= $max){
        $text .= "$data[0]\t$data[1]\t$data[2]";
        for($i=0;$i<@metharray;$i++){
            $text .= "\t$metharray[$i]";
        }
        $text .= "\n";
    }

    if($count%10000 == 0){
        print "$data[0]\t$data[1]\t$data[2]\n";
        print OUT $text;
        $text = "";
    }

    $count++;
}

print OUT $text;

###########################################################
# Subroutine
###########################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
