#!/usr/bin/env perl
#
#	Extract GFF3 features for given gene-mRNA query file from GFF3 file
#
# v0.2 update
# - Adding the functionality that if there is two "gene" features in the query only the first occurance is printed
#
# AUTHOR:Gemy George Kaithakottil (gemy.kaithakottil@tgac.ac.uk || gemygk@gmail.com)

use strict;
use warnings;
use File::Basename;
my $prog = basename($0);

my $usage = "
	Extract GFF3 features for given gene->mRNA [match->match_part] query file from GFF3 file

	Usage: perl $prog <id.txt[/path/to/id.txt]> <file.gff3[/path/to/file.gff3]>

	Note: The id.txt should be tab delimited

	# id.txt file - the first field MUST be gene_ID and the second field MUST
	be transcript ID, anything else from 3rd column is ignored

	Eg id.txt file:
	#   [gene|match]                  [mRNA|transcript|match_part]
	S3_CUFF.10004.1|g.145776	S3_CUFF.10004.1|m.145776	3931
	S3_CUFF.10008.1|g.145810	S3_CUFF.10008.1|m.145810	423
	MYZPE13503_v1.4_0000020	MYZPE13503_v1.4_0000020.1       1338    0       0.00000
	MYZPE13503_v1.4_0000020	MYZPE13503_v1.4_0000020.2       1338    0       0.00000
	MYZPE13503_v1.4_0000030	MYZPE13503_v1.4_0000030.1       4338    0       0.00000

	# v0.2 update
	# - Adding the functionality that if there is two \"gene\" features for same mRNA in the 
	GFF3 only the first occurance is printed

Contact:Gemy.Kaithakottil\@tgac.ac.uk || gemygk\@gmail.com
\n";

my $id = shift or die $usage;
my $gff = shift or die $usage;

# Link the files:
my @id_path = split /\//, $id;
my @gff_path = split /\//, $gff;
my $idName = $id_path[$#id_path];
my $gffName = $gff_path[$#gff_path];
system("ln -s $id") unless (-e $idName);
system("ln -s $gff") unless (-e $gffName);

#open(ID ,"<", $id) | die "Cannot open $id file:$!\n";
open(ID ,"$id") || die "Cannot open $id file:$!\n";
my %gene_hash=();
my %mrna_hash=();

# ID file
while (<ID>) {
    next if (/^\#/); # Remove comments from $_.
    next unless /\S/; # \S matches non-whitespace.  If not found in $_, skip to next line.
	chomp;
	my @l = split (/\t/);
	# Get the gene ID to hash
	unless(exists($gene_hash{$l[0]})) {
		$gene_hash{$l[0]} +=1;
	}
	# Get the mRNA ID to hash
	unless(exists($mrna_hash{$l[1]})) {
		$mrna_hash{$l[1]} +=1;
	}
}
close(ID);

# GFF3 file
#open(FILE,"<", $gff) or die "Cannot open $gff file:$!";
open(FILE,$gff) or die "Cannot open $gff file:$!";
while (<FILE>) {
    next if (/^\#/); # Remove comments from $_.
    next unless /\S/; # \S matches non-whitespace.  If not found in $_, skip to next line.
	chomp;
	my @f = split (/\t/);
	# extract gene lines from GFF3 if present in ID file
	if($f[2] eq "gene" || $f[2] eq "match")	{
		my ($gene_id) = $f[8] =~ /ID\s*=\s*([^;]+)/;
		$gene_id =~ s/\s+$//;
		if (exists $gene_hash{$gene_id}) {
			print "$_\n";
			delete $gene_hash{$gene_id};	# v0.2 update
		}
	}
	# extract mRNA lines from GFF3 if present in ID file
	elsif ($f[2] eq "mRNA" || $f[2] eq "transcript" || $f[2] eq "match_part") {
		my ($mrna_id) = $f[8] =~ /ID\s*=\s*([^;]+)/;
		$mrna_id =~ s/\s+$//;
		if (exists $mrna_hash{$mrna_id}) {
			print "$_\n";
		}
	}
	# extract rest lines from GFF3 if present in ID file
	else {
		if ($f[8] =~ /Parent\s*=\s*([^;]+)/) {
			my ($rest_id) = $f[8] =~ /Parent\s*=\s*([^;]+)/;
			$rest_id =~ s/\s+$//;
			if (exists $mrna_hash{$rest_id}) {
				print "$_\n";
			}
		}
	}
}
close(FILE);
exit;

