use strict;
use 5.10.0;
undef $/;

my $base = '$(bib)/';

my $f = <>;

my %rx;

# Find unique RXREFs
foreach ($f =~ /\[RXPOINT:([^=]*)=([^\]]*)\]/g){
	$rx{$1}=$2;
}

while (my ($key, $val) = each %rx){
	say "$key=$val";
}

