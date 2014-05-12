use LWP::Simple;
use Cwd;
use Encode qw/encode decode/;

## Read parameters from the config file
&parse_config_file ("app.ini", \%Config);


my $pwd = getdcwd();
my $phantomjsExePath = "$pwd\\phantomjs.exe";
my $jsPath = "$pwd\\examples\\8comic.js";
my $savePath = $Config{savePath};

my $webContent ="";
print "input website:";
my $website = <STDIN>;




$webContent= `$phantomjsExePath $jsPath $website`;
$webContent=Encode::encode("big5", decode("utf-8", $webContent));
my @line = split('\n', $webContent);
my @volumnInfo;  undef (@volumnInfo);
my $title="";
my $currentVol ="";
my $totalVol="";
foreach my $tmpLine (@line)
{
	
	if( $tmpLine =~/comic_title: /)
	{
		my $text = extractStrFromTwoStr($tmpLine,"comic_title: ", "漫畫線上觀看" );
		@volumnInfo = get8comicVolumnInfo($text);
		
		$title = trim($volumnInfo[0]);
		$ca=is_utf8($title)?"UTF-8":"ASCII";
		print $ca;
		$currentVol = $volumnInfo[1];
		$totalVol = $volumnInfo[2];
		last;
	}
	
}
#$title2 =Encode::encode("big5", decode("utf-8", $title));

print "Title: $title";
print "(目前集數/全集數): ($volumnInfo[1]/$volumnInfo[2])";


my $totalPage ="";
mkdir("$savePath\\$title");
print "folder: $savePath\\$title\n";

for($i=$currentVol; $i <=$totalVol; $i++)
{
	print "Current Vol: $i\n";
	mkdir("$savePath\\$title\\$i");
	my $folderPath = "$savePath\\$title\\$i";

	## 1. get total pages for i-th vol
	my $volWebSite = generateMultiWebSites($i,"");
	my $webContent= `$phantomjsExePath $jsPath $volWebSite`;
	my @line = split('\n', $webContent);
	foreach my $tmpLine (@line)
	{

		if($tmpLine =~/id=\"pagenum\">第/)
		{
			my $text = extractStrFromTwoStr($tmpLine,"id=\"pagenum\">第", "頁" );
			@pageInfo = get8comicPageInfo($text);
			$totalPage = $pageInfo[1];
			last;
		}
	}
	
	
	## 2. parse img path for each pages
	for ($j=1;$j<=$totalPage;$j++)
	{
		my $volWebSite = generateMultiWebSites($i,$j);
		my $webContent= `$phantomjsExePath $jsPath $volWebSite`;
		my @line = split('\n', $webContent);
		my $imgLink="";
		foreach my $tmpLine (@line)
		{
			if($tmpLine =~/id="TheImg" src="/)
			{
				my $text = extractStrFromTwoStr($tmpLine,"id=\"TheImg\" src=\"", ".jpg\"" );
				$imgLink = $text.".jpg";
				last;
			}
		}
		
		my $page = sprintf ("%03d",$j);
		my $filePath = $folderPath."\\$page".".jpg";
		print "imgLink: $imgLink, filePath: $filePath\n";
#		saveFileToFolder($imgLink, $filePath);
		
	}
	
}



open (MYFILE, '>data.txt'); 
#print MYFILE "realTitle: $realTitle\n";
#print MYFILE "$webContent\n"; 
#print MYFILE "Title: $volumnInfo[0]";
#print MYFILE "(目前集數/全集數): ($volumnInfo[1]/$volumnInfo[2])";


close (MYFILE); 



sub extractStrFromTwoStr
{
	my ($oriStr, $strA, $strB) = @_;
	print $oriStr,$strA, $strB;
	#my $lastIndexStrA = index($oriStr, $strA)+length($strA);
	$oriStr =~m/.*\Q$strA\E(.*)\Q$strB\E.*/;
	print $1;
	#my $returnStr = substr($oriStr, $lastIndexStrA , index($oriStr, $strB)-$lastIndexStrA  );
	return $1;
}

sub get8comicVolumnInfo
{
	my ($titleStr) = @_;
	my @volumnInfo; undef (@volumnInfo);
	
	$titleStr =~m/(.*)(\d+) - (\d+) .*/;

	push @volumnInfo, $1 ;
	push @volumnInfo, $2 ;
	push @volumnInfo, $3 ;

	return @volumnInfo;
}

sub get8comicPageInfo
{
	my ($pageStr) = @_;
	my @pageInfo; undef (@pageInfo);
	
	$pageStr =~m/(\d+)\/(\d+)/;

	push @pageInfo, $1 ;
	push @pageInfo, $2 ;
	return @pageInfo;
}

sub generateMultiWebSites
{
	my ($vol, $page) = @_;
	#http://new.comicvip.com/show/best-manga-10617.html?ch=1
	my $returnWebStr="";
	$website =~m/(.*ch=).*/;
	$returnWebStr = $1.$vol;
	if($page ne "")
	{
		$returnWebStr = $returnWebStr."-".$page;
	}
	return $returnWebStr;
}



sub saveFileToFolder
{
	my ($url, $filePath) = @_;
	getstore($url, $filePath);
}




sub parse_config_file {
	
    local ($config_line, $Name, $Value, $Config);

    ($File, $Config) = @_;

    if (!open (CONFIG, "$File")) {
        print "ERROR: Config file not found : $File";
        exit(0);
    }
	
    while (<CONFIG>) {
        $config_line=$_;
        trim($config_line);          # Get rid of the trailling \n
        $config_line =~ s/^\s*//;     # Remove spaces at the start of the line
        $config_line =~ s/\s*$//;     # Remove spaces at the end of the line
        if ( ($config_line !~ /^#/) && ($config_line ne "") ){    # Ignore lines starting with # and blank lines
            ($Name, $Value) = split (/=/, $config_line);          # Split each line into name value pairs
            $Config{$Name} = $Value;                             # Create a hash of the name value pairs
        }
		#print "File: $File\n";
    }

    close(CONFIG);

}





sub trim($)  
{  
    my $string = shift;  
    $string =~ s/^\s+//;  
    $string =~ s/\s+$//;  
    return $string;  
}   


sub is_utf8 {
  local($p_string) = @_;
 
	#From http://w3.org/International/questions/qa-forms-utf-8.html
	# It will return true if $p_string is UTF-8, and false otherwise.
	return($p_string =~ m/\A(
     [\x09\x0A\x0D\x20-\x7E]            # ASCII
   | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
   |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
   | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
   |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
   |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
   | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
   |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
  )*\z/x);
}