###########################################################
#(How to use)
###########################################################
#perl Coverage_filter.pl -max <Max Coverage> -min <min coverage> -c <Coverage._File_list.txt>  -i <Input_File_list.txt> -o <Output name>

###########################################################
#(Importing modules)
###########################################################
use Getopt::Long;           #For command line options
use FindBin;
use List::Util qw(max min);

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
$year += 1900;
$mon++;

###########################################################
#(Getting arguments)
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

###########################################################
#(Open files)
###########################################################

open(INPUT, $inputfile);    #a bdg file for methylation levels
open(COV, $covfile);        #a bed file for gene locations

#Loading a methylation level file
print "input file\n";
@in_arr=();
while(<INPUT>){
    $line = $_;
    print $line;
    $line =~ s/(\r\n|\r|\n)$//g;
    push(@in_arr,$line);
}
print "\n";

#Loading a coverage file
print "coverage file\n";
@cov_arr=();
while(<COV>){
    $line = $_;
    print $line;
    $line =~ s/(\r\n|\r|\n)$//g;
    push(@cov_arr,$line);
}
print "\n";

#Check if the numbers of lines are consistent both in methylation level and coverage files
$inlen = @in_arr;
$covlen = @cov_arr;
if($inlen  != $covlen){
    print "Error:inconsistency in line numbers\n";
    print "$inlen\t!=\t$covlen\n";
    exit(0);
}

#Open methylation level and coverage files
for($i=0;$i<@in_arr;$i++){
    $hdl = "IN".$i;
    open($hdl, $in_arr[$i]);
}
for($i=0;$i<@cov_arr;$i++){
    $hdl = "COV".$i;
    open($hdl, $cov_arr[$i]);
}

#Open an output file
open(OUT, ">".$outputname);

###########################################################
#(Output only when coverage is within a specified range)
###########################################################

$count=0;
$text = "";

open(DUM, $in_arr[0]);  #Open a dummy file for the while statement

print OUT "chr\tstart\tend";
for($i=0;$i<@in_arr;$i++){print OUT "\t$in_arr[$i]";}
print OUT "\n";
        
while (<DUM>){

    #Get methylation level value
    @metharray = ();
    for($i=0;$i<@in_arr;$i++){
        $hdl = "IN".$i;
        $line = <$hdl>;
        @data = &getline($line);
        push(@metharray,sprintf("%.2f",$data[3]));
    }
    
    #Get coverage value
    @covarray = ();
    for($i=0;$i<@cov_arr;$i++){
        $hdl = "COV".$i;
        $line = <$hdl>;
        @data = &getline($line);
        push(@covarray,$data[3]);
    }
    
    #When a coverage value is within a specified range, store the data in $text variable
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
    
    #Write $text variable to the output file and initialize every 1000 lines
    if($count%10000 == 0){
        print OUT $text;
        $text = "";
    }

    #Add line number counts
    $count++;
}

#Write $text variable to the output file
print OUT $text;


print OUT "\n";;
print OUT "出力日時：$year年$mon月$mday日 $hour時$min分$sec秒";

########################################################################
#Subroutine
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
