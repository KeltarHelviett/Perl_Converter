use 5.14.2;
use warnings;
use Converter;

MarkdownToHTML('test.txt');
# open(my $fin, '<', 'test.txt');
# my $s = do {local $/; <$fin>};
# $s =~ s/(^|\n)(.+)\n[=]+(\n|$)/owo/g;
# my @arr = split //, $s;
# foreach (@arr) {
# 	# if ($_ eq "\n") {
# 	# 	say "WOW";
# 	# }
# 	print "$_";
# }