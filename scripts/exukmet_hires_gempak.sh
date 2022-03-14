#!/bin/sh
#####################################################################
echo "------------------------------------------------"
echo "JUKMET_HIRES_GEMPAK - UKMET HIRES postprocessing"
echo "------------------------------------------------"
echo "History: JUL 2008 - Create UKMET HiRes GEMPAK output        "
echo "                    from GRIB1 tiled data                   "
#####################################################################

set -x

# ------------------------------------------------------------------------
# Set up current date/time variables.
# -----------------------------------------------------------------------

cd $DATA
export PDY2=`echo $PDY | cut -c3-`
CYC=$cyc

########################################
set -x
msg="HAS BEGUN!"
postmsg "$jlogfile" "$msg"
########################################

# -----------------------------------------------------------------------
# We will assume that this script will be set off 4 times, at 
# 18, 48, 84, and 144 hours.  This is based on the current average 
# timing of the grib file arrival on the CCS.  
#
# Update 8/2010 - Propose running it a 5th time, at 18,42,72,108 and 
#                 144 hours to account for new file times.
#
# The forecast hours/files processed will depend on the input argument
# -----------------------------------------------------------------------
#
# New hours - QQT - F078
#           - TTT - F090
#           - UUT - F102
#           - VVT - F114
#           - 11T - F126
#           - 22T - F138

fhr_proc=$1

rm -f poescript

#echo "#!/bin/ksh" > poescript
if [ $fhr_proc -eq 18 ]; then
    $USHukmet/ukmet_hires_gempak.sh AAT anl 000
    $USHukmet/ukmet_hires_gempak.sh BBT 6 006
    $USHukmet/ukmet_hires_gempak.sh CCT 12 012
    $USHukmet/ukmet_hires_gempak.sh DDT 18 018
#    echo "hostname" >> poescript
#    echo "hostname" >> poescript
elif [ $fhr_proc -eq 42 ]; then
    $USHukmet/ukmet_hires_gempak.sh EET 24 024
    $USHukmet/ukmet_hires_gempak.sh FFT 30 030
    $USHukmet/ukmet_hires_gempak.sh GGT 36 036
    $USHukmet/ukmet_hires_gempak.sh HHT 42 042
#    echo "hostname" >> poescript
#    echo "hostname" >> poescript
elif [ $fhr_proc -eq 72 ]; then
    $USHukmet/ukmet_hires_gempak.sh IIT 48 048
    $USHukmet/ukmet_hires_gempak.sh JJT 54 054
    $USHukmet/ukmet_hires_gempak.sh JJT 60 060
    $USHukmet/ukmet_hires_gempak.sh KKT 66 066
    $USHukmet/ukmet_hires_gempak.sh KKT 72 072
#    echo "hostname" >> poescript
elif [ $fhr_proc -eq 108 ]; then
    $USHukmet/ukmet_hires_gempak.sh QQT 78 078
    $USHukmet/ukmet_hires_gempak.sh LLT 84 084
    $USHukmet/ukmet_hires_gempak.sh TTT 90 090
    $USHukmet/ukmet_hires_gempak.sh MMT 96 096
    $USHukmet/ukmet_hires_gempak.sh UUT 102 102
    $USHukmet/ukmet_hires_gempak.sh NNT 108 108
elif [ $fhr_proc -eq 144 ]; then
    $USHukmet/ukmet_hires_gempak.sh VVT 114 114
    $USHukmet/ukmet_hires_gempak.sh OOT 120 120
    $USHukmet/ukmet_hires_gempak.sh 11T 126 126
    $USHukmet/ukmet_hires_gempak.sh 22T 138 138
    $USHukmet/ukmet_hires_gempak.sh PPA 132 132
    $USHukmet/ukmet_hires_gempak.sh PPA 144 144
fi

export err=$?; err_chk


#####################################################################
# GOOD RUN
set +x
echo "**************job UKMET HIRES GEMPAK COMPLETED NORMALLY ON THE IBM"
echo "**************job UKMET HIRES GEMPAK COMPLETED NORMALLY ON THE IBM"
echo "**************job UKMET HIRES GEMPAK COMPLETED NORMALLY ON THE IBM"
set -x
#####################################################################


msg="HAS COMPLETED NORMALLY!"
echo $msg
postmsg "$jlogfile" "$msg"

############## END OF SCRIPT #######################
