use LWP::Simple;
use Cwd;
use Encode qw/encode decode/;

#	my $oriStr="comic_title: 進擊的巨人 1 - 57 進擊的巨人漫畫線上觀看 無限動漫 8comic.com";
#	$oriStr =~ /.*comic_title: (.*)漫畫線上觀看.*/;
#	print $1;

$str="comic_title: 進擊的巨人 1 - 57 進擊的巨人漫畫線上觀看 無限動漫 8comic.com";
$str =~ /(.*)\Q漫畫線上觀看\E.*/; 
print $&,"\n"; # brand names and product names 
print $1,"\n";  # brand 
print $2,"\n";  # product