#!/bin/sh
#####################################################################
echo "------------------------------------------------"
echo "   UKMET Graphics postprocessing"
echo "------------------------------------------------"
echo "History: April 2006 - First implementation of this new script."
#####################################################################

set -x
msg="Begin job for $job"
postmsg "$jlogfile" "$msg"

cd $DATA

#####################################################################
#  Create the UKMET GEMPAK Redbook graphics for                     #
#  500mb height and mean sea level pressure at 96 hours,            #
#  120 hours and 144 hours. 					    #	
#####################################################################

#
# Start by creating the day-of-week Titles
#

echo 0096${PDY}${cyc} > dates
export FORT55="title.output"
$WEBTITLE  <  dates
export TITLEA=`cat title.output`
echo 0120${PDY}${cyc} > dates
$WEBTITLE  <  dates
export TITLEB=`cat title.output`
echo 0144${PDY}${cyc} > dates
$WEBTITLE  <  dates
export TITLEC=`cat title.output`

export DATE=$PDY

  $USHgempak/ukmet_gempak_redbook.sh 
#
#    Add the NTC header to the Redbook graphic and send to TOC
#

  $USHukmet/make_ntc_bull.pl  redb  NONE KWNO NONE    \
    $DATA/NMCGPHU05     $COMOUTwmo/ukmet_redbook_u05.$cycle
  $USHukmet/make_ntc_bull.pl  redb  NONE KWNO NONE    \
    $DATA/NMCGPHU06     $COMOUTwmo/ukmet_redbook_u06.$cycle
  $USHukmet/make_ntc_bull.pl  redb  NONE KWNO NONE    \
    $DATA/NMCGPHU07     $COMOUTwmo/ukmet_redbook_u07.$cycle
  $USHukmet/make_ntc_bull.pl  redb  NONE KWNO NONE    \
    $DATA/NMCGPHU16     $COMOUTwmo/ukmet_redbook_u16.$cycle
  $USHukmet/make_ntc_bull.pl  redb  NONE KWNO NONE    \
    $DATA/NMCGPHU17     $COMOUTwmo/ukmet_redbook_u17.$cycle
  $USHukmet/make_ntc_bull.pl  redb  NONE KWNO NONE    \
    $DATA/NMCGPHU18     $COMOUTwmo/ukmet_redbook_u18.$cycle

if [ $SENDDBN = YES ]; then
  $DBNROOT/bin/dbn_alert NTC_LOW NONE $job $COMOUTwmo/ukmet_redbook_u05.$cycle
  $DBNROOT/bin/dbn_alert NTC_LOW NONE $job $COMOUTwmo/ukmet_redbook_u06.$cycle
  $DBNROOT/bin/dbn_alert NTC_LOW NONE $job $COMOUTwmo/ukmet_redbook_u07.$cycle
  $DBNROOT/bin/dbn_alert NTC_LOW NONE $job $COMOUTwmo/ukmet_redbook_u16.$cycle
  $DBNROOT/bin/dbn_alert NTC_LOW NONE $job $COMOUTwmo/ukmet_redbook_u17.$cycle
  $DBNROOT/bin/dbn_alert NTC_LOW NONE $job $COMOUTwmo/ukmet_redbook_u18.$cycle
fi
#####################################################################
# GOOD RUN
set +x
echo "**************UKMET GEMPAK graphics COMPLETED NORMALLY"
echo "**************UKMET GEMPAK graphics COMPLETED NORMALLY"
echo "**************UKMET GEMPAK graphics COMPLETED NORMALLY"
set -x
#####################################################################

cat $pgmout

msg="HAS COMPLETED NORMALLY!"
echo $msg
postmsg "$jlogfile" "$msg"

############## END OF SCRIPT #######################
