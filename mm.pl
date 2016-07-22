use strict;

undef $/;

my $f = <>;

$f =~ s/.*<pre>//s;
$f =~ s|</pre>.*||s;
$f =~ s/\n([A-Z][A-Z0-9]*)\s*-\s*/%FIELD%$1: /g;

my %rec;

foreach (split /%FIELD%/, $f){
	s/\s+/ /g;
	# print "Field: $_\n";
	next unless my($key, $field) = /^([A-Z][A-Z0-9]*): (.*)/;
	push @{$rec{$key}}, $field;
}

my $tag = substr($rec{AU}->[0], 0, 4);
$tag .= substr($rec{AU}->[1], 0, 4) if defined($rec{AU}->[1]);
$tag =~ s/[, ]*//g; # Removing trailing stuff from short author names
$tag =~ s/'/_/g; # Apostrophes choke bibtexml (and maybe others)
$tag .= substr($rec{DP}->[0], 2, 2);
$rec{TAG} = [$tag];

foreach (sort keys %rec){
	print "$_: ";
	print join " #AND# ", @{$rec{$_}};
	print "\n";
}

