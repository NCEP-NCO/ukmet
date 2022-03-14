#!/bin/ksh
#####################################################################
echo "------------------------------------------------"
echo "JUKMET - UKMET postprocessing"
echo "------------------------------------------------"
echo "History: AUG 1995 - First implementation of this new script  "
echo "                     for processing 1.25 degree grids FTPd   "
echo "                     from the HDS.                           "
echo "          OCT 1996 - Standardized and added SMS hooks.       "
echo "          JAN 1997 - Moved processing from Cray3 to Cray4.   "
echo "                     Now processes 2.5 and 1.25 degree       "
echo "                     bulletins from /dcom instead of HDS     "
echo "                     preprocessed/FTPd files.                "
echo "          APR 1997 - Added AFOS/AWIPS UKMET graphics.        "
echo "          APR 1997 - Added FAX UKMET graphics.               "
echo "          APR 1997 - Change date-line for the 12Z UKMET      "
echo "                     graphics from PDYm1 to PDY.             "
echo "          AUG 1997 - Added copygb to make 00-72hr 2.5 degree "
echo "                     files from 1.25 degree files            "
echo "          MAR 1998 - Add lines to kick off script to track "
echo "                     tropical storms in UKMET GRIB files -- Marchok "
echo "          APR 1998 - modified to use afstoawp.sh to convert"
echo "                     AFOS maps U06 and U17 into awips format-"
echo "                     Peter Henrichsen. "
echo "          AUG 1998 - modified to make GRIB processing Y2K"
echo "                     compliant.  -- W. Bostelman"
echo "          SEP 1998 - modified to run for CYCLES 00Z/12Z separately-" 
echo "                     made appropriate script changes to run f-90 codes-" 
echo "                     faxmakr90, afosmakr90 & ukmetdp3 with Y2K "
echo "                     compliance. -- Bill Facey/Krishna Kumar "
echo "          JAN 1999 - modified to convert UKMET AFOS graphics U01-  " 
echo "                     U18 to Redbook graphics format for AWIPS      " 
echo "          SEP 1999 - Converted to IBM SP                     " 
echo "          FEB 2002 - Modified to create a non-restricted UKMET "
echo "          JUN 2005 - Restored production of pils u05, u06, u07, "
echo "                     u16, u17, u18                              "
echo "          AUG 2005 - Restored UKMET 500MB D+3 HGT/DN and a ECMWF "
echo "                     for HPC.                                    "
echo "          OCT 2005 - Send Redbook graphics to TOC via the NTC    "
echo "          APR 2006 - Move Redbook processing to separate script "
echo "          FEB 2012 - Modify script so that if any missing data  "
echo "                     it still continues processing the data until"
echo "                     the end then the job will be aborted."
echo "          JUN 2014 - Comment out err_chk  "
echo "          NOV 2014 - Update for Vertical Structure of UKMET "
#####################################################################

cd $DATA


########################################################################
#
# START FLOW OF CONTROL
#
#  1) Get the Date from /com/date
#     -- Now done in J-job, not here.
#  2) Initialize the run control file for the UKMET 1.25 processing.
#  3) Extract UKMET 1.25 degree data from /dcom holding tank.
#  4) Form GRIB Grid 45 (1.25) fields from input 1.25 degree GRIB fields.
#  5) Convert 00-72hr 1.25 fields to 2.5 degree fields. 
#  6) Initialize the run control file for the UKMET 2.5 processing.
#  7) Extract UKMET 2.5 degree data from /dcom holding tank.
#  8) Form GRIB Grid 2 (2.5 deg) fields from input 2.5 degree GRIB fields.
#  9) Form D+3 z500 average GRIB file and the Departure from climatology.
# 10) FAXMAKR90 - generate UKMET FAX/varian charts.
# 11) AFOSMAKR90 - generate UKMET bulletins up to hour 72.
# 12) AFOSMAKR90 - generate UKMET AFOS maps U06 and U17.
# 13) start script afstoawp.sh to convert UKMET AFOS graphics   
#               into AWIPs redbook format.
# 14) Kick off script to track tropical storms in UKMET GRIB files.
#########################################################################


########################################
set -x
msg="STARTED!"
postmsg "$jlogfile" "$msg"
########################################

##############################################################
#     Process the 1.25 degree UKMET bulletins
##############################################################
set +x
echo " "
echo "#############################################"
echo " Initialize UKMET run control file (BULLPROI)"
echo "#############################################"
echo " "
set -x

#
#  Get Run Date and GRIB processing file name/path name
#
rm RDATE

RDY=$PDY
RDYm1=$PDYm1

tot_err=0

grbfile_id=ukwafs
if test "$grbfile_id" != 'grdbul'
then
   Filedate=$RDY
   RCYCL=$cyc
else
   Filedate=$RDYm1
   RCYCL=12
fi

#
GRBFILE=${DCOMIN}/${Filedate}/wgrbbul/${grbfile_id}_${RCYCL}
echo "DATE  ${Filedate}${RCYCL}WASHINGTON">RDATE

rm hdrfile
rm hdrinv 

export pgm=BULLPROI
. prep_step

export FORT11="RDATE"
export FORT12="$PARMukmet/grib_listbul.uk125"
export FORT51="hdrfile"
export FORT52="hdrinv"

startmsg
$BULLPROI >> $pgmout 2> errfile
export err=$?
 
if test "$err" -ne '0'
then
   set +x
   echo "Something wrong with input cards"
   set -x

   msg="SOMETHING WRONG WITH UKMET 1.25 INPUT CARDS"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi
 

#  Copy GRIB Bulletin File to the Working Directory for pgm BULL2SEQ 

#cp ${GRBFILE} grbulls
cp $GRBFILE grbulls

set +x
echo " "
echo "#########################################"
echo " Extract UKMET data from $DCOMROOT (BULL2SEQ)"
echo "#########################################"
echo " "
set -x

#     execute program BULL2SEQ to extract 1.25 GRIB/GRID bulletins 
#     from the incoming bulletin holding files and create
#     a file from which they may be accessed for processing.
#                
export pgm=BULL2SEQ
. prep_step

#   GRIB Input File
export FORT11="hdrfile"
export FORT12="grbulls"
#   GRIB Output Files
export FORT51="hdrinv"
export FORT61="ukgribf00"
export FORT62="ukgribf06"
export FORT63="ukgribf12"
export FORT64="ukgribf18"
export FORT65="ukgribf24"
export FORT66="ukgribf30"
export FORT67="ukgribf36"
export FORT68="ukgribf42"
export FORT69="ukgribf48"
export FORT70="ukgribf60"
export FORT71="ukgribf72"

startmsg
$BULL2SEQ >> $pgmout 2> errfile
export err=$?
 
if test "$err" -ne '0'
then
   set +x
   echo "No UKMET 1.25 data found in $DCOMROOT"
   set -x

   msg="NO UKMET 1.25 DATA FOUND IN /DCOM"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi
 
set +x
echo " "
echo "####################################################"
echo " Unpack and order UKMET 1.25 grids into ordered sets"
echo "####################################################"
echo " "
set -x

#     execute program UNPMGRB1 to unpack GRIB data into
#     floating point numbers and arrange output files into
#     grid-ordered sets.  A complete set contains 8 grids
#     of type 37-44.
#                
export pgm=UNPMGRB1
. prep_step

#  Input Parameter List
export FORT11="$PARMukmet/grib_listbul.uk125"
#
#  GRIB Bulletin Input Files 
export FORT12="ukgribf00"
export FORT13="ukgribf06"
export FORT14="ukgribf12"
export FORT15="ukgribf18"
export FORT16="ukgribf24"
export FORT17="ukgribf30"
export FORT18="ukgribf36"
export FORT19="ukgribf42"
export FORT20="ukgribf48"
export FORT21="ukgribf60"
export FORT22="ukgribf72"
#
#  Unpacked GRIB Output Files,  Set 1 - Winds Excluded
export FORT51="unpukg00"
export FORT52="unpukwg00"
export FORT53="unpukg06"
export FORT54="unpukwg06"
export FORT55="unpukg12"
export FORT56="unpukwg12"
export FORT57="unpukg18"
export FORT58="unpukwg18"
export FORT59="unpukg24"
export FORT60="unpukwg24"
export FORT61="unpukg30"
export FORT62="unpukwg30"
export FORT63="unpukg36"
export FORT64="unpukwg36"
export FORT65="unpukg42"
export FORT66="unpukwg42"
export FORT67="unpukg48"
export FORT68="unpukwg48"
export FORT69="unpukg60"
export FORT70="unpukwg60"
export FORT71="unpukg72"
export FORT72="unpukwg72"
#
#  Unpacked GRIB Output Files,  Set 2 - Winds
export FORT80="ukjcdata" # Output file

startmsg
$UNPMGRB1 >> $pgmout 2> errfile
export err=$?
 
if test "$err" -ne '0'
then
   set +x
   echo "No bulletins found on input file"
   set -x

   msg="NO UKMET 1.25 DATA FOUND IN INPUT FILE"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi
 
set +x
echo " "
echo "####################################################"
echo " Read, combine and thicken 1.25 (non-wind) grids    "
echo "####################################################"
echo " "
set -x

#     Execute program MK125FLS to read sets of 8 thinned
#     grids, combine into a global thinned grid, then
#     thicken into a 288 x 145 1.25 degree global grid.
#     Output is a GRIB 45 grid (1.25 grid).
#                
export pgm=MK125FLS
. prep_step

#  JCDATA Input File  
export FORT11="ukjcdata"
#
#  Unpacked GRIB Input Files
export FORT12="unpukg00"
export FORT13="unpukg06"
export FORT14="unpukg12"
export FORT15="unpukg18"
export FORT16="unpukg24"
export FORT17="unpukg30"
export FORT18="unpukg36"
export FORT19="unpukg42"
export FORT20="unpukg48"
export FORT21="unpukg60"
export FORT22="unpukg72"
#
#  Output Files of Grid map 45, 1.25 Degree fields
export FORT51="uk45f00"
export FORT52="uk45f06"
export FORT53="uk45f12"
export FORT54="uk45f18"
export FORT55="uk45f24"
export FORT56="uk45f30"
export FORT57="uk45f36"
export FORT58="uk45f42"
export FORT59="uk45f48"
export FORT60="uk45f60"
export FORT61="uk45f72"

startmsg
$MK125FLS >> $pgmout 2> errfile
export err=$?
 
if test "$err" -ne '0'
then
   set +x
   echo "No bulletins found on input file"
   set -x

   msg="NO UKMET 1.25 DATA FOUND IN INPUT FILE"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi

set +x
echo " "
echo "####################################################"
echo " Read, combine and thicken 1.25 (u/v wind) grids    "
echo "####################################################"
echo " "
set -x

#     Execute program MK125FLW to read sets of 8 thinned
#     U/V grids, combine into a global thinned grid, then
#     thicken into a 288 x 145 1.25 degree global grid.
#     Output is a GRIB 45 grid (1.25 grid).
#                
export pgm=MK125FLW
. prep_step

#  JCDATA Input File  
export FORT11="ukjcdata"
#
#  Unpacked GRIB Input Files
export FORT12="unpukwg00"
export FORT13="unpukwg06"
export FORT14="unpukwg12"
export FORT15="unpukwg18"
export FORT16="unpukwg24"
export FORT17="unpukwg30"
export FORT18="unpukwg36"
export FORT19="unpukwg42"
export FORT20="unpukwg48"
export FORT21="unpukwg60"
export FORT22="unpukwg72"
#
#  Output Files of Grid map 45, 1.25 Degree fields
export FORT51="uk45wf00"
export FORT52="uk45wf06"
export FORT53="uk45wf12"
export FORT54="uk45wf18"
export FORT55="uk45wf24"
export FORT56="uk45wf30"
export FORT57="uk45wf36"
export FORT58="uk45wf42"
export FORT59="uk45wf48"
export FORT60="uk45wf60"
export FORT61="uk45wf72"

startmsg
$MK125FLW >> $pgmout 2> errfile
export err=$?
 
if test "$err" -ne '0'
then
   set +x
   echo "No bulletins found on input file"
   set -x

   msg="NO UKMET 1.25 WIND DATA FOUND IN INPUT FILE"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi

###############################################################
#  Good run, now concatenate the uk45wf to uk45f files,
#  run COPYGB to convert 00-72hr 1.25 degree to 2.5 degree files
#  make index files and copy the files to /com
###############################################################
ftimes='00 06 12 18 24 30 36 42 48 60 72'

for ft in $ftimes
do
 cat uk45f$ft uk45wf$ft > ukmet.${cycle}.ukmet$ft

 $GRBINDEX ukmet.${cycle}.ukmet$ft \
  ukmet.${cycle}.ukmeti$ft

#############################################
# Convert to grib2 format
#############################################

 $CNVGRIB -g12 -p40 ukmet.${cycle}.ukmet$ft ukmet.${cycle}.ukmet${ft}.grib2
 $WGRIB2 -s ukmet.${cycle}.ukmet$ft.grib2 > ukmet.${cycle}.ukmet${ft}.grib2.idx

  if test $SENDCOM = 'YES'
  then
    cp ukmet.${cycle}.ukmet$ft $COMOUT
    cp ukmet.${cycle}.ukmeti$ft $COMOUT

    cp ukmet.${cycle}.ukmet${ft}.grib2 $COMOUT
    cp ukmet.${cycle}.ukmet${ft}.grib2.idx $COMOUT
  fi

  $COPYGB -g2 ukmet.${cycle}.ukmet$ft \
  ukmet.${cycle}.ukmeti$ft ukmet.${cycle}.ukm25f$ft
  $GRBINDEX ukmet.${cycle}.ukm25f$ft \
  ukmet.${cycle}.ukm25if$ft

  if test $SENDCOM = 'YES'
  then
    cp ukmet.${cycle}.ukm25f$ft $COMOUT
    cp ukmet.${cycle}.ukm25if$ft $COMOUT
  fi
done

##############################################################
#
#     Process the 2.5 degree UKMET bulletins (96-144hr)
#
##############################################################


# Clean up work files from 1.25 degree processing

rm hdrfile hdrinv bullfile grdbulls
 
set +x
echo " "
echo "#############################################"
echo " Initialize UKMET run control file (BULLPROI)"
echo "#############################################"
echo " "
set -x
#
#  Get Run Date and GRIB processing file name/path name
#
rm RDATE

RDY=$PDY
RDYm1=$PDYm1

grbfile_id=uk25
if test "$grbfile_id" != 'grdbul'
then
   Filedate=$PDY
   RCYCL=$cyc
else
   Filedate=$RDYm1
   RCYCL=12
fi

GRBFILE=${DCOMIN}/${Filedate}/wgrbbul/${grbfile_id}_${RCYCL}
echo "DATE  ${Filedate}${RCYCL}WASHINGTON">RDATE

rm hdrfile*
rm hdrinv* 

export pgm=BULLPROI
. prep_step

export FORT11="RDATE"
export FORT12="$PARMukmet/grib_listbul.uk25"
export FORT51="hdrfile"
export FORT52="hdrinv"

startmsg
msg="pgm=BULLPROI has BEGUN"
postmsg "$msg"

$BULLPROI >> $pgmout 2> errfile
export err=$?

###############################################################
# Initialize None-Restricted UKMET run control file (BULLPROI)
###############################################################

export FORT11="RDATE"
export FORT12="$PARMukmet/grib_NRlistbul.uk25"
export FORT51="hdrfile2"
export FORT52="hdrinv2"

$BULLPROI >> $pgmout 2> errfile
export err=$?

if test "$err" -ne '0'
then
   set +x
   echo "Something wrong with input cards"
   set -x

   msg="SOMETHING WRONG WITH UKMET 2.5 INPUT CARDS"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi
 
#  Copy GRIB Bulletin File to the Working Directory for pgm BULL2SEQ 

cp ${GRBFILE} grbulls

set +x
echo " "
echo "#########################################"
echo " Extract UKMET data from $DCOMROOT (BULL2SEQ)"
echo "#########################################"
echo " "
set -x

#     execute program BULL2SEQ to extract 2.5 GRIB/GRID bulletins 
#     from the incoming bulletin holding files and create
#     a file from which they may be accessed for processing.
#                
export pgm=BULL2SEQ
. prep_step

# Input Files
export FORT11="hdrfile"
export FORT12="grbulls"
# Output Files
export FORT51="hdrinv"
export FORT61="ukmgrbfxx"

startmsg
$BULL2SEQ >> $pgmout 2> errfile
export err=$?

###############################################################
# Process None-Restricted UKMET
###############################################################
 
# Input Files
export FORT11="hdrfile2"
export FORT12="grbulls"
# Output Files
export FORT51="hdrinv2"
export FORT61="nrukmgrbfxx"

startmsg
$BULL2SEQ >> $pgmout 2> errfile
export err=$?

if test "$err" -ne '0'
then
   set +x
   echo "No UKMET 2.5 data found in $DCOMROOT"
   set -x

   msg="NO UKMET 2.5 DATA FOUND IN /DCOM"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi
 
set +x
echo " "
echo "######################################"
echo " Process UKMET data (MKGRB25)"
echo "######################################"
echo " "
set -x

#     Reads sets of 4 grids, combines into one global set.
#     Output is made in GRIB format under grid 2 specs.

export pgm=MKGRB25
. prep_step

export FORT11="hdrfile" # JCDATA Input File
export FORT12="hdrinv"
export FORT13="ukmgrbfxx" # Unpacked GRIB Input
export FORT51="ukm25fxx" # Output Grid 2, 2.5 Degree fields

startmsg
$MKGRB25 >> $pgmout 2> errfile
export err=$?

###############################################################
# Process None-Restricted UKMET data (MKGRB25)
###############################################################
 
export FORT11="hdrfile2" # JCDATA Input File
export FORT12="hdrinv2"
export FORT13="nrukmgrbfxx" # Unpacked GRIB Input
export FORT51="nrukmet.${cycle}.ukm25" # Output Grid 2, 2.5 Degree fields

startmsg
$MKGRB25 >> $pgmout 2> errfile
export err=$?

if test "$err" -ne '0'
then
   set +x
   echo "MKGRB25 failed making UKMET 2.5 degree grids"
   set -x

   msg="MKGRB25 FAILED MAKING UKMET 2.5 DEGREE GRIDS"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi
 
#    Append the fxx file to the f72 hr file and reindex
#    the ukm25f72 file

cat ukm25fxx >> ukmet.${cycle}.ukm25f72

$GRBINDEX ukmet.${cycle}.ukm25f72 \
 ukmet.${cycle}.ukm25if72

$GRBINDEX nrukmet.${cycle}.ukm25 \
 nrukmet.${cycle}.ukm25i

set +x
echo " "
echo "######################################"
echo " Enhance it with UKAUXFLD"
echo "######################################"
echo " "
set -x

#     Read in basic ecmwf grib fields and compute 500 mb 
#     geostrophic vorticity and 1000 mb height

export pgm=UKAUXFLD
. prep_step

#
#  Output Files of Grid map 2, 2.5 Degree fields
export FORT11="ukmet.${cycle}.ukm25f72"
export FORT31="ukmet.${cycle}.ukm25if72"
export FORT51="UKAUXFLD"

startmsg
$UKAUXFLD >> $pgmout 2> errfile
export err=$?
 
if test "$err" -ne '0'
then
   set +x
   echo "UKAUXFLD failed making 2.5 degree auxiliary grids"
   set -x

   msg="UKAUXFLD FAILED MAKING UKMET 2.5 DEGREE AUXILIARY GRIDS"
   postmsg "$msg"

   tot_err=`expr $tot_err + $err`
fi
 
cat UKAUXFLD >> ukmet.${cycle}.ukm25f72
$GRBINDEX ukmet.${cycle}.ukm25f72 \
 ukmet.${cycle}.ukm25if72

##############################
# Convert to grib2 format
##############################
$CNVGRIB  -g12 -p40 nrukmet.${cycle}.ukm25 nrukmet.${cycle}.ukm25.grib2
$WGRIB2 nrukmet.${cycle}.ukm25.grib2 -s >nrukmet.${cycle}.ukm25.grib2.idx

if test $SENDCOM = 'YES'
then
  cp ukmet.${cycle}.ukm25f72  $COMOUT
  cp ukmet.${cycle}.ukm25if72 $COMOUT
  cp nrukmet.${cycle}.ukm25   $COMOUT
  cp nrukmet.${cycle}.ukm25i  $COMOUT

  cp nrukmet.${cycle}.ukm25.grib2 $COMOUT
  cp nrukmet.${cycle}.ukm25.grib2.idx $COMOUT
fi

set +x
echo " "
echo "#############################################################"
echo " Send the 2.5 degree UKMET files to OSO (for the server).    "
echo "#############################################################"
echo " "
set -x

if test "$SENDDBN" = 'YES'
then
  $DBNROOT/bin/dbn_alert MODEL NRUKMET25 $job $COMOUT/nrukmet.${cycle}.ukm25
  $DBNROOT/bin/dbn_alert MODEL NRUKMET25_GB2 $job $COMOUT/nrukmet.${cycle}.ukm25.grib2
  $DBNROOT/bin/dbn_alert MODEL NRUKMET25_GB2_WIDX $job $COMOUT/nrukmet.${cycle}.ukm25.grib2.idx

  for ft in $ftimes
  do
    $DBNROOT/bin/dbn_alert MODEL UKMET25 $job $COMOUT/ukmet.${cycle}.ukm25f$ft
    $DBNROOT/bin/dbn_alert MODEL UKMET125 $job $COMOUT/ukmet.${cycle}.ukmet$ft
    $DBNROOT/bin/dbn_alert MODEL UKMET125_GB2 $job $COMOUT/ukmet.${cycle}.ukmet${ft}.grib2
    $DBNROOT/bin/dbn_alert MODEL UKMET125_GB2_WIDX $job $COMOUT/ukmet.${cycle}.ukmet${ft}.grib2.idx
  done
fi

#####################################################################
# GOOD RUN
set +x
echo "**************JOB UKMET COMPLETED NORMALLY ON THE IBM SP"
echo "**************JOB UKMET COMPLETED NORMALLY ON THE IBM SP"
echo "**************JOB UKMET COMPLETED NORMALLY ON THE IBM SP"
set -x
#####################################################################

############## END OF SCRIPT #######################
