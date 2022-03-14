#!/bin/ksh
#
# Metafile Script : ukmet_meta_mar_ver
#
# Log :
# J. Carr/PMB     12/15/2004       Pushed into production.
#
# Set up Local Variables
set -x
#
export PS4='mar_ver:$SECONDS + '
mkdir $DATA/mar_ver
cd $DATA/mar_ver
cp $FIXukmet/datatype.tbl datatype.tbl
#ndatex=$NDATE
#
mdl=ukmet
MDL=UKMETHR
metatype="mar"
metaname="ukmetver_${PDY}_${cyc}_mar_ver"
device="nc | ${metaname}"
PDY2=`echo ${PDY} | cut -c3-`
#
#
# DEFINE 1 CYCLE AGO
dc1=`$NDATE -12 ${PDY}${cyc} | cut -c -10`
date1=`echo ${dc1} | cut -c -8`
sdate1=`echo ${dc1} | cut -c 3-8`
cycle1=`echo ${dc1} | cut -c 9,10`
# DEFINE 2 CYCLES AGO
dc2=`$NDATE -24 ${PDY}${cyc} | cut -c -10`
date2=`echo ${dc2} | cut -c -8`
sdate2=`echo ${dc2} | cut -c 3-8`
cycle2=`echo ${dc2} | cut -c 9,10`
# DEFINE 3 CYCLES AGO
dc3=`$NDATE -36 ${PDY}${cyc} | cut -c -10`
date3=`echo ${dc3} | cut -c -8`
sdate3=`echo ${dc3} | cut -c 3-8`
cycle3=`echo ${dc3} | cut -c 9,10`
# DEFINE 4 CYCLES AGO
dc4=`$NDATE -48 ${PDY}${cyc} | cut -c -10`
date4=`echo ${dc4} | cut -c -8`
sdate4=`echo ${dc4} | cut -c 3-8`
cycle4=`echo ${dc4} | cut -c 9,10`
# DEFINE 5 CYCLES AGO
dc5=`$NDATE -60 ${PDY}${cyc} | cut -c -10`
date5=`echo ${dc5} | cut -c -8`
sdate5=`echo ${dc5} | cut -c 3-8`
cycle5=`echo ${dc5} | cut -c 9,10`
# DEFINE 6 CYCLES AGO
dc6=`$NDATE -72 ${PDY}${cyc} | cut -c -10`
date6=`echo ${dc6} | cut -c -8`
sdate6=`echo ${dc6} | cut -c 3-8`
cycle6=`echo ${dc6} | cut -c 9,10`
# DEFINE 7 CYCLES AGO
dc7=`$NDATE -96 ${PDY}${cyc} | cut -c -10`
date7=`echo ${dc7} | cut -c -8`
sdate7=`echo ${dc7} | cut -c 3-8`
cycle7=`echo ${dc7} | cut -c 9,10`
# DEFINE 8 CYCLES AGO
dc8=`$NDATE -120 ${PDY}${cyc} | cut -c -10`
date8=`echo ${dc8} | cut -c -8`
sdate8=`echo ${dc8} | cut -c 3-8`
cycle8=`echo ${dc8} | cut -c 9,10`
# DEFINE 9 CYCLES AGO
dc9=`$NDATE -144 ${PDY}${cyc} | cut -c -10`
date9=`echo ${dc9} | cut -c -8`
sdate9=`echo ${dc9} | cut -c 3-8`
cycle9=`echo ${dc9} | cut -c 9,10`

# SET CURRENT CYCLE AS THE VERIFICATION GRIDDED FILE.
vergrid="F-${MDL} | ${PDY2}/${cyc}00"
fcsthr="f000"

# SET WHAT RUNS TO COMPARE AGAINST BASED ON MODEL CYCLE TIME.
verdays="${dc1} ${dc2} ${dc3} ${dc4} ${dc5} ${dc6} ${dc7} ${dc8} ${dc9}"

# GENERATING THE METAFILES.
for area in ATL PAC
do
    if [ ${area} = "ATL" ] ; then
        garea="15.0;-100.0;70.0;20.0"
    else
        garea="5.0;120.0;70.0;-105.0"
    fi
    for verday in ${verdays}
    do
        MDL2="UKMETHPC"
        cominday=`echo ${verday} | cut -c -8`
        #export HPCUKMET=$COMROOT/nawips/${envir}/${mdl}.${cominday}
        export HPCUKMET=$COMIN/${mdl}.${cominday}/gempak
        if [ ${verday} = ${dc1} ] ; then
            dgdattim=f012
            grid="F-${MDL2} | ${sdate1}/${cycle1}00"
        elif [ ${verday} = ${dc2} ] ; then
            dgdattim=f024
            grid="F-${MDL2} | ${sdate2}/${cycle2}00"
        elif [ ${verday} = ${dc3} ] ; then
            dgdattim=f036
            grid="F-${MDL2} | ${sdate3}/${cycle3}00"
        elif [ ${verday} = ${dc4} ] ; then
            dgdattim=f048
            grid="F-${MDL2} | ${sdate4}/${cycle4}00"
        elif [ ${verday} = ${dc5} ] ; then
            dgdattim=f060
            grid="F-${MDL2} | ${sdate5}/${cycle5}00"
        elif [ ${verday} = ${dc6} ] ; then
            dgdattim=f072
            grid="F-${MDL2} | ${sdate6}/${cycle6}00"
        elif [ ${verday} = ${dc7} ] ; then
            dgdattim=f096
            grid="F-${MDL2} | ${sdate7}/${cycle7}00"
        elif [ ${verday} = ${dc8} ] ; then
            dgdattim=f120
            grid="F-${MDL2} | ${sdate8}/${cycle8}00"
        elif [ ${verday} = ${dc9} ] ; then
            dgdattim=f144
            grid="F-${MDL2} | ${sdate9}/${cycle9}00"
        fi

# 500 MB HEIGHT METAFILE
export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc << EOFplt
PROJ     = MER 
GAREA    = ${garea}
map      = 1//2
clear    = yes
text     = 1/22/////hw
contur   = 2
skip     = 0
type     = c
latlon   = 0 
device   = ${device}

gdfile   = ${vergrid}
gdattim  = ${fcsthr}
gdpfun   = sm5s(hght)
glevel   = 500
gvcord   = pres
scale    = -1
cint     = 6
line     = 6/1/3
title    = 6/-2/~ ? ${MDL} 500 MB HGT (6-HR FCST)|~${area} 500 HGT DIFF
r

gdfile   = ${grid}
gdattim  = ${dgdattim}
line     = 5/1/3
contur   = 4
title    = 5/-1/~ ? ${MDL} 500 MB HGT
clear    = no
r

gdfile   = ${vergrid}
gdattim  = ${fcsthr}
gdpfun   = sm5s(pmsl)
glevel   = 0
gvcord   = none
scale    = 0
cint     = 4
line     = 6/1/3
contur   = 2
title    = 6/-2/~ ? ${MDL} PMSL (6-HR FCST)|~${area} PMSL DIFF
clear    = yes

r

gdfile   = ${grid}
gdattim  = ${dgdattim}
line     = 5/1/3
contur   = 4
title    = 5/-1/~ ? ${MDL} PMSL
clear    = no
r

gdfile   = ${vergrid}
gdattim  = ${fcsthr}
gdpfun   = mag(kntv(wnd))
glevel   = 9950
gvcord   = sgma
scale    = 0
cint     = 35;50;65
line     = 6/1/3
title    = 6/-2/~ ? ${MDL} WIND ISOTACHS 30m|~${area} WIND DIFF
clear    = yes
r

gdfile   = ${grid}
gdattim  = ${dgdattim}
glevel   = 1000
gvcord   = pres 
line     = 5/1/3
contur   = 0
title    = 5/-1/~ ? ${MDL} WIND ISOTACHS 30m
clear    = no
r
ex
EOFplt
export err=$?;err_chk
    done
done

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l $metaname
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
   cpfs ${metaname} ${COMOUT}/ukmet_${res}_ver_${PDY}_${cyc}_mar
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMOUT}/ukmet_${res}_ver_${PDY}_${cyc}_mar
   fi
fi

exit
