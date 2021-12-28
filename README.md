# chimaeraCheck

A perl script for detecting paired reads generated via ddRAD methods that either contain chimaera sequences, or incompletely digested sequence. The script detects and removes these reads. 

## Usage

Run the script by providing paired reads (fastq format) using the required -f (read 1) and -F (read 2) inputs on the command line. Also specify the restriction enzyme names using the -1 and -2 inputs. A complete list of supported restriction enzymes is supplied below. All restriction enzyme names are case sensitive. 

Example

```
chimaeraCheck.pl -f exampleinput.1.fq -F exampleinput.2.fq -1 PstI -2 MspI
```

You can also use the optional -c (read 1) and -C (read 2) commands to input custom names for the files that will contain all chimaera reads. Otherwise, these will retain your files original name, appending ".chim.fq" as the new extension. Similarly, you can use the optional -o (read 1) and -O (read 2) commands to input custom names for the files containing your retained reads. If you do not specify custom names, the extension ".kept.fq" will be appended to your original file names. 

## Supported Restriction Enzymes:

A list of supported enzymes is as follows.  Cut sites are indicated by '^'.

	   AciI     C^CGC
	   AgeI     A^CCGGT
	   AluI     AG^CT
	   AseI     AT^TAAT
	   BamHI    G^GATCC
	   BfaI     C^TAG
	   BgIII    A^GATCT
	   BspDI    AT^CGAT
	   ClaI     AT^CGAT
	   DpnII    ^GATC
       EcoRI    G^AATTC
	   EcoRV    GAT^ATC
	   EcoT22I  ATGCA^T
	   HindIII  A^AGCTT
	   KpnI     GGTAC^C
	   MluCI    ^AATT
	   MseI     T^TAA
       MspI     C^CGG
	   NdeI     CA^TATG
	   NheI     G^CTAGC
	   NlaIII   CATG^
	   NotI     GC^GGCCGC
	   NsiI     ATGCA^T
       PstI     CTGCA^G
	   RsaI     GT^AC
	   SacI     GAGCT^C
	   Sau3AI   ^GATC
	   SpeI     A^CTAGT
	   SphI     GCATG^C
	   TaqI     T^CGA
	   XbaI     T^CTAGA
	   XhoI     C^TCGAG
	   SbfI     CCTGCA^GG
     
