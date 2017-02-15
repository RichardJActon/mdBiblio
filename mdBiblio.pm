package mdBiblio;
use warnings;
use strict;

sub CITATION_STRING # APA - mybib.bib
{
	my %hashName = %{$_[0]};
	my $k = $_[1];
	my $string = $hashName{$k}{"author"} .
	" (". $hashName{$k}{"year"} ."). ".
	"*". $hashName{$k}{"title"}.".* ".
	$hashName{$k}{"journal"}.", ".
	"V(".$hashName{$k}{"volume"} .")".
	"\n\n";
	return $string;
}

1;