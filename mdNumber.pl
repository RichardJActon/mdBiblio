#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;

my $toc = 0;
my $title = "";
my $width = 50;
GetOptions(
	"contents" => \$toc,
	"title=s" => \$title,
	"width=i" => \$width
	);# or die "Options error \n$!";

# read markdown file to array
my @lines;
while (my $line = <>) 
{
	push @lines, $line;
	# # Debugging
	# print STDERR $line;
}
# my $linesString;
# for (my $i = 0; $i < scalar @lines; $i++) 
# {
# 	$linesString .= $lines[$i];
# }

my %contents;
	
my $h1 = 0;
my $h2 = 0;
my $h3 = 0;
my $h4 = 0;
my $h5 = 0;
my $h6 = 0;

for (my $i = 0; $i < scalar @lines; $i++) 
{
	if ($lines[$i] =~ /```/) # ignore the contents of code blocks
	{
		$i++;
		until ($lines[$i] =~ /```/){$i++}
	}
	elsif ($lines[$i] =~ /^#\s/ ) # ``` $i++ until ```
	{
		my $line = $lines[$i];
		$h1++;
		$line =~ s/^#\s/# ${h1} /;
		$h2 = 0;
		$contents{$line} = $lines[$i];
		$lines[$i] = $line; 
	}
	elsif ($lines[$i] =~ /^##\s/ ) 
	{
		my $line = $lines[$i];
		#my $sub = ($h1-1);
		$h2++;
		$line =~ s/^##\s/## ${h1}\.${h2} /;
		$h3 = 0;
		$contents{$line} = $lines[$i];
		$lines[$i] = $line; 
	}
	elsif ($lines[$i] =~ /^###\s/ ) 
	{
		my $line = $lines[$i];
		$h3++;
		$line =~ s/^###\s/### ${h1}\.${h2}\.${h3} /;
		$h4 = 0;
		$contents{$line} = $lines[$i];
		$lines[$i] = $line; 
	}
	elsif ($lines[$i] =~ /^####\s/ ) 
	{
		my $line = $lines[$i];
		$h4++;
		$line =~ s/^####\s/#### ${h1}\.${h2}\.${h3}\.${h4} /;
		$h5 = 0;
		$contents{$line} = $lines[$i];
		$lines[$i] = $line
	}
	elsif ($lines[$i] =~ /^#####\s/ ) 
	{
		my $line = $lines[$i];
		$h5++;
		$line =~ s/^#####\s/##### ${h1}\.${h2}\.${h3}\.${h4}\.${h5} /;
		$h6 = 0;
		$contents{$line} = $lines[$i];
		$lines[$i] = $line; 
	}
	elsif ($lines[$i] =~ /^######\s/ ) 
	{
		my $line = $lines[$i];
		$h6++;
		$line =~ s/^######\s/###### ${h1}\.${h2}\.${h3}\.${h4}\.${h5}\.${h6} /;
		$contents{$line} = $lines[$i];
		$lines[$i] = $line; 
	}
}

my %contents2;
while (my($k,$v) = each %contents) 
{
	my $key = $k;
	$key =~ /#\s(\d+[\.|\d+]*)/;
	$key = $1;
	my $val = $v;
	$val =~ /#\s(.*)/;
	$val = $1;
	$contents2{$key} = $val;
}

# for (my $i = 0; $i < scalar @lines; $i++) 
# {
# 	print STDOUT $lines[$i];
# }



#print STDERR Dumper %contents2;

#########################
# print output
# lines up to refTitle
if ($toc == 1 && $title eq "")
{
	unshift @lines, "# Contents\n";
	$title = "# Contents";
}

my $lnum = 0;
my $max = scalar @lines;
while ($lnum < $max) 
{	
	if ($lines[$lnum] =~ /```/) # ignore the contents of code blocks
	{
		until ($lines[$lnum] =~ /```/){$lnum++}
	}
	if ($lines[$lnum] =~ /${title}/) 
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

if ($toc == 1 || $title ne "")
{
	my @contentsLines;
	foreach my $key (sort keys %contents2)
	{
		my $heading = $contents2{$key};
		$heading =~ s/(\w+)/lc($1)/ge;
		$heading =~ s/\s+|[\u2000-\u206F\u2E00-\u2E7F\\'!"#$%&()*+,\-.\/:;<=>?@\[\]^_`{|}~]+//g; # strip punctuation
		push @contentsLines, "- $key - $heading\n";
		my $keyLen = length($key);
		my $titleLen = length($contents2{$key});
		my $cLen = $keyLen + $titleLen;
		my $re = $width - $cLen - 3;
		print STDOUT "$key...";
		for (my $i = 0; $i < $re; $i++) 
		{
			print STDOUT "."
		}
		#printf STDOUT "%-50s", $heading;
		print "[$contents2{$key}][./#$heading]";
		print STDOUT "\n"; 
	}
}

# for (my $i = 0; $i < scalar @contentsLines; $i++) 
# {
# 	printf STDOUT  '%12s' , $contentsLines[$i];
# }


print STDOUT "\n";
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
