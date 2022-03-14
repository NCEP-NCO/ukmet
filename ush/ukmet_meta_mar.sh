#! /bin/ksh
#
# Metafile Script : ukmet_meta_mar.sh
#
# Log :
# J. Carr/PMB       12/13/2004      Pushed into production.
#
# Set up Local Variables
#
set -x
#
export PS4='MAR:$SECONDS + '
mkdir $DATA/MAR
cd $DATA/MAR
cp $FIXukmet/datatype.tbl datatype.tbl

mdl=ukmet
MDL="UKMETHR"
metatype="mar"
metaname="${mdl}_${res}_${metatype}_${cyc}.meta"
device="nc | ${metaname}"
PDY2=`echo $PDY | cut -c3-`
export HPCUKMET=${COMIN}/${RUN}.${PDY}/gempak

export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc << EOFplt
\$MAPFIL=mepowo.gsf+mehsuo.ncp+mereuo.ncp+mefbao.ncp
gdfile	= F-${MDL} | ${PDY2}/${cyc}00
gdattim	= fall
GAREA	= 15;-100;70;5
PROJ	= mer//3;3;0;1
MAP	= 31 + 6 + 3 + 5
LATLON	= 18/2/1/1/10
CONTUR	= 7
device	= $device 
GLEVEL	= 1000!0
GVCORD	= pres!none
PANEL	= 0
SKIP	= 0/2
SCALE	= 0
GDPFUN	= mag(kntv(wnd)) ! pmsl ! kntv(wnd@1000%pres)
TYPE	= c/f                  ! c          ! b
CINT	= 5/20!4
LINE	= 32/1/2/2!19//2
FINT	= 20;35;50;65
FLINE	= 0;24;25;30;15
HILO	= 0!20/H#;L#
HLSYM	= 0!1;1//22;22/3;3/hw
CLRBAR	= 1/V/LL!0
WIND	= bk9/0.6/2/112
REFVEC	=
TITLE   = 5/-2/~ ? ${MDL} PMSL & @ WIND|~ ATL PMSL & 1000mb Wind!0
TEXT	= 1.2/22/2/hw
CLEAR	= YES
li
run

GAREA	= 13;-84;50;-38
PROJ	= str/90;-67;1
LATLON	= 18/2/1/1/5;5
TITLE   = 5/-2/~ ? ${MDL} PMSL & @ WIND|~ WATL PMSL & 1000mb Wind!0
li
run

SKIP	= 0/1
GLEVEL  = 850:1000                  !0
GVCORD  = pres                      !none
SCALE   = -1                        ! 0
GDPFUN  = sub(hght@850,hght@1000) ! pmsl ! kntv(wnd@1000%pres)
TYPE    = c                             !  c         ! b
CINT    = 1                         ! 4
LINE    = 3/5/1/2                   ! 20//2
FINT    =
FLINE   =
HILO    = ! 26;2/H#;L#/1020-1070;900-1012//30;30/y
HLSYM   = 2;1.5//21//hw
CLRBAR  = 1
WIND    = bk9/0.7/2/112
TITLE   = 5/-2/~ ? ${MDL} UKMET PMSL, 1000-850 THK & 1000mb WIND|~ WATL PMSL & 1000-850 THK!0
li
run

GLEVEL  = 500
GVCORD  = PRES
SKIP    = 0                  
SCALE   = 5                  !-1
GDPFUN  = abs(avor(wnd))    !hght
TYPE    = c/f                !c
CINT    = 3/3/99             !6
LINE    = 7/5/1/2            !20/1/2/1
FINT    = 15;21;27;33;39;45;51;57
FLINE   = 0;23-15
HILO    = 2;6/X;N/10-99;10-99!          !
HLSYM   = 
WIND    = 
TITLE   = 5/-2/~ ? ${MDL} UKMET @ HEIGHTS & ABS VORTICITY|~ WATL 500mb HGHT & VORT!0
li
run

GAREA   = 15;-100;70;5
PROJ    = mer//3;3;0;1
LATLON  = 18/2/1/1/10
TITLE   = 5/-2/~ ? ${MDL} UKMET @ HEIGHTS & ABS VORTICITY|~ ATL 500mb HGHT & VORT!0
li
run

\$MAPFIL=mepowo.gsf+mehsuo.ncp+mereuo.ncp+himouo.nws
GAREA	= 4;120;69;-105
PROJ	= mer//3;3;0;1
LATLON	= 18/2/1/1/10
GLEVEL  = 1000!0
GVCORD  = pres!none
PANEL   = 0
SKIP    = 0/2
SCALE   = 0
GDPFUN  = mag(kntv(wnd)) ! pmsl ! kntv(wnd@1000%pres)
TYPE    = c/f                  ! c          ! b
CINT    = 5/20!4
LINE    = 32/1/2/2!19//2
FINT    = 20;35;50;65
FLINE   = 0;24;25;30;15
HILO    = 0!20/H#;L#
HLSYM   = 0!1;1//22;22/3;3/hw
CLRBAR  = 1/V/LL!0
WIND    = bk9/0.6/2/112
REFVEC  =
TITLE   = 5/-2/~ ? ${MDL} PMSL & @ WIND|~ PAC PMSL & 1000mb Wind!0
TEXT    = 1.2/22/2/hw
CLEAR   = YES
li
run

GAREA   = 11;-135;75;-98
PROJ    = str/90;-100;1
LATLON  = 18/2/1/1/5;5
TITLE   = 5/-2/~ ? ${MDL} PMSL & @ WIND|~ EPAC PMSL & 1000mb Wind!0
SKIP    = 0/1
li
run

GLEVEL  = 850:1000                  !0
GVCORD  = pres                      !none
SCALE   = -1                        ! 0
GDPFUN  = sub(hght@850,hght@1000) !pmsl ! kntv(wnd@1000%pres)
TYPE    = c                             ! c         ! b
CINT    = 1                         ! 4
LINE    = 3/5/1/2                   ! 20//2
FINT    =
FLINE   =
HILO    = ! 26;2/H#;L#/1020-1070;900-1012//30;30/y
HLSYM   = 2;1.5//21//hw
CLRBAR  = 1
WIND    = bk9/0.7/2/112
TITLE   = 5/-2/~ ? ${MDL} PMSL, 1000-850 THK & 1000mb WIND|~ EPAC PMSL & 1000-850 THK!0
li
run

GLEVEL  = 500
GVCORD  = PRES
SKIP    = 0                  
SCALE   = 5                  !-1
GDPFUN   = abs(avor(wnd))  !hght
TYPE    = c/f                !c
CINT    = 3/3/99             !6
LINE    = 7/5/1/2            !20/1/2/1
FINT    = 15;21;27;33;39;45;51;57
FLINE   = 0;23-15
HILO    = 2;6/X;N/10-99;10-99!          !
HLSYM   = 
WIND    = 0
TITLE   = 5/-2/~ ? ${MDL} @ HEIGHTS & ABS VORTICITY|~ EPAC 500mb HGHT & VORT!0
li
run

GAREA   = 4;120;69;-105
PROJ    = mer//3;3;0;1
LATLON  = 18/2/1/1/10
GLEVEL  = 500
GVCORD  = PRES
SKIP    = 0                  
SCALE   = 5                  !-1
GDPFUN  = abs(avor(wnd))    !hght
TYPE    = c/f                !c
CINT    = 3/3/99             !6
LINE    = 7/5/1/2            !20/1/2/1
FINT    = 15;21;27;33;39;45;51;57
FLINE   = 0;23-15
HILO    = 2;6/X;N/10-99;10-99!          !
HLSYM   = 
WIND    = 0
TITLE   = 5/-2/~ ? ${MDL} @ HEIGHTS & ABS VORTICITY|~ PAC 500mb HGHT & VORT!0
li
run
exit
EOFplt

export err=$?;err_chk
#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l $metaname
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
   cpfs ${metaname} ${COMOUT}/${mdl}_${res}_${PDY}_${cyc}_mar
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMOUT}/${mdl}_${res}_${PDY}_${cyc}_mar
   fi
fi

exit
