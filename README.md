Summary
===========
Script : "extract_GFF3_lines_for_query_ID.pl"

  Extract GFF3 features for given gene->mRNA [match->match_part] query file from GFF3 file

	Usage: perl extract_GFF3_lines_for_query_ID.pl <id.txt[/path/to/id.txt]> <file.gff3[/path/to/file.gff3]>

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
	
<END>
