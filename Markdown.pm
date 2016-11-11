use 5.14.2;
use warnings;

my @toHTML = (
	sub { # header
		my $s = $_[0];
		$s =~ s/(#{1,6}) (.+?)(\s|$)#*/'<h' . length($1) . '>' . $2 . '<\/h' . length($1) . '>'/ge;
		$s =~ s/(^|\n)(.+?)\n[=]+(\n|$)/<h1>$2<\/h1>/g;
		$s =~ s/(^|\n)(.+?)\n[_]+(\n|$)/<h2>$2<\/h2>/g;
		return $s;	
	},
	sub { # paragraph
		my $s = $_[0];
		$s =~ s/(.*)\\(\s|$)/$1<br>/g;
		$s =~ s/\n\n(.+)(\n|$)/<p>$1<\/p>/g;
		return $s;
	},
	sub { # link
		my $s = $_[0];
		$s =~ s/[^!]\[(.*?)\](?!\s+)\((.*?)\)/<a href = $2>$1<\/a>/g;
		return $s;	
	},
	sub { # list
		my $s = $_[0];
		$s =~ s/(\*|-) (.*)($|\n)/<li>$2<\/li>/g;
		return $s;	
	},
	sub { # image
		my $s = $_[0];
		$s =~ s/!\[(.*?)\](?!\s+)\((.*?)\)/<p><img src=$2><\/p>/g;
		return $s;	
	},
	sub { # qoute
		my $s = $_[0];
		$s =~ s/> (.*?)($|\n)/<blockquote>$1<\/blockquote>/g;
		return $s;	
	},
	sub { # code
		my $s = $_[0];
		$s =~ s/`(.*)`/<code>$1<\/code>/g;
		# $s =~ s/(\n|^) {4}(.*)(\n|$)/<code>$1<\/code>/;
		return $s;
	}
	sub { # bold
		my $s = $_[0];
		$s =~ s/\*{2}(?!\s+)([^*]+?)(?!\s+)\*{2}/<strong>$1<\/strong>/g;
		$s =~ s/_{2}(?!\s+)([^*]+?)(?!\s+)_{2}/<strong>$1<\/strong>/g;
		return $s;
	},
	sub { # italic
		my $s = $_[0];
		$s =~ s/\*(?!\s+)([^*]+?)(?!\s+)\*/<em>$1<\/em>/g;
		$s =~ s/_(?!\s+)([^*]+?)(?!\s+)_/<em>$1<\/em>/g;
		return $s;
	},
);

sub MarkdownToHTML {
	open(my $fin, '<', $_[0]) or die "Motherfucker!";
	my $s = do {local $/; <$fin>};
	for my $i (0.. @toHTML - 1) {
		$s = $toHTML[$i]->($s);
	}
	close $fin;
	$/ = "\r\n";
	open(my $fout, '>', 'out.html') or die "Motherfucker!";
	print $fout $s;
	close $fout;
}

1;