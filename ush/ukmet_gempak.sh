#!/bin/ksh

set -x

export PS4='$SECONDS + ' 
date

cd $DATA 

#
# Set up model and cycle specific variables
#
export fend=36
export finc=6
export fstart=06
export model=ukmet_early
export GRIB=ukmet
export EXT=""

#
# FIRST RUN FOR GLOBAL GRIDS
#
########################################################
# Execute the script.
$USHukmet/ukmet_nawips.sh
########################################################

#
# NOW RUN A SECOND TIME TO CREATE THE TROPICAL GRIDS
#
export RUN=ukmet2
export GRIB=ukm25f
export fstart=96
export fend=144
export finc=24
cp $COMIN/ukmet.${cycle}.${GRIB}72 ukmet2.grib
ls -l ukmet2.grib
err=$?; err_chk
########################################################
# Execute the script.
$USHukmet/ukmet_nawips.sh
########################################################

date

exit
