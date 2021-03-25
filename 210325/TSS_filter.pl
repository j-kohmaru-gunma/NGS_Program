#########################################################################################
# Module
#########################################################################################
use File::Basename;
use FindBin;

#########################################################################################
# Main
#########################################################################################

@datalist = [];

open(TSS, $ARGV[0]);

for($i=1;$i<@ARGV;$i++){

    $name = basename($ARGV[$i],'.bedGraph');
    $dir = $FindBin::Bin;

    open(DATA, $ARGV[$i]);
    
    open(OUT, ">".$dir."/".$name.".tss±1000.bdg.txt");

    $count = 0;
    $text = "";
    $pointer=0;

    seek(TSS,0,0);
    while (<TSS>){

        $line = $_;
        @tssdata = &getline($line);
        $chr = $tssdata[0];
        $strand = $tssdata[3];

        if($strand eq "+"){
            $start = $tssdata[1] - 1000 - 1;
            $end = $tssdata[1] - 1;
        }elsif($strand eq "-"){
            $start = $tssdata[2];
            $end = $tssdata[2] + 1000;
        }

        if($chr =~ /random$/ or $chr =~ /^LAMDA/){
            next;
        }


        seek(DATA,$pointer,0);
        while (<DATA>){
            $line = $_;
            @data = &getline($line);

            if($data[0] eq $chr and $data[1] >= $start and $data[1] < $end){
                print OUT $line."\n";

            }elsif($data[0] eq $chr and $data[1] >= $end){
                last;
            }
            $pointer = tell(DATA);
        }
    }
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
