# chimaeraCheck

A perl script for detecting paired reads generated via ddRAD methods that either contain chimaera sequences, or incompletely digested sequence. The script detects and removes these reads. 

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
     
