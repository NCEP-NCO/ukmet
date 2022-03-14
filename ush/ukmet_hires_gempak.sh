#!/bin/ksh
#####################################################################
echo "------------------------------------------------"
echo "JUKMET_HIRES_GEMPAK - UKMET HIRES postprocessing"
echo "------------------------------------------------"
echo "History: JUL 2008 - Create UKMET HiRes GEMPAK output        "
echo "                    from GRIB1 tiled data                   "
#####################################################################

set -x

export extns=$1
export FH=$2
export fhrlp=$3

mkdir -m 775 $DATA/$fhrlp
cd $DATA/$fhrlp

echo "CYC"=$CYC

ic=0
while [ ! -e $DCOMIN/GAB${CYC}${extns}.GRB ]
do
  let ic=ic+1
  if [ $ic -gt 4 ]; then
    echo "FATAL ERROR: $DCOMIN/GAB${CYC}${extns}.GRB is not available after 1 hour waiting!"
    export err=99; err_chk
  fi
  sleep 900
done # loop if no dcom file exist
fname="GAB${CYC}${extns}.GRB"
cp $DCOMIN/$fname .

pad="fh"

for tile in 0 1 2 3 4 5 6 7
do
  $WGRIB -s $fname | awk '{if ($1 % 8 == '"$tile"' && $6 ~/'"$FH"'/ ) print $0}' FS=":" | $WGRIB -i $fname -o ukmet.${PDY}.t${CYC}z.${pad}$fhrlp.${tile} -grib
  export err=`expr $err + $?`
done # loop through tiles to get grib files
 
# --------------------------------------------------------------------------------------           
# Loop through the forecast hours and run nagrib_nc to convert the grib1 data to grids.
# --------------------------------------------------------------------------------------
        
fhr=$fhrlp
fhrval=fh$fhr

for tile in 0 1 2 3 4 5 6 7
do
  gbfile=ukmet.$PDY.t${CYC}z.$fhrval.$tile
  gdoutf=ukmet_${PDY}_F${fhr}_${tile}.grd

  $GEMEXE/nagrib_nc << EOF
  gbfile  = $gbfile
  indxfl  =
  gdoutf  = $gdoutf
  proj    =
  grdarea =
  kxky    =
  maxgrd  = 300
  cpyfil  = gds
  garea   =
  output  = t
  gbtbls  =
  gbdiag  =
  pdsext  = yes
  overwr  = yes
  run

  exit
EOF

done # loop through tiles

# ---------------------------------------------------------------------------------------------------------
# We now have the grib files converted to grids...8 tiles per forecast hour
# Create new grid files to hold the mosaicked grids and initialize all
# parameters to 0.  For forecast hours up through 120...there are 73 parameters in the grid files.
# For fhr=132 and 144...there are only 12.
#
# Currently, chosing a grid that is .75x.75 degree resolution to map to.  This is not an exact
# match to stitching the tiles together, but is adequate. 
#
# To create the new grids easily, run gddiag.  gddiag needs an input file to start...so will use
# one just created from the nagrib above.
# ---------------------------------------------------------------------------------------------------------

filnam=`ls -1 *.grd | tail -1`

# -----------------------------------------------------------------------------
# Begin creation of the final grid files with 0 value for each parameter
# Pull over UKMET mask grid on the output grid navigation to use later
# -----------------------------------------------------------------------------
     
cp ${FIXukmet}/ukmet_mask.grd .

gdoutf_tmp=ukmet_${res}_${PDY}${CYC}f${fhr}_tmp
gdoutf=ukmet_${res}_${PDY}${CYC}f${fhr}
gdatout=${PDY2}/${CYC}00F${fhr}

# -----------------------------------------------------------------
# Set levels, parameters, vertical coordinates dependent on fhour
# Forecast hours 132 and 144 have considerably fewer parameters
# -----------------------------------------------------------------
  
if [ $fhr -lt 078 -o $fhr -eq 084 -o $fhr -eq 096 -o $fhr -eq 108 -o $fhr -eq 120 ]; then
  levels="1000 950 925 850 700 500 400 300 250 200 150 100 0"
  parms_sfc="PMSL SPFH TMPK TMNK TMXK PRXX PXXM UREL VREL SNIR \
             TPRES TTMPK MUREL MVREL MPRES"
elif [ $fhr -eq 132 -o $fhr -eq 144 ]; then
  levels="1000 850 700 500 0"
  parms_sfc="TMPK UREL VREL PMSL TMNK TMXK PXXM"
else
  levels="300 200 0"
  parms_sfc="PMSL SPFH TMPK TMNK TMXK PXXM UREL VREL"
fi 

# ------------------------------------
# Process everything above level 0
# Initialize all grids to 0.
# ------------------------------------

for lev in $levels
do

  if [ $lev = "0" ]; then
    parms=$parms_sfc
  elif [ $lev -ne 0 ] && [ $fhr -lt 078 -o $fhr -eq 084 -o $fhr -eq 096 -o $fhr -eq 108 -o $fhr -eq 120 ]; then
    parms="HGHT TMPK UREL VREL RELH"
  elif [ $lev -ne 0 ] && [ $fhr -eq 078 -o $fhr -eq 090 -o $fhr -eq 102 -o $fhr -eq 114 -o $fhr -eq 126 -o $fhr -eq 138 ]; then
    parms="UREL VREL"
  else
    if [ $lev = "1000" -o $lev = "500" ]; then
      parms="HGHT"
    else
      parms="TMPK UREL VREL"
    fi
  fi

  for parm in $parms
  do

    fnlparm=$parm
    if [ $lev != "0" ]; then
      vcord="PRES"
    else
      vcord="NONE"
      if [ $parm = "TPRES" ]; then
        vcord=trop
        fnlparm=PRES
      elif [ $parm = "TTMPK" ]; then
        vcord=trop
        fnlparm=TMPK
      elif [ $parm = "MUREL" ]; then
        vcord=mwsl
        fnlparm=UREL
      elif [ $parm = "MVREL" ]; then
        vcord=mwsl
        fnlparm=VREL
      elif [ $parm = "MPRES" ]; then
        vcord=mwsl
        fnlparm=PRES
      elif [ $parm = "PXXM" ]; then
        if [ $fhr -gt 0 -a $fhr -lt 54 ]; then
          fnlparm=P06M
        elif [ $fhr -gt 0 ] && [ $fhr -eq 078 -o $fhr -eq 090 -o $fhr -eq 102 -o $fhr -eq 114 -o $fhr -eq 126 -o $fhr -eq 138 ]; then
          fnlparm=P06M
        elif [ $fhr -gt 0 -a $fhr -ge 54 ] ; then
          fnlparm=P12M
        fi
      fi
    fi

    $GEMEXE/gddiag << EOF
    gdfile  = $filnam
    gdoutf  = $gdoutf_tmp
    gfunc   = 0
    gdattim = first
    glevel  = $lev
    gvcord  = $vcord
    grdnam  = $fnlparm^$gdatout
    grdtyp  = s
    gpack   = none
    grdhdr  = 0/0
    proj    = CED/0;0;0
    grdarea = -90.00;0.00;90.00;-0.66667
    kxky    = 540;271
    maxgrd  = 500
    cpyfil  =
    anlyss  = 4/2;2;2;2
    run
 
EOF
    # ----------------------------------------------------------------------
    # Loop through the 8 tiles, running gddiag to remap the tiles to the
    # grid of currently 0 values.
    # GFUNC=ADD(PARAMETER,MISS(PARAMETER+2,0)).  This changes any missing
    # values to 0, then adds the parameter to the mosaicked field.  This
    # will either be the parameter or 0 if outside the tile.  In this way...
    # each tile's values are preserved on the big grid as it loops through.
    # ----------------------------------------------------------------------

    rm -f procfile.sh.$fhrlp
    echo "$GEMEXE/gddiag << EOF" >> procfile.sh.$fhrlp

    for tile in 0 1 2 3 4 5 6 7
    do
       cat >> procfile.sh.$fhrlp << EOF10
       gdfile  = $gdoutf_tmp + ukmet_${PDY}_f${fhr}_${tile}.grd
       gdoutf  = $gdoutf_tmp
       gfunc   = add($fnlparm,miss($fnlparm+2,0))
       gdattim = $gdatout
       glevel  = $lev
       gvcord  = $vcord
       grdnam  = $fnlparm^$gdatout
       grdtyp  = s
       gpack   = none
       grdhdr  = 0/0
       proj    =
       grdarea =
       kxky    =
       maxgrd  =
       cpyfil  =
       anlyss  = 4/2;2;2;2
       run

EOF10
    done  # Looping through the tiles
    echo "EOF" >> procfile.sh.$fhrlp
    sh procfile.sh.$fhrlp

    #---------------------------------------------------------------------------------------------------------
    # However...there is a problem with the mosaic.  When remapped, there are missing values
    # on the grid boundaries.  We need to use a mask grid that is populated with 1's where there are
    # values and zeros where there aren't.  Break down the gfunc.
    #    This statement "quo(sm9s(parm),sm9s(msk+2^000101/0000F000))" smooths the mask and parm fields
    #    and divides them.  This leaves the parm field intact over most areas...but modifies the zero values
    #
    #    The statement: sub(1,msk+2^000101/0000F000) either evaluates to 1 if the mask value is 0...or 0
    #    if the mask value is 1.
    #
    #    mul(sub(1,msk+2^000101/0000F000),quo(sm9s(parm),sm9s(msk+2^000101/0000F000)) multiplies a 0 or 1
    #    by the interpolated value of the smoothed field.  In most cases, this is 0 since the mask value
    #    is 1 everywhere but the boundaries.
    #    Then the parm field is added to the interpolated value to get the output field.
    #--------------------------------------------------------------------------------------------------------

    $GEMEXE/gddiag << EOF
    gdfile  = $gdoutf_tmp + ukmet_mask.grd
    gdoutf  = $gdoutf
    gdattim = $gdatout
    glevel  = $lev
    gvcord  = $vcord
    gfunc   = add(mul(sub(1,msk+2@0%none^000101/0000F000),quo(sm9s($fnlparm),sm9s(msk+2@0%none^000101/0000F000))),$fnlparm)
    grdnam  = $fnlparm@$lev%$vcord^$gdatout
    grdtyp  = s
    gpack   = none
    grdhdr  = 0/0
    proj    =
    grdarea =
    kxky    =
    maxgrd  = 500
    cpyfil  = $gdoutf_tmp
    anlyss  = 4/2;2;2;2
    run

    exit
EOF
    #---------------------------------------------------------------------------------------------------------
    # Want to create P06M grids for those forecast hours in which the UKMET provides P12M.  To do this, 
    # we will need to subtract the P06M of the previous grid time from the P12M of the current grid file.
    # For example:
    #   To get the P06M valid at F054, subtract P12M^F054 from P06M^F048 and write the P06M into the F054
    #   grid file.  This means we need, in this case, the F048 hour grid to be present AND P06M to be in
    #   that grid file (as well as the P12M in F054).  For now, I will assume this the case. 
    #
    # I've set the list of hours to process (above) to try to ensure that the necessary files will be 
    # available.
    #---------------------------------------------------------------------------------------------------------
    
    # WANT TO ADD P06M TO FILES THAT CURRENTLY ONLY HAVE P12M.
    # 
    if [ $fnlparm = "P12M" ]; then
      process_p12m=0

      # ---- Get forecast hour from 6 hours ago --------------
        pfhr_tmp=`expr $fhr - 6`
        pfhr=$pfhr_tmp  
        if [ $pfhr_tmp -lt 100 ]; then
             pfhr="0${pfhr_tmp}"
        fi
          
      # ---------- Determine if file from 6 hours ago is available, then process --------------------
        icnt=0
        while [ ! -f $DATA/ukmet_${res}_${PDY}${CYC}f${pfhr}.done ]
        do
          let icnt=$icnt+1
          if [ $icnt -gt 360 ]; then
            echo " Waiting ukmet_${res}_${PDY}${CYC}f${pfhr} for more than half hour!"
            export err=9; err_chk
          fi
          sleep 5
        done
        $GEMEXE/gddiag << EOF
        gdfile  = $gdoutf + $DATA/ukmet_${res}_${PDY}${CYC}f${pfhr}
        gdoutf  = $gdoutf
        gdattim = $gdatout
        glevel  = 0
        gvcord  = none
        gfunc   = sub(P12M,P06M+2^${PDY2}/${CYC}00F${pfhr})
        grdnam  = P06M^$gdatout
        grdtyp  = s
        gpack   = none
        grdhdr  = 0/0
        run

        exit
EOF
   
    fi 
  done  #Looping through the parameters.
done      #Looping through the levels.

mv ukmet_${res}_${PDY}${CYC}f${fhr} $DATA/

echo "done" > $DATA/ukmet_${res}_${PDY}${CYC}f${fhr}.done
# Move to COMOUT directory

if test "$SENDCOM" = 'YES'
then
  cp ${DATA}/ukmet_${res}_${PDY}${CYC}f${fhr}  ${COMOUT}/ukmet_${res}_${PDY}${CYC}f${fhr}
  export err=`expr $err + $?`
fi

err_chk

# Send DBNet alert

if test "$SENDDBN" = 'YES'
then
    $DBNROOT/bin/dbn_alert MODEL UKMET_HIRES_GEMPAK ukmet_hires_gempak $COMOUT/ukmet_${res}_${PDY}${CYC}f${fhr}
fi
