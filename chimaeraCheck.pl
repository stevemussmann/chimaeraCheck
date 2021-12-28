#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Chart::Gnuplot;
use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
    &help;
    die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( '1:2:c:C:f:F:ho:O:r', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# declare hash to hold restriction enzyme cut sites
my %re = (
		'AciI' => 'C^CGC',
		'AgeI' => 'A^CCGGT',
		'AluI' => 'AG^CT',
		#'ApeKI' => 'G^CWGC',
		#'ApoI' => 'R^AATY',
		'AseI' => 'AT^TAAT',
		'BamHI' => 'G^GATCC',
		'BfaI' => 'C^TAG',
		'BgIII' => 'A^GATCT',
		'BspDI' => 'AT^CGAT',
		#'BstYI' => 'R^GATCY',
		'ClaI' => 'AT^CGAT',
		#'DdeI' => 'C^TNAG',
		'DpnII' => '^GATC',
		#'EaeI' => 'Y^GGCCR',
		'EcoRV' => 'GAT^ATC',
		'EcoT22I' => 'ATGCA^T',
		'HindIII' => 'A^AGCTT',
		'KpnI' => 'GGTAC^C',
		'MluCI' => '^AATT',
		'MseI' => 'T^TAA',
		'NdeI' => 'CA^TATG',
		'NheI' => 'G^CTAGC',
		'NlaIII' => 'CATG^',
		'NotI' => 'GC^GGCCGC',
		'NsiI' => 'ATGCA^T',
		'RsaI' => 'GT^AC',
		'SacI' => 'GAGCT^C',
		'Sau3AI' => '^GATC',
		#'SexAI' => 'A^CCWGGT',
		#'SgrAI' => 'CR^CCGGYG',
		'SpeI' => 'A^CTAGT',
		'SphI' => 'GCATG^C',
		'TaqI' => 'T^CGA',
		'XbaI' => 'T^CTAGA',
		'XhoI' => 'C^TCGAG',
		'SbfI' => 'CCTGCA^GG',
		'EcoRI' => 'G^AATTC',
		'PstI' => 'CTGCA^G',
		'MspI' => 'C^CGG',
	);

# if -r flag is used, kill program and print supported enzyme list
if( $opts{r} ){
	&printenzymes( \%re );
	die "Exiting program following request to print supported enzyme list.\n\n";
}

# parse the command line options and return values
my( $first, $second, $file1, $file2, $chim1, $chim2, $out1, $out2 ) = &parsecom( \%opts );

# open files for reading
open( FILE1, $file1 ) or die "Can't open $file1: $!\n\n";
open( FILE2, $file2 ) or die "Can't open $file2: $!\n\n";

# open files for writing
open( CHIM1, '>', $chim1 ) or die "Can't open $chim1: $!\n\n";
open( CHIM2, '>', $chim2 ) or die "Can't open $chim2: $!\n\n";
open( OUT1, '>', $out1 ) or die "Can't open $out1: $!\n\n";
open( OUT2, '>', $out2 ) or die "Can't open $out2: $!\n\n";

# get restriction enzyme sequences
my $re1 = $re{$first} or die "\nMatch for first restriction enzyme not found in the program.\nCheck your input for flag -1. Input is case sensitive.\nAlternatively, your enzyme may not be supported at this time.\n\n";
my $re2 = $re{$second} or die "\nMatch for first restriction enzyme not found in the program.\nCheck your input for flag -2. Input is case sensitive.\nAlternatively, your enzyme may not be supported at this time.\n\n";

my $cut1 = $re{$first};
my $cut2 = $re{$second};

# remove carot from restriction enzyme cut sites for matching
$re1 =~ s/\^//;
$re2 =~ s/\^//;


my $counter = 0;
my @record1;
my @record2;
my $counts1 = 0;
my $counts2 = 0;
my $kept = 0;
my $discard = 0;

print "\nSearching for chimaeric or incompletely digested sequences containing $first and $second restriction cut sites.\n";
print "Read 1 filename = $file1\n";
print "Read 2 filename = $file2\n\n";

while( defined(my $line1 = <FILE1>) and defined(my $line2 = <FILE2>) ){
	$counter++;
	chomp( $line1 );
	chomp( $line2 );
	push( @record1, $line1 );
	push( @record2, $line2 );
	if( ($counter % 2 == 0) && ($counter % 4 != 0) ){
		#print $line, "\n";
		$line1 =~ s/$re1/$cut1/eg;
		$line1 =~ s/$re2/$cut2/eg;
		$line2 =~ s/$re1/$cut1/eg;
		$line2 =~ s/$re2/$cut2/eg;
		my @fragments1 = split( /\^/, $line1 );
		my @fragments2 = split( /\^/, $line2 );
		$counts1 = scalar(@fragments1);
		$counts2 = scalar(@fragments2);
		#print("Read 1 = ", scalar(@fragments1), "\n");
		#print("Read 2 = ", scalar(@fragments2), "\n");
	}
	if( $counter % 4 == 0 ){
		if( ($counts1 == 1) && ($counts2 == 1) ){
			$kept++;
			foreach my $record( @record1 ){
				print OUT1 $record, "\n";
			}
			foreach my $record( @record2 ){
				print OUT2 $record, "\n";
			}
		}else{
			$discard++;
			foreach my $record( @record1 ){
				print CHIM1 $record, "\n";
			}
			foreach my $record( @record2 ){
				print CHIM2 $record, "\n";
			}
		}
		## FASTQ record clear
		# reset counter
		$counter=0;

		# clear arrays
		@record1 = ();
		@record2 = ();
	}
}
my $perKept = sprintf( "%.2f", ($kept/($kept+$discard))*100 );
my $perChim = sprintf( "%.2f", ($discard/($kept+$discard))*100 );
print "Number of retained read pairs = $kept ($perKept\%).\n";
print "Number of discarded read pairs = $discard ($perChim\%).\n\n";

print "Retained reads written to $out1 and $out2.\n";
print "Discarded reads written to $chim1 and $chim2.\n\n";


# close files
close FILE1;
close FILE2;
close CHIM1;
close CHIM2;
close OUT1;
close OUT2;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nddrad.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  
  print "Program Options:\n";
  print "\t\t[ -1 | -2 | -f | -F | -h | -r ]\n\n";
  print "\t-1:\tUse this to specify the first restriction enzyme.\n";
  print "\t\tProgram will terminate if no enzyme is specified.\n\n";

  print "\t-2:\tUse this to specify the second restriction enzyme.\n";
  print "\t\tProgram will terminate if no enzyme is specified.\n\n";

  print "\t-f:\tUse this to specify the input file name for read 1.\n";
  print "\t\tProgram will terminate if no file name is provided.\n\n";

  print "\t-F:\tUse this to specify the input file name for read 2.\n";
  print "\t\tProgram will terminate if no file name is provided.\n\n";

  print "\t-h:\tUse this command to display this help message.\n";
  print "\t\tProgram will terminate after displaying this help message.\n\n";

  print "\t-r:\tUse this command to display a list of supported restriction enzymes.\n";
  print "\t\tProgram will terminate after displaying the enzyme list.\n\n";

}

#####################################################################################################
# subroutine to print supported enzyme list
sub printenzymes{

	my( $re ) = @_;
	my %enz_seq = %$re;

	print "\nEnzyme", "\t\t", "Target sequence (^ denotes the cut site)", "\n\n";

	#print the list of enzymes
	foreach my $enzyme( sort{ $a cmp $b } keys %enz_seq ){
		print $enzyme, "\t\t", $enz_seq{$enzyme}, "\n";
	}

	print "\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $first = $opts{1} or die "\nFirst restriction enzyme not specified.\n\n";
  my $second = $opts{2} or die "\nSecond restriction enzyme not specified.\n\n";
  my $file1 = $opts{f} or die "\nNo input file specified for read 1.\n\n";
  my $file2 = $opts{F} or die "\nNo input file specified for read 2.\n\n";

  my @root1 = split( /\./, $file1 );
  my @root2 = split( /\./, $file2 );
  my $extension1 = pop( @root1);
  my $extension2 = pop( @root2);

  my $chim1 = $opts{c} || join(".", @root1, "chim", $extension1);
  my $chim2 = $opts{C} || join(".", @root2, "chim", $extension2);
  my $out1 = $opts{o} || join(".", @root1, "kept", $extension1);
  my $out2 = $opts{O} || join(".", @root2, "kept", $extension2);
  
  return( $first, $second, $file1, $file2, $chim1, $chim2, $out1, $out2 );

}

#####################################################################################################
# subroutine to parse a fasta file

sub fastaparse{
    my( $file ) = @_;
    
    # declare strings to hold header and sequence
    my @head;
    my @seqs;
    my $seq;
    
    # open the fasta file
    open( FASTA, $file ) or die "Can't open $file: $!\n\n";
    
    # loop through fasta file and extract data
    while( my $line = <FASTA> ){
      chomp( $line );
      if( $line =~/^>/ ){
	push( @head, $line );
	# push the previous sequence off to the @seqs array
	if( $seq ){
	  push( @seqs, $seq );
	  # undefine the $seq string
	  undef( $seq );
	}
	# if the line does not start with > then append the sequence to the $seq string
      }else{
	$seq .= $line;
      }
    }
    
    # take care of the last sequence by pushing it to @seqs array
    if( $seq ){
      push( @seqs, $seq );
      undef( $seq );
    }
    
    close FASTA;
    
    return( \@head, \@seqs );
    
}

#####################################################################################################
# subroutine to count fragments of a desired size range

sub sizeselect{
  
  my( $fragment, $select, $discard, $min, $max ) = @_;

  if( length( $$fragment ) ~~ [$$min..$$max] ){
    $$select ++;
  }else{
    $$discard++;
  }
  
}

#####################################################################################################
# subroutine to remove numbers from fragments and push sequences to appropriate arrays

sub transform{ 

  my( $array, $seq, $frags ) = @_;

  $$seq =~ s/[12]//g;
  push( @$array, $$seq );
  $$frags++;

}

#####################################################################################################
