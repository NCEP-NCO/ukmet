#! /bin/ksh
#
# Metafile Script : ukmet_meta_mar_vgf.sh - produce VGF files for 
#                   ATL/PAC high seas desks
# Log :
# J. Carr/PMB   12/13/2004    Pushed into production.
#
#
# Set up Local Variables
#
set -x
#
export PS4='OPC_MAR_VGF:$SECONDS + '
workdir="${DATA}/OPC_MAR_VGF"
mkdir ${workdir}
cd ${workdir}

cp $FIXukmet/datatype.tbl datatype.tbl

mdl=ukmet
MDL="UKMETHR"
PDY2=`echo $PDY | cut -c3-`

export HPCUKMET=${COMIN}/${RUN}.${PDY}/gempak
export DBN_ALERT_TYPE=VGF
export DBN_ALERT_SUBTYPE=OPC

gdplot2_vg << EOFplt
gdfile	= F-${MDL} | ${PDY2}/${cyc}00
gdattim = f60
garea   = 17;-98;64;10
proj    = mer
latlon  =
map     = 0
clear   = yes
device  = vg | ${mdl}_${PDY2}_${cyc}_60ATLsfc.vgf
glevel  = 0
gvcord  = none
panel   = 0
skip    = 0
scale   = 0
gdpfun  = pmsl
type    = c
contur  = 7
cint    = 4
line    = 5/1/3/-5/2/.13
fint    =
fline   =
hilo	=
hlsym	=
clrbar  = 0
wind    =
refvec  =
title   =
text    = 1.3/21/2/hw
li
ru

gdattim = F120
device  = vg | ATL_${mdl}_120sfc_${PDY2}_${cyc}.vgf
li
ru


garea   = 17;136;64;-116
device  = vg | ${mdl}_${PDY2}_${cyc}_60PACsfc.vgf
li
ru

gdattim = F120
device  = vg | PAC_${mdl}_120sfc_${PDY2}_${cyc}.vgf
li
ru


exit
EOFplt

if [ $SENDCOM = "YES" ] ; then
#    mv *.vgf ${COMOUT}
    for file in `ls *.vgf`
    do
      cpfs $file ${COMOUT}/$file
    done

    if [ $SENDDBN = "YES" ] ; then
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/${mdl}_${PDY2}_${cyc}_60ATLsfc.vgf
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/${mdl}_${PDY2}_${cyc}_60PACsfc.vgf
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/ATL_${mdl}_120sfc_${PDY2}_${cyc}.vgf
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/PAC_${mdl}_120sfc_${PDY2}_${cyc}.vgf
    fi
fi
exit
