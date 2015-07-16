use strict;
use 5.10.0;
undef $/;

my ($fn) = @ARGV;
my $f = <>;
$f =~ s|http://[a-zA-Z.]*/pubmed/([0-9]*)\S*|PMID:$1 |g;
$f =~ s/\[?PMID:\s*([0-9]+)\]?/[RXREF:$1.pm]/g;

print $f;
