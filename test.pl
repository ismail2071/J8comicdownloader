use LWP::Simple;
use Cwd;
use Encode qw/encode decode/;

#	my $oriStr="comic_title: �i�������H 1 - 57 �i�������H���e�u�W�[�� �L���ʺ� 8comic.com";
#	$oriStr =~ /.*comic_title: (.*)���e�u�W�[��.*/;
#	print $1;

$str="comic_title: �i�������H 1 - 57 �i�������H���e�u�W�[�� �L���ʺ� 8comic.com";
$str =~ /(.*)\Q���e�u�W�[��\E.*/; 
print $&,"\n"; # brand names and product names 
print $1,"\n";  # brand 
print $2,"\n";  # product