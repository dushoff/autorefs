use strict;
use 5.10.0;
undef $/;

my $base = '$(bib)/';

my $f = <>;

my %rx;

# Find unique PMIDs
foreach ($f =~ /\[RXREF:([^\]]*)\]/g){
	$rx{$_}=1;
}

my @stems = sort keys %rx;
@stems = grep {s/^/$base/} @stems;

say "refrec: " .  join ".refrec ", @stems, "";
