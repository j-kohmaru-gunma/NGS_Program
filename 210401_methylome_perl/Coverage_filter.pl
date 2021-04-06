#（使用法）#(How to use)###########################################################
#perl Coverage_filter_200929.pl -max <Max Coverage> -min <min coverage> -c <Coverage._File_list.txt>  -i <Input_File_list.txt> -o <Output name>

#（モジュールの読込）#(Loading mudules)###########################################################
use Getopt::Long;           #コマンドラインオプション用#小松編集テスト#For command line options
use FindBin;
use List::Util qw(max min);

#（引数読込）#(Loading arguments)###########################################################
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

#（ファイルを開く）#(Open files)###########################################################
open(INPUT, $inputfile);       #メチル化率bdgファイル#a bdg file for methylaton levels
open(COV, $covfile);    #遺伝子情報記述bedファイル#a bed file for gene location

#インプットファイルの読込#Loading a methylation level file
print "input file\n";
@in_arr=();
while(<INPUT>){
    $line = $_;
    print $line;
    $line =~ s/(\r\n|\r|\n)$//g;
    push(@in_arr,$line);
}
print "\n";

#カバレッジファイルの読込#Loading a coverage file
print "coverage file\n";
@cov_arr=();
while(<COV>){
    $line = $_;
    print $line;
    $line =~ s/(\r\n|\r|\n)$//g;
    push(@cov_arr,$line);
}
print "\n";

#読み込んだファイルの行数が一致しているかチェック#Check if the numbers of lines are consistent both in methylation level and coverage files
$inlen = @in_arr;
$covlen = @cov_arr;
if($inlen  != $covlen){
    print "Error:インプットファイルの個数とカバレッジファイルの個数が一致しませんinconsistency in line numbers\n";
    print "$inlen\t!=\t$covlen\n";
    exit(0);
}

#個別のファイルを開く#Open methylation level and coverage files
for($i=0;$i<@in_arr;$i++){
    $hdl = "IN".$i;
    open($hdl, $in_arr[$i]);
}
for($i=0;$i<@cov_arr;$i++){
    $hdl = "COV".$i;
    open($hdl, $cov_arr[$i]);
}

#出力先ファイルを開く#Open an output file
open(OUT, ">".$outputname);

#while処理用のダミーとして、ファイルを開く
open(DUM, $in_arr[0]);

#「カバレッジが指定範囲内のときのみ出力」#(Output only when coverage is within a specified range)###########################################################

$count=0;
$text = "";

while (<DUM>){

    #各ファイルから一行分のデータを取得#Extract one line from each file
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
    
    #条件に一致した場合だけ出力待ち変数に保存
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

    #1000行ごとに出力して、出力待ち変数をリセット
    if($count%10000 == 0){
        #print "$data[0]\t$data[1]\t$data[2]\n";
        print OUT $text;
        $text = "";
    }

    #行数カウント追加#Add line number counts
    $count++;
}

#出力待ち変数に残っているデータも出力
print OUT $text;

########################################################################
#サブルーチン#Subroutine
########################################################################
sub getline{
    ($x) = @_;
    $line = $x;
    $line =~ s/(\r\n|\r|\n)$//g;
    return split(/\t/, $line);
}
