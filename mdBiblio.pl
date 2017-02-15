#!/usr/bin/perl

# dealing with code blocks  ~ if ``` next until ```?
# bibtex file parse
# style file

use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;
use mdBiblio;

my $bibliograhy;
my $refTitle = "";
GetOptions(
	"bibliograhy=s" => \$bibliograhy,
	"refTitle:s" => \$refTitle
	);# or die "Options error \n$!";


# read markdown file to array
my @lines;
while (my $line = <>) 
{
	push @lines, $line;
	# # Debugging
	# print STDERR $line;
}

# get references
my @refTags;
my @refLabels;
for (my $i = 0; $i < scalar @lines; $i++) 
{
	if ($lines[$i] =~ /\[(.*)\]\[(.*)\]/) 
	{
		push @refLabels, $1;
		push @refTags, $2;
		# # Debugging
		# print STDERR $1;
	}
}

# bibtex processing
# red file to string 
my $bibtex;
open(BIB,"<$bibliograhy") or die "unable to open $bibliograhy\n$!";
while (my $bib = <BIB>) 
{
	chomp $bib;
	$bibtex .= $bib;
}
close(BIB) or die "unable to close $bibliograhy\n$!";
#print STDERR $bibtex;

# get entries from file 
my @bibtexTypes = $bibtex =~ /(@\w+\{(?:(?!\},*\}).)*\},*\})/g;
#print STDERR Dumper @bibtexTypes;

my %bibtexKeys;
for (my $i = 0; $i < scalar @bibtexTypes; $i++) 
{
	my %tags = $bibtexTypes[$i] =~ /(?:,(\w+)\s*=\s*)(?|(?:(?:[\{|"])([^\}|"]+))|(?:(\d+)))/g; 
	if ($bibtexTypes[$i] =~ /@(\w+)\{(\w+),/) 
	{
		$tags{"type"} = $1;
		$bibtexKeys{$2} = \%tags;
	}
}

if ($refTitle eq "")
{
	push @lines, "\n# References\n";
	$refTitle = "# References";
}

# print output
# lines up to refTitle
my $lnum = 0;
my $max = scalar @lines;
while ($lnum < $max) 
{	
	if ($lines[$lnum] =~ /```/) # ignore the contents of code blocks
	{
		until ($lines[$lnum] =~ /```/){$lnum++}
	}
	if ($lines[$lnum] =~ /${refTitle}/) 
	{
		print STDOUT $lines[$lnum];
		$max = $lnum;
	}
	else
	{
		print STDOUT $lines[$lnum];
		$lnum++;	
	}
}

# print STDERR Dumper %bibtexKeys;

for (my $i = 0; $i < scalar @refTags; $i++) 
{
	foreach my $k (keys %bibtexKeys)
	{
		if ($k eq $refTags[$i])
		{
			#print STDOUT Dumper $v;
			if ($bibtexKeys{$k}{"type"} eq "article") 
			{
				my $citation = mdBiblio::CITATION_STRING(\%bibtexKeys,$k);
				print STDOUT "###### $refLabels[$i]\n [$k]: #$refLabels[$i]\n __".$refLabels[$i]."__ - $citation";
			}
		}
	}
}

$lnum++;
while ($lnum < scalar @lines) 
{
	if ($lines[$lnum] =~ /```/) # ignore the contents of code blocks
	{
		until ($lines[$lnum] =~ /```/){$lnum++}
	}
	print STDOUT $lines[$lnum];
	$lnum++;
}
print STDOUT "\n";
#print STDERR "WARNING $refTags[$i] is not in your bibliography file!\n";