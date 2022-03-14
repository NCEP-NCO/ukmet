#!/bin/ksh

#
# Metafile Script : ukmet_gempak_redbook.sh
#
# Log :
# D.W.Plummer/NCEP   2/97   Add log header
# D.W.Plummer/NCEP  12/97   Added NGM v. ETA plot comparison if NGM precedes ETA
# J. Carr/HPC        8/98   Changed map to medium resolution
# J. Carr/HPC        1/99   Changed contur from 1 to 2 per OM request
# J. Carr/HPC        2/99   Changed skip to 0 per OM request
# B. Gordon/NCO      5/00   Ported to IBM-SP, Standardized for production,
#                           changed gdplot_nc -> gdplot2_nc
# B. Gordon/NCO      4/01   Modified to make individual GIF images.
# L. Sager/NCO       3/06   Modified to make UKMET Redbook graphics
#
cd $DATA

  $GEMEXE/gdplot2 << EOF
\$MAPFIL= mepowo.gsf

GDFILE	= $COMIN/${RUN}_${DATE}${cyc}f096   
GDATTIM	= F096    
TITLE  = 1/-4/ UKMET 96HR 500MB HEIGHT         
DEVICE  = rbk| u05 ||c
restore $USHgempak/restore/500mb_hgt_ukmet.2.rbk.nts
r

CLEAR  = NO
TITLE  = 1/-3/ $TITLEA 
GDPFUN = 
LATLON = 
r

GDFILE	= $COMIN/${RUN}_${DATE}${cyc}f120    
GDATTIM	= F120    
TITLE  = 1/-4/ UKMET 120HR 500MB HEIGHT         
DEVICE  = rbk| u06 ||c
restore $USHgempak/restore/500mb_hgt_ukmet.2.rbk.nts
r

CLEAR  = NO
TITLE  = 1/-3/ $TITLEB 
GDPFUN = 
LATLON = 
r

GDFILE	= $COMIN/${RUN}_${DATE}${cyc}f144    
GDATTIM	= F144    
TITLE  = 1/-4/ UKMET 144HR 500MB HEIGHT         
DEVICE  = rbk| u07 ||c
restore $USHgempak/restore/500mb_hgt_ukmet.2.rbk.nts
r

CLEAR  = NO
TITLE  = 1/-3/ $TITLEC 
GDPFUN = 
LATLON = 
r

GDFILE	= $COMIN/${RUN}_${DATE}${cyc}f096    
GDATTIM	= F096    
TITLE  = 1/-4/ UKMET 96HR MSLP FORECAST         
DEVICE  = rbk| u16 ||c
restore $USHgempak/restore/mslp_ukmet.2.rbk.nts
r

CLEAR  = NO
TITLE  = 1/-3/ $TITLEA 
GDPFUN = 
LATLON = 
r

GDFILE	= $COMIN/${RUN}_${DATE}${cyc}f120    
GDATTIM	= F120    
TITLE  = 1/-4/ UKMET 120HR MSLP FORECAST         
DEVICE  = rbk| u17 ||c
restore $USHgempak/restore/mslp_ukmet.2.rbk.nts
r

CLEAR  = NO
TITLE  = 1/-3/ $TITLEB 
GDPFUN = 
LATLON = 
r

GDFILE	= $COMIN/${RUN}_${DATE}${cyc}f144    
GDATTIM	= F144    
TITLE  = 1/-4/ UKMET 144HR MSLP FORECAST         
DEVICE  = rbk| u18 ||c
restore $USHgempak/restore/mslp_ukmet.2.rbk.nts
r

CLEAR  = NO
TITLE  = 1/-3/ $TITLEC 
GDPFUN = 
LATLON = 
r

EOF


$GEMEXE/gpend
#
