use File::Basename;
use FindBin;
@datalist = [];

open(TSS, $ARGV[0]);
#########################################################################################
# Extract methylation levels and read depth for individual CpGs located within 1kb upstream regions from all TSSs on the genome
#########################################################################################

for($i=1;$i<@ARGV;$i++){

    $name = basename($ARGV[$i],'.bedGraph');
    $dir = $FindBin::Bin;

    open(DATA, $ARGV[$i]);
    
    mkdir $dir."/output"; 
    open(OUT, ">".$dir."/output/".$name.".tss±1000.bdg.txt");

    $count = 0;
    $text = "";
    $pointer=0;
    
    seek(TSS,0,0);
    while (<TSS>){

        #Read one line from bdg file and get chromosome number & strand data
        $line = $_;
        @tssdata = &getline($line);
        $chr = $tssdata[0];
        $strand = $tssdata[3];

        #Specify a 1kb upstream region from TSS based on strandness of a gene
        if($strand eq "+"){
            $start = $tssdata[1] - 1000 - 1;
            $end = $tssdata[1] - 1;
        }elsif($strand eq "-"){
            $start = $tssdata[2];
            $end = $tssdata[2] + 1000;
        }

        #Skip chrN_random and LAMBDA
        if($chr =~ /random$/ or $chr =~ /^LAMBDA/){
            next;
        }
        
        #Search and output data within 1kb upstream regions from TSS
        seek(DATA,$pointer,0);
        $flg=0;
        while (<DATA>){
            $line = $_;
            @data = &getline($line);
        
            if($data[0] eq $chr and $data[1] >= $start and $data[1] < $end){
                $flg=1;
                $text .= $line."\n";

            }elsif($data[0] eq $chr and $data[1] >= $end){
                last;
                
            }elsif($flg==1){
                last;
                
            }elsif($data[0] gt $chr){
                last;
            }
            
            $pointer = tell(DATA);
        }
        if($count%1000==0){
            print $line."\n";
            print OUT $text;
            $text = "";
        }
    }
    print OUT $text;
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
