use File::Basename;
use FindBin;
@datalist = [];

open(TSS, $ARGV[0]);
#########################################################################################
#TSS周辺のメチル化情報を順番に取得
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

        #一行を取得して、配列としてdata変数に格納
        $line = $_;
        @tssdata = &getline($line);
        $chr = $tssdata[0];
        $strand = $tssdata[3];

        #ストランドの向きによって、範囲を場合分けして指定
        if($strand eq "+"){
            $start = $tssdata[1] - 1000 - 1;
            $end = $tssdata[1] - 1;
        }elsif($strand eq "-"){
            $start = $tssdata[2];
            $end = $tssdata[2] + 1000;
        }

        #LAMDA,randomeは飛ばす
        if($chr =~ /random$/ or $chr =~ /^LAMDA/){
            next;
        }
        
        #検索
        seek(DATA,$pointer,0);
        while (<DATA>){
            #一行を取得
            $line = $_;
            @data = &getline($line);
        
            #場合わけ
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
#サブルーチン
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
