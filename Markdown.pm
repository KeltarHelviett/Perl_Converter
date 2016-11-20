use 5.14.2;	
use warnings;

my $parseList = sub {
	my $s = shift;
	my @lines = split /\n/, $s;
	my ($nestingLvl, @nesting, $closed) = -1;
	foreach my $line (@lines) {
		if ($line =~ m/( +)(\*|-) (.*)($|\n)/g) {
			$closed = undef;
			my $spaces = length $1;
			my ($ul, $_ul) = (0, 0);
			if ($nestingLvl < $spaces) {
				$nestingLvl = $spaces;
				push @nesting, $nestingLvl;
				$ul = 1;
			}
			elsif ($nestingLvl > $spaces) {
				$nestingLvl = $spaces;
				pop(@nesting);
				$_ul = 1;
				$_ul++ while pop(@nesting) != $nestingLvl;
				push @nesting, $spaces;
			}
			$line =~ s/(\*|-) (.*)($|\n)/<li>$2<\/li>/;
			$line = ('<ul>' x $ul) . ('</ul>' x $_ul) . $line;
		}
		else {
			if (!$closed) {
				$line = '</ul>' . $line;
				$closed = 1;
			}
		}
	}
	push @lines, '</ul>' if !$closed;
	return join("\n", @lines);
};

my @toHTML = (
	sub { # qoute
		my $s = $_[0];
		$s =~ s/> (.*?)($|\n)/<blockquote>$1<\/blockquote>/g;
		open(my $tmp, '>', 'qoute.html');
		return $s;	
	},
	sub { # header
		my $s = $_[0];
		$s =~ s/(#{1,6}) (.+?)(\s|$)#{0,6}/'<h' . length($1) . '>' . $2 . '<\/h' . length($1) . '>'/ge;
		$s =~ s/(^|\n)(.+?)\n[=]+(\n|$)/<h1>$2<\/h1>/g;
		$s =~ s/(^|\n)(.+?)\n[_]+(\n|$)/<h2>$2<\/h2>/g;
		open(my $tmp, '>', 'head.html');
		return $s;	
	},
	sub { # paragraph
		my $s = $_[0];
		$s =~ s/(.*)\\(\s|$)/$1<br>/g;
		# $s =~ s/\n\n(.+)(\n|$)/<p>$1<\/p>/g;
		open(my $tmp, '>', 'paragraph.html');
		return $s;
	},
	sub { # link
		my $s = $_[0];
		$s =~ s/[^!]?\[(.*)\](?!\s+)\((.*?)\)/ <a href=$2>$1<\/a>/g;
		open(my $tmp, '>', 'link.html');
		return $s;	
	},
	sub { # list
		my $s = $_[0];
		return $parseList->($s) if  $s =~ m/(\*|-) (.*)($|\n)/g;
		open(my $tmp, '>', 'list.html');
		return $s;	
	},
	sub { # image
		my $s = shift;
		$s =~ s/!\[(.*?)\](?!\s+)\((.*?)\)/<p><img src=$2><\/p>/g;
		open(my $tmp, '>', 'image.html');
		return $s;	
	},
	sub { # code
		my $s = $_[0];
		$s =~ s/`(.+?)(?=`)/<code>$1<\/code>/g;
		open(my $tmp, '>', 'code.html');
		return $s;
	},
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
	}
);

sub MarkdownToHTML {
	open(my $fin, '<', $_[0]) or die "Can't open file $!";
	my $s = do {local $/; <$fin>};
	my @p = split /\n\n/, $s;
	for my $i (0..@p - 1) {
		for my $j (0..@toHTML - 1) {
			$p[$i] = $toHTML[$j]($p[$i]);
		}
	}
	close $fin;
	$/ = "\r\n";
	open(my $fout, '>', 'out.html') or die "Can't open file $!";
	print $fout "<p>$_</p>" foreach (@p) ;
	close $fout;
}

1;