#!/usr/bin/env perl
#
#	Extract GFF3 features for given gene-mRNA query file from GFF3 file
#
# AUTHOR:Gemy George Kaithakottil (gemy.kaithakottil@tgac.ac.uk || gemygk@gmail.com)

use strict;
use warnings;

my $usage = "
Extract GFF3 features for given gene-mRNA query file from GFF3 file

Usage: perl $0 <id.txt> <file.gff3>

Note: The id.txt should be tab delimited

# id.txt file--- the first field MUST be gene_ID and the second field MUST be transcript ID, anything else from 3rd column is ignored

Eg id.txt file
# For transdecdoder GFF file
#           #Gene_ID                      #mRNA_ID/transcript_ID
INRA_S3_CUFF.10004.1|g.145776	INRA_S3_CUFF.10004.1|m.145776	3931
INRA_S3_CUFF.10008.1|g.145810	INRA_S3_CUFF.10008.1|m.145810	423
# For augustus GFF file
#      #Gene_ID         #mRNA_ID/transcript_ID
MYZPE13503_v1.4_0000020	MYZPE13503_v1.4_0000020.1       1338    0       0.00000
MYZPE13503_v1.4_0000020	MYZPE13503_v1.4_0000020.2       1338    0       0.00000
MYZPE13503_v1.4_0000030	MYZPE13503_v1.4_0000030.1       4338    0       0.00000

\n";

my $id = shift or die $usage;
my $transcripts = shift or die $usage;

# ID file--- the first field MUST be gene_ID and the second field MUST be transcript ID, following by anything is fine

# For transdecdoder GFF file
#INRA_S3_CUFF.10004.1|g.145776	INRA_S3_CUFF.10004.1|m.145776	3931	3931	100.00000	3584	91.17273	0	0.00000	347	8.82727	347	8.82727
#INRA_S3_CUFF.10008.1|g.145810	INRA_S3_CUFF.10008.1|m.145810	423	423	100.00000	413	97.63593	0	0.00000	10	2.36407	10	2.36407

# For augustus GFF file
# MYZPE13503_v1.4_0000020	MYZPE13503_v1.4_0000020.1       1338    0       0.00000 -- for augustus

#open(ID ,"<", $id) || die "Cannot open $id\n";
open(ID ,$id) || die "Cannot open $id\n";
my %gene_hash=();
my %mrna_hash=();

#first file
while (<ID>) {
	s/#.*//; # Remove comments from $_.
    next unless /\S/; # \S matches non-whitespace.  If not found in $_, skip to next line.
	chomp;
	my @l = split (/\t/); # split $_ at tabs separating fields.

	# Get the gene ID to hash
	unless(exists($gene_hash{$l[0]})) {

		# copy ID to gene_hash
		$gene_hash{$l[0]} +=1;
		#print "$l[0]\n";
	}
	# Get the mRNA ID to hash
	unless(exists($mrna_hash{$l[1]})) {

		# copy ID to gene_hash
		$mrna_hash{$l[1]} +=1;
		#print "$l[0]\n";
	}
}
close(ID);

#my %combined_hash = (%gene_hash, %mrna_hash);

# GFF3 file
#open(FILE,"<", $transcripts) or die "$!";
open(FILE,$transcripts) or die "$!";

while (<FILE>) { # Read lines from file(s) specified on command line. Store in $_.
    s/#.*//; # Remove comments from $_.
    next unless /\S/; # \S matches non-whitespace.  If not found in $_, skip to next line.
	chomp;
	my @f = split (/\t/); # split $_ at tabs separating fields.

	# extract the gene line from GFF3 if present in ID file
	if($f[2] eq "gene")	{
		$f[8] =~ /ID\s*=\s*([^;]+)/; # ID=INRA_S3_CUFF.10004.1|g.145776;Name=ORF
		my $gene_id = $1;
		$gene_id =~ s/\s+$//;
		#$gene_id =~ s/\|g/\|m/;			# For transdecoder GFF3 files
		if (exists $gene_hash{$gene_id}) {
			print "$_\n";
		}
	}
	# extract the mRNA line from GFF3 if present in ID file
	elsif ($f[2] eq "mRNA" || $f[2] eq "transcript") {
		$f[8] =~ /ID\s*=\s*([^;]+)/; # ID=INRA_S3_CUFF.10003.1|m.145802;Parent=INRA_S3_CUFF.10003.1|g.145802;Name=ORF
		my $mrna_id = $1;
		$mrna_id =~ s/\s+$//;
		if (exists $mrna_hash{$mrna_id}) {
			print "$_\n";
		}
	}

	# extract the rest line from GFF3 if present in ID file
	else {
		$f[8] =~ /Parent\s*=\s*([^;]+)/; # ID=INRA_S3_CUFF.10003.1|m.145802;Parent=INRA_S3_CUFF.10003.1|g.145802;Name=ORF
		my $rest_id = $1;
		$rest_id =~ s/\s+$//;
		#$rest_id =~ s/\|g/\|m/;			# For transdecoder GFF3 files
		if (exists $mrna_hash{$rest_id}) {
			print "$_\n";
		}
	}
}
close(FILE);
exit;

