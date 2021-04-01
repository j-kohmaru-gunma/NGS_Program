use File::Basename;
use FindBin;

#########################################################################################
#出力ファイルを開く
#########################################################################################
$dir = $FindBin::Bin;
mkdir "$dir/output";

open(OUT, ">$dir/output/TSS_count_result.txt");
open(OUT2, ">$dir/output/TSS_methyl_result.txt");

#########################################################################################
#TSS周辺のメチル化情報を順番に取得
#########################################################################################


#検索効率化のため、位置ごとにファイルポインターを作成
$chr = "";
$pos = 0;
$count = 0;
$tmp_pointer = 0;
open(IN, $ARGV[1]);
open(POINT, ">$dir/output/file_pointer.txt");
while (<IN>){

    #一行を取得
    $line = $_;
    @data = &getline($line);
    
    if($count%1000==0){
        print "$data[0]\t$data[1]\t$tmp_pointer\n";
        print POINT "$data[0]\t$data[1]\t$tmp_pointer\n";
    }
    
    $tmp_pointer = tell(IN);
    $count++;
}


#TSSごとのメチル化情報を抽出
print OUT "chr\tstart\tend\tstrand\ttranscript_id\tgene_id\t";
print OUT "D2(-)<-0.25\tD2(+)<-0.25\tD8(-)<-0.25\tD8(+)<-0.25\t";
print OUT "D2(-)<-0.5\tD2(+)<-0.5\tD8(-)<-0.5\tD8(+)<-0.5\n";

print OUT2 "chr\tstart\tend\tstrand\ttranscript_id\tgene_id\t";
print OUT2 "chr\tstart\tend\tD0\tD2(-)\tD8(-)\tD2(+)\tD8(+)\tdistance_from_TSS\n";

open(TSS, $ARGV[0]);
while (<TSS>){

    @diff = (0,0,0,0,0,0,0,0);

    #一行を取得
    $line = $_;
    print $line;
    @tssdata = &getline($line);

    #ストランドの向きによって、範囲を場合分けして、TSS上流1000bpの範囲を指定
    $chr = $tssdata[0];
    if($tssdata[3] eq "+"){
        $start = $tssdata[1] - 1000 - 1;
        $end = $tssdata[1] - 1;
    }else{
        $start = $tssdata[2];
        $end = $tssdata[2] + 1000;
    }
    
    #TSSの情報を一時保存、OUT2にのみ出力
    $tssinfo = "$chr\t".($start+1)."\t$end\t$tssdata[3]\t$tssdata[4]\t$tssdata[5]";
    print OUT "$tssinfo\t";

    #インプットファイルを、TSS近くのファイルポインターまで移動
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
    
    #一行ずつ場合わけして出力
    while(<IN>){
        
        #一行を取得
        $line = $_;
        @data = &getline($line);

        #解析範囲を超えていたら処理中断
        if(($chr eq $data[0] and $end < $data[1]) or $chr ne $data[0]){
            last;
        }
    
        #染色体が同じで解析範囲内であれば出力
        if($chr eq $data[0] and $start <= $data[1] and $end > $data[1]){
        
            if($tssdata[3] eq "+"){
                $dist = ($end - $data[1]);
            }else{
                $dist = ($data[1] - $start + 1);
            }
            
            print OUT2 "$tssinfo\t$data[0]\t".($data[1]+1)."\t".($data[2]+1)."\t$data[3]\t$data[4]\t$data[5]\t$data[6]\t$data[7]\t$dist\n";
            
            $tssinfo = "\t\t\t\t\t";
            
            #条件にあっていた場合、カウント
            if($data[4] - $data[3] >= 0.25){$diff[0]++;}   #D2(-)
            if($data[5] - $data[3] >= 0.25){$diff[1]++;}   #D8(-)
            if($data[6] - $data[3] >= 0.25){$diff[2]++;}   #D2(+)
            if($data[7] - $data[3] >= 0.25){$diff[3]++;}   #D8(+)
            if($data[4] - $data[3] >= 0.5){$diff[4]++;}   #D2(-)
            if($data[5] - $data[3] >= 0.5){$diff[5]++;}   #D8(-)
            if($data[6] - $data[3] >= 0.5){$diff[6]++;}   #D2(+)
            if($data[7] - $data[3] >= 0.5){$diff[7]++;}   #D8(+)
            
        }
    
    }
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
#サブルーチン
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}