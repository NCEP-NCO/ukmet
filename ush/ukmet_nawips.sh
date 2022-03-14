#!/bin/ksh
###################################################################
echo "----------------------------------------------------"
echo "exnawips - convert NCEP GRIB files into GEMPAK Grids"
echo "----------------------------------------------------"
echo "History: Mar 2000 - First implementation of this new script."
echo "S Lilly: May 2008 - add logic to make sure that all of the "
echo "                    data produced from the restricted ECMWF"
echo "                    data on the CCS is properly protected."
echo "C. Magee: 11/2013 - swap X and Y for rtgssthr Atl and Pac."
echo "S Earle: 1/7 -    - modified for ukmet"
#####################################################################

set -xa

cd $DATA

msg="Begin job for $job"
postmsg "$jlogfile" "$msg"

NAGRIB=nagrib_nc

cpyfil=gds
garea=dset
gbtbls=
maxgrd=200
kxky=
grdarea=
proj=
output=T
pdsext=no

maxtries=180
fhcnt=$fstart
while [ $fhcnt -le $fend ] ; do
  if [ $fhcnt -ge 100 ] ; then
    typeset -Z3 fhr
  else
    typeset -Z2 fhr
  fi
  fhr=$fhcnt
  fhcnt3=`expr $fhr % 3`

  fhr3=$fhcnt
  typeset -Z3 fhr3

  case $RUN in
   ukmet) GRIBIN=$COMIN/${RUN}.${cycle}.${GRIB}${fhr}${EXT}
          GEMGRD=${RUN}_${PDY}${cyc}f${fhr3} ;;
   ukmet2)  $WGRIB ukmet2.grib | grep "${fhr}hr" | $WGRIB \
          -i -grib -o ukmet2.${fhr} ukmet2.grib
          GRIBIN=ukmet2.${fhr}
          GEMGRD=ukmet_${PDY}${cyc}f${fhr3} ;;
  esac

  GRIBIN_chk=$GRIBIN

  icnt=1
  while [ $icnt -lt 1000 ]
  do
    if [ -r $GRIBIN_chk ] ; then
      break
    else
      let "icnt=icnt+1"
      sleep 20
    fi
    if [ $icnt -ge $maxtries ]
    then
      msg="ABORTING after 1 hour of waiting for F$fhr to end."
      err_exit $msg
    fi
  done

  cp $GRIBIN grib$fhr

  export pgm="nagrib_nc F$fhr"

  startmsg

  $GEMEXE/$NAGRIB << EOF
   GBFILE   = grib$fhr
   INDXFL   = 
   GDOUTF   = $GEMGRD
   PROJ     = $proj
   GRDAREA  = $grdarea
   KXKY     = $kxky
   MAXGRD   = $maxgrd
   CPYFIL   = $cpyfil
   GAREA    = $garea
   OUTPUT   = $output
   GBTBLS   = $gbtbls
   GBDIAG   = 
   PDSEXT   = $pdsext
  l
  r
EOF
  export err=$?;err_chk
  gpend

  #####################################################
  # GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
  # WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
  # FOR THIS CASE HERE.
  #####################################################
  if [ $model != "ukmet_early" ] ; then
    ls -l $GEMGRD
    export err=$?;export pgm="GEMPAK CHECK FILE";err_chk
  fi

  if [ $SENDCOM = "YES" ] ; then
     cpfs $GEMGRD $COMOUT/$GEMGRD
     if [ $SENDDBN = "YES" ] ; then
         $DBNROOT/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
           $COMOUT/$GEMGRD
     else
       echo "##### DBN_ALERT_TYPE is: ${DBN_ALERT_TYPE} #####"
     fi
  fi

  if [ $RUN = "ukmet" -a $fhcnt -ge 48 ] ; then
    let fhcnt=fhcnt+12
  else
    let fhcnt=fhcnt+finc
  fi
done

#####################################################################
# GOOD RUN
set +x
echo "**************JOB $RUN NAWIPS COMPLETED NORMALLY ON THE IBM"
echo "**************JOB $RUN NAWIPS COMPLETED NORMALLY ON THE IBM"
echo "**************JOB $RUN NAWIPS COMPLETED NORMALLY ON THE IBM"
set -x
#####################################################################

msg='Job completed normally.'
echo $msg
postmsg "$jlogfile" "$msg"

############################### END OF SCRIPT #######################
