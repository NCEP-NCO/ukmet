#!/bin/ksh
#
# Metafile Script : ukmet_hires_meta.sh
#
# Script to create a metafile for the high resolution UKMET data.
#
# Log :
# M. Klein	08/13/2008	Creation.
# M. Klein      08/15/2008      Add metafile for Atlantic tropical region.
# M. Klein      11/17/2008      Fix display of 500mb hght/vort.
# M. Klein      11/18/2008      Only display 500mb height for F132-F144.
# M. Klein      01/14/2010      Add Alaska region display.
# M. Klein/HPC  02/18/2010      Set dbnet alert to environment variable set in .cshrc
# M. Klein/HPC  08/24/2010      Add additional parameters with new available forecast hours
# M. Klein/HPC  04/04/2011      Correct for RHEL5 (octal issue).
# M. Klein/HPC  04/05/2011      Bug fix.
# M. Klein/HPC  12/16/2011      Move to compute farm...but do not implement.
# M. Klein/HPC  01/14/2013      Add 6-hour PCPN/1000-500 thk overlay.
# M. Klein/HPC  01/15/2013      Slight modification to map navigation for 1/14 entry.
# M. Klein/HPC  07/25/2013      Change $MODEL directory for UK data.
# M. Klein/WPC  06/12/2014      Add South America region.
# M. Klein/WPC  10/21/2016      Correct error in 6-hour precip for AK.

#
# Set up local variables and see if the script is already running.
#

cd $DATA

set -xa

PDY2=`echo $PDY | cut -c3-`
modtitle="UKMET"

#
# GET DATE AND TIME. DETERMINE CYCLE BASED ON CURRENT TIME.
#

export HPCUKMET=$COMIN/${RUN}.${PDY}/gempak

mn=$(date -u +%m)

fhrs="000 006 012 018 024 030 036 042 048 054 060 066 072 078 084 090 096 102 108 114 120 126 132 138 144"

mod="ukmet_hr"
metamod="ukmet"
modtitle="UKMET"

    numfiles=0
    fnl_hr="000"
    set -A mylist
    for hr in $fhrs
    do
      if [[ -f ${COMIN}/${RUN}.${PDY}/gempak/${mod}_${PDY}${cyc}f${hr} ]]; then
        mylist[${#mylist[*]}+1]=${hr}
        fnl_hr=${hr}
        numfiles=$(( $numfiles + 1 ))
      fi
    done
    echo "${mylist[*]}"

    metafiles="us trop ak sa"
    #metafiles="us"

    # 
    # BEGIN GENERATION OF THE METAFILES
    #

    for metafl in ${metafiles}
    do
        metafile="${metamod}.meta.${metafl}"
        echo " \n Generating ${metafile} metafile...."
	if [[ -f ${metafile} ]]; then
          rm -f ${metafile}
        fi
	device="nc | ${metafile}"
        export pgm=gdplot2_nc;. prep_step; startmsg

     
        garea_pcpn="bwus"
        proj_pcpn=" "
        qpfparm_24hr="p24i"
        qpfparm_6hr="p06i"
        qpf_fint=".01;.1;.25;.5;.75;1;1.25;1.5;1.75;2;2.5;3;4;5;6;7;8;9"
        if [[ ${metafl} = "us" ]]; then
	    garea="17.529;-129.296;53.771;-22.374"
	    proj="str/90;-105;0"
	    latlon="18/2"
        elif [[ ${metafl} = "ak" ]]; then
	    garea="35.0;178.0;78.0;-94.0"
	    proj="NPS"
	    latlon="18/2/1/1;1/10;10"
	    garea_pcpn="35.0;178.0;78.0;-94.0"
	    proj_pcpn="NPS"
        elif [[ ${metafl} = "sa" ]]; then
	    garea="-66.0;-127.0;14.5;-19.0"
	    proj="mer//3;3;0;1"
	    latlon="1//1/1/10"
            garea_pcpn="-66.0;-127.0;14.5;-19.0"
            proj_pcpn="mer//3;3;0;1"
            qpfparm_24hr="p24m"
            qpfparm_6hr="p06m"
            qpf_fint="1;5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80;85"
	else 
	    garea="-6;-111;52;-14"
	    proj="MER/0.0;-49.5;0.0"
	    latlon="1//1/1/10"
	fi
     
        for fhr in ${mylist[*]}
        do
            gdfile="F-UKMETHR | ${PDY2}/${cyc}00"

    # NOTE THAT FOR FHRS 132 AND 144, THERE ARE LIMITED FIELDS...DO NOT CREATE 
    # IMAGES FOR THOSE FIELDS NOT PRESENT

            run="run"
	    runoff="run"
	    run_500=""
	    gdp_500vort="abs(avor(wnd))  !abs(avor(wnd))  !hght"

	    if [[ ${fhr} = "132" || ${fhr} = "144" ]]; then
	        run=""
		runoff=""
	        run_500="run"
		gdp_500vort="sm5s(abs(avor(geo))) !sm5s(abs(avor(geo))) !hght"
	    fi

	    if [[ ${fhr} = "078" || ${fhr} = "090" || ${fhr} = "102" || ${fhr} = "114" || ${fhr} = "126" || ${fhr} = "138" ]]; then
	        runoff=""
            fi	    

            if (( $mn < 4 || $mn > 9 )); then
              fint_temp="0;5;10;15;20;25;30;35;40;45;50;55;60;65;70"
              fint_min="-15;-10;-5;0;5;10;15;20;25;30;35;40;45;50;55"
            else
              fint_temp="30;35;40;45;50;55;60;65;70;75;80;85;90;95;100"
              fint_min="20;25;30;35;40;45;50;55;60;65;70;75;80;85;90"
            fi
	    fint_max=${fint_temp}

            if [[ ${metafl} = "us" || ${metafl} = "ak" || ${metafl} = "sa" ]] then
                gdplot2_nc << EOF
                 \$MAPFIL= mepowo.gsf
                 gdfile  = ${gdfile}
                 gdattim = f${fhr}
                 device  = ${device}
                 panel   = 0
                 text    = 1/21//hw
                 contur  = 2
                 map     = 1/1/1/yes
                 clear   = y
                 clrbar  = 1
                 garea   = ${garea}
                 proj    = ${proj}
                 latlon  = ${latlon}
	         filter  = yes

                 glevel  = 500   !500    !0
                 gvcord  = pres  !pres   !none
                 skip    = 0
                 scale   = -1    !-1     !0
                 gdpfun  = sub(hght,hght@1000)  !sub(hght,hght@1000)   !sm5s(pmsl)
                 type    = c
                 cint    = 6/0/540 ! 6/546/999        ! 4         
                 line    = 6/3/2   ! 2/3/2            ! 20//3
                 fint    =
                 fline   =
                 hilo    = !! 26;2/H#;L#///30;30/y
                 hlsym   = 2;1.5//21//hw
                 title   = 1/-2/~ ? ${modtitle} HI RES PMSL, 1000-500MB THKN|~MSLP,1000-500 THKN !0
                 run

                 glevel  = 850
                 gvcord  = pres
                 panel   = 0 
                 scale   = 0         !0         !0         !-1        !0
                 skip    = 0         !0         !0         !0         !0/1;-1
                 gdpfun  = sm5s(tmpc)!sm5s(tmpc)!sm5s(tmpc)!sm5s(hght)!kntv(wnd)
                 type    = c/f       !c         !c         !c         !b
                 contur  = 3
                 cint    = 3/-99/50  !3/3/18    !3/21/99   !3
                 line    = 27/1/2    !2/1/2    !16/1/2   !20/1/1/1
                 fint    = -24;-18;-12;-6; 0;18
                 fline   = 24; 30; 28;29;25; 0;17
                 hilo    = 0
                 hlsym   =
                 wind    = 18//1
                 refvec  =
                 title   = 1/-2/~ ? ${modtitle} HI RES 850 MB HEIGHTS, TEMPERATURE AND WIND (KTS)|~@ HGT,TMP,WIND
                 ${runoff}

                 ${run_500}
		 
                 glevel  = 700
                 gvcord  = pres
                 skip    = 0              !0              !0           !0/1;-1
                 scale   = 0              !0              !-1          !0          
                 gdpfun  = sm5s(relh)     !sm5s(relh)     !sm5s(hght)  !kntv(wnd) 
                 type    = c              !c/f            !c           !b
                 contur  = 2
                 cint    = 10;30          !50;70;90       !3          
                 line    = 8//2/0         !23//2/0        !20/1/1/1  
                 fint    = 70;90
                 fline   = 0;23;22
	         wind    = 18//1
                 hilo    = 0
                 hlsym   = 0
                 clrbar  = 1
                 title   = 1/-2/~ ? ${modtitle} HI RES 700 MB HGTS, RELATIVE HUMIDITY AND WINDS|~@ HGT, RH AND WINDS!
                 ${runoff}

                 glevel  = 500
                 gvcord  = pres
	         scale   = 5               !5               !-1
	         gdpfun  = ${gdp_500vort}
	         type    = c/f             !c               !c
	         cint    = 2/10/20         !2/4/8           !6
	         line    = 7/5/1/2         !29/5/1/2        !5/1/2/1
                 fint    = 16;20;24;28;32;36;40;44
                 fline   = 0;23-15
                 hilo    = 2;6/X;N/10-99;10-99 ! !
                 hlsym   = 
                 wind    =
                 title   = 1/-2/~ ? ${modtitle} HI RES 500 MB HEIGHT AND ABS VORTICITY|~@ HGT AND VORTICITY!0 
                 ${runoff}

	         ${run_500}

                 skip    = 0                !0        !0               !0               !0/2
                 scale   = 0                !0        !0               !-1              !0
                 gdpfun  = mag(kntv(wnd))   !tmpc     !tmpc            !hght            !kntv(wnd)
                 type    = f                !c        !c               !c               !b
                 contur  = 2
                 cint    =                  !2/-38/50 !2/-70/-40       !6
                 line    =                  !2/12/2/2 !6/12/2/2        !1/1/2
                 fint    = 60;65;70;75;80;85;90;95;100;105;110;115;120;125;130
                 fline   = 0;23-1
                 hilo    =
                 hlsym   =
                 clrbar  = 1
                 wind    = 18/1/1
                 title   = 1/-2/~ ? ${modtitle} HI RES 500 MB HEIGHT, TEMPERATURE AND WINDS|~@ HGHT,TMP,WIND         
                 ${runoff}

                 glevel  = 250
                 skip    = 0
                 scale   = 0                             !-1          !0
                 gdpfun  = knts((mag(wnd)))              !sm5s(hght)  !kntv(wnd)
                 type    = c/f                           !c           !b
                 contur  = 2                             !2
                 cint    = 30;50;70;90;110;130;150       !12
                 line    = 27/5/2/1                      !20/1/2/1
                 fint    = 70;90;110;130;150
                 fline   = 0;25;24;29;7;15
                 hilo    =
                 hlsym   = 
                 wind    = 18/1/1
                 title   = 1/-2/~ ? ${modtitle} HI RES 250 MB HEIGHTS, ISOTACHS AND WIND (KTS)|~@ HGT AND WIND!0
                 ${runoff} 

                 garea    = ${garea_pcpn}
                 proj     = ${proj_pcpn}
                 glevel   = 0   !500:1000       !500:1000       !0
                 gvcord   = none!pres           !pres           !none
                 scale    = 0   !-1             !-1             !0
                 gdpfun   = ${qpfparm_6hr} !sm5s(ldf(hght))!sm5s(ldf(hght))!sm5s(pmsl)
                 type     = f   !c              !c
                 cint     =     !3/0/540        !3/543/1000     !4
                 line     =     !4/5/2          !2/5/2          !19//3
                 fint     = ${qpf_fint}
                 fline    = 0;21-30;14-20;5
                 hilo     = 0   !0              !0!19/H#;L#/1020-1070;900-1012
                 hlsym    = 0   !0              !0!1.3;1.3//22;22/3;3/hw
                 clrbar   = 1
                 wind     =
                 title    = 1/-2/~ ? ${modtitle} HI RES 6-H PCPN, PMSL, 1000-500 MB THK|~6-H PCPN & 1000-500 THK!0
                 run

                 garea   = ${garea}
                 proj    = ${proj}
                 glevel  = 500                     !500                     !0
                 scale   = 0
                 gvcord  = pres                    !pres                    !none
                 gdpfun  = lyr_swtm(relh|1000-500) !lyr_swtm(relh|1000-500) !pmsl
                 type    = c/f                     !c                       !c
                 cint    = 50;70;90;95             !                        !4
                 line    = 32//2/0                 !                        !5/1/2
                 fint    = 50;70;90
                 fline   = 0;24;23;22
                 hilo    =  !! 26;2/H#;L#/1018-1070;900-1012//30;30/y
                 hlsym   = !! 2;1.5//21//hw
                 clrbar  = 1
                 title   = 1/-2/~ ? ${modtitle} HI RES PMSL, 1000-500 MB MEAN RH|~1000-500MB MEAN RH,PMSL!0
                 ${runoff}

                 glevel  = 500                     !500                     !850       !850        !0          !0
                 scale   = 0                       !0                       !0
                 gvcord  = pres                    !pres                    !pres      !pres       !none
                 gdpfun  = lyr_swtm(relh|1000-500) !lyr_swtm(relh|1000-500) !tmpc      !tmpc       !sm5s(tmpc) !sm5s(tmpc)
                 type    = c/f                     !c                       !c         !c
                 cint    = 50;70;90;95             !                        !2;-2      !200;0      !2;-2       !200;0
                 line    = 32//2/0                 !                        !2/2/2     !2/1/2      !20/2/2     !20/1/2
                 fint    = 50;70;90
                 fline   = 0;24;23;22
                 hilo    = 0
                 hlsym   = 0
                 clrbar  = 1
                 title   = 1/-2/~ ? ${modtitle} HI RES PMSL, 1000-500 MB MEAN RH, T (SFC yel,850 red)|~1000-500MB RH,R/S TEMP!0
                 ${runoff}

                 glevel  = 0
                 gvcord  = none
                 scale   = 0
                 gdpfun  = sm5s(pmsl) !kntv(wnd)
                 type    = c          !b
                 cint    = 4
                 line    = 5//3
                 fint    = 50;56;62;68;74
                 fline   = 0;23;22;30;14;2
                 hilo    = 5/H#;L#/1020-1060;900-1012
                 hlsym   = 1.3;1.3//22/3/hw
                 clrbar  = 0
                 wind    = bk9/0.8/2/112
                 title   = 1/-2/~ ? ${modtitle} HI RES BL WIND (KTS) AND PMSL|~BL WIND AND PMSL!0
                 run         

                 gdpfun  = sm9s(add(mul((sub(tmpk,273),1.8)32)
                 type    = c/f
                 contur  = 1
                 cint    = 5/-50/130
                 line    = 32/1/2/1
                 fint    = ${fint_temp}
                 fline   = 30;29;28;27;24;23;22;21;20;19;18;17;16;14;12;1
                 hilo    = 0
                 hlsym   = 0
                 clrbar  = 1
                 wind    = 0
                 title   = 1/-2/~ ? ${modtitle} HI RES 2-METER TEMPERATURE (F)|~2-METER TEMP!0
                 run

                 exit
EOF

            else
                gdplot2_nc << EOF
                 \$MAPFIL = mepowo.gsf
                 gdfile  = ${gdfile}
                 gdattim = f${fhr}
                 device  = ${device}
                 panel   = 0
                 text    = 1/21//hw
                 contur  = 2
                 map     = 1/1/1/yes
                 clear   = y
                 clrbar  = 1
                 garea   = ${garea}
                 proj    = ${proj}
                 latlon  = ${latlon}

                 glevel  = 0
                 gvcord  = none
                 scale   = 0
	         skip    = 0
                 gdpfun  = mag(kntv(wnd))   !sm5s(pmsl)   !kntv(wnd)
                 type    = c/f              !c            !b
                 cint    = 5/20             !2
                 line    = 32/1/2/2         !19//2
                 fint    = 20;35;50;65
                 fline   = 0;24;25;30;15
                 hilo    = 0                !20/H#;L#/1020-1060;880-1012///1
                 hlsym   = 0                !1;1//22;22/3;3/hw
                 clrbar  = 1/V/LL           !0
                 wind    = bk0              !bk0          !bk9/0.8/1.4/112
                 title   = 1/-2/~ ? ${modtitle} HI RES PMSL, BL WIND (KTS)|~PMSL AND BL WIND!0
                 run         

	         glevel  = 850
	         gvcord  = pres
	         scale   = 5                   !5            !0              !-1
	         skip    = 0                   !0            !0/1;-1         !0
	         gdpfun  = vor(wnd)            !vor(wnd)     !kntv(wnd)      !sm5s(hght)
	         type    = c/f                 !c            !b              !c
	         cint    = 2/-99/-2            !2/2/99       !0              !3
	         line    = 29/5/1/2            !7/5/1/2      !               !6/1/1
	         fint    = 4;6;8;10;12;14;16;18
	         fline   = 0;14-21
	         hilo    = 2;6/X;N/-99--4;4-99 !0             
	         hlsym   = 1;1//22;22/3;3/hw
	         wind    = bk0                 !bk0          !bk9/.8/1.4/112 !bk0
	         title   = 1/-2/~ ? ${modtitle} HI RES @ MB HEIGHTS, WINDS AND RELATIVE VORTICITY|~@ HGT, WIND, REL VORT!0
	         ${runoff}

                 ${run_500}
		 
	         glevel  = 700
	         ${runoff}

		 ${run_500}
          
	         glevel  = 500
	         gdpfun  = avor(wnd)           !avor(wnd)           !kntv(wnd)      !sm5s(hght)
	         cint    = 2/-99/-2            !2/2/99              !0              !2
	         line    = 29/5/1/2            !7/5/1/2             !0              !20/1/2/1
	         fint    = 16;20;24;28;32;36;40;44
	         fline   = 0;23-15
	         hilo    = 2;6/X;N/-99--4;4-99 !                    !
	         hlsym   = 1;1//22;22/3;3/hw   !
                 title   = 1/-2/~ ? ${modtitle} HI RES @ MB HEIGHTS, WINDS AND ABSOLUTE VORTICITY|~@ HGT, WIND, ABS VORT!0
	         ${runoff}

	         glevel  = 250
	         cint    = 2/-99/-2            !2/2/99              !0              !4
	         ${runoff}

	         glevel  = 300:850        !850       !300
	         gvcord  = pres
      	         scale   = 0
	         skip    = 0              !0/3;3     !0/3;3
	         gdpfun  = mag(vldf(obs)) !kntv(wnd) !kntv(wnd)
	         type    = c/f            !a         !a
	         cint    = 5/20
	         line    = 26//1
	         fint    = 5/25
	         fline   = 0;24;30;29;23;22;14;15;16;17;20;5
	         hilo    =
	         hlsym   =
	         wind    = ak0            !ak7/.1/1/221/.2  !ak6/.1/1/221/.2
	         filter  = no
	         title   = 1/-2/~ ? ${modtitle} HI RES @ WIND SHEAR (850=Purple, 300=Cyan) |~850-300MB WIND SHEAR!0
	         ${runoff}

                 glevel  = 250
	         gvcord  = pres
	         scale   = 0                   !5            !5
	         skip    = 0                   !0            !0            !0/2;2
	         gdpfun  = mag(kntv(wnd))      !div(wnd)     !div(wnd)     !kntv(wnd)
	         type    = c/f                 !c            !c            !b
	         cint    = 20/30/190           !2/-13/-3     !2/3/18
	         line    = 26/1/2              !19/2/2       !3/1/2
	         fint    = 50;70;90;110;130;150;170
	         fline   = 0;24;25;29;7;15;14;2
	         wind    = bk0                 !bk0          !bk0          !bk9/.8/1.3/112
	         refvec  = 10
	         filter  = yes
	         title   = 1/-2/~ ? ${modtitle} HI RES @ ISOTACHS, AND DIVERGENCE|~@ SPEED & DIVERG!0
	         ${runoff}

	         glevel  = 400:850          !0
	         gvcord  = pres             !none
	         scale   = 0
	         skip    = 0/2;2
         	 gdpfun  = squo(2,vadd(vlav(wnd@850:700%pres,vlav(wnd@500:400%pres)  !sm5s(pmsl)
	         type    = b                !c
	         cint    = 0                !4
	         line    = 0                !20//3
	         fint    =
	         fline   =
	         wind    = bk10/0.9/1.4/112 !bk0
	         refvec  =
	         title   = 1/-2/~ ? ${modtitle} HI RES 850-400mb MEAN LAYER WINDS AND PMSL|~850-400mb MLW & MSLP!0
	         ${runoff}
	  
                exit
EOF
            fi
        done

        # ADD QPF TO THE METAFILE...THIS MAY END UP BEING SEPARATED OUT
    
        if (( (( ${fnl_hr} + 0 )) > 0 )); then
	    run12hrqpf=""
	    run24hrqpf=""
	    run48hrqpf=""
	    run72hrqpf=""
	
            last6hr="${fnl_hr}"
	    
            if (( (( ${fnl_hr} + 0 )) >= 12 )); then
              run12hrqpf="run"
            fi
	    if (( (( ${fnl_hr} + 0 )) >= 24 )); then
              run24hrqpf="run"
            fi
	    if (( (( ${fnl_hr} + 0 )) >= 48 )); then
              run48hrqpf="run"
            fi
	    if (( (( ${fnl_hr} + 0 )) >= 72 )); then
              run72hrqpf="run"
            fi

            if [[ ${metafl} = "us" ]]; then

                gdplot2_nc << EOF
                \$MAPFIL = mepowo.gsf
                GDFILE  = F-UKMETHR | ${PDY2}/${cyc}00
                gdattim = F006-F${last6hr}-06
                device  = ${device}
                panel   = 0
                text    = 1/21//hw
        	skip    = 0
                contur  = 2
                map     = 1/1/1/yes
                clear   = y
                clrbar  = 1
                garea   = 17.529;-129.296;53.771;-22.374
                proj    = str/90;-105;0
                latlon  = 18/2
                glevel  = 0
                gvcord  = none
                gdpfun  = sm9s(add(mul(sub(tmxk,273),1.8),32))
                type    = c/f
                contur  = 2
                cint    = 5/-50/130
                line    = 32/1/2/1
                fint    = ${fint_max}
 	        fline   = 30;29;28;27;24;23;22;21;20;19;18;17;16;15;14;13;12;11;10
                hilo    = 0
                hlsym   = 0
                wind    = 0
                title   = 1/-2/~ ? ${modtitle} HI RES 2-METER 6-HR MAX TEMPERATURE (F)|~6-HR MAX TEMP!0
	        l
	        run
           
	        fint    = ${fint_min}
	        gdpfun  = sm9s(add(mul(sub(tmnk,273),1.8),32))
		title   = 1/-2/~ ? ${modtitle} HI RES 2-METER 6-HR MIN TEMPERATURE (F)|~6-HR MIN TEMP!0
	        run

                gdpfun  = p06i
		type    = f
		cint    = 0
		line    = 0
		fint    = .01;.1;.25;.5;.75;1;1.25;1.5;1.75;2;2.5;3;4;5;6;7;8;9
		fline   = 0;21-30;14-20;5
		hilo    = 31;0/x#2/.1-25./3/50;0/y
		hlsym   = 1.5
		title   = 1/-2/~ ? ${modtitle} HI RES 6-HOUR PRECIPITATION|~NOAM 06-HR TOTAL PCPN!0
		run

	        gdpfun  = p12i
	        gdattim = F012-F${fnl_hr}-12
	        title   = 1/-2/~ ? ${modtitle} HI RES 12-HOUR PRECIPITATION|~NOAM 12-HR TOTAL PCPN!0 
	        ${run12hrqpf}

         
	        gdpfun  = p24i
	        gdattim = F024-F${fnl_hr}-12
 	        title   = 1/-2/~ ? ${modtitle} HI RES 24-HOUR PRECIPITATION|~NOAM 24-HR TOTAL PCPN!0 
	        ${run24hrqpf}

	        gdpfun  = p48i
	        gdattim = F048-F${fnl_hr}-12
	        title   = 1/-2/~ ? ${modtitle} HI RES 48-HOUR PRECIPITATION|~NOAM 48-HR TOTAL PCPN!0 
	        ${run48hrqpf}
             
	        gdpfun  = p72i
	        gdattim = F072-F${fnl_hr}-12
	        title   = 1/-2/~ ? ${modtitle} HI RES 72-HOUR PRECIPITATION|~NOAM 72-HR TOTAL PCPN!0 
	        ${run72hrqpf}

                exit
EOF
            elif [[ ${metafl} = "ak" || ${metafl} = "sa" ]]; then
	    
                gdplot2_nc << EOF
                \$MAPFIL = mepowo.gsf
                GDFILE  = F-UKMETHR | ${PDY2}/${cyc}00
                gdattim = F024-F${fnl_hr}-12
                device  = ${device}
                panel   = 0
                text    = 1/21//hw
        	skip    = 0
                contur  = 2
                map     = 1/1/1/yes
                clear   = y
                clrbar  = 1
                garea   = ${garea}
                proj    = ${proj}
                latlon  = ${latlon}
                glevel  = 0
                gvcord  = none
                gdpfun  = ${qpfparm_24hr}
                type    = f
                contur  = 2
                cint    = 0
                line    = 0
                fint    = ${qpf_fint}
 	        fline   = 0;21-30;14-20;5
                hilo    = 31;0/x#2/.1-25./3/50;0/y
                hlsym   = 1.5
                wind    = 0
                title   = 1/-2/~ ? ${modtitle} HI RES 24-HOUR PRECIPITATION|~24-HR TOTAL PCPN!0
	        l
	        ${run24hrqpf}

		exit
EOF
            elif [[ ${metafl} = "us" || ${metafl} = "trop" ]]; then
	        gdplot2_nc << EOF
		\$MAPFIL = mepowo.gsf
                GDFILE  = F-UKMETHR | ${PDY2}/${cyc}00
		device  = ${device}
		panel   = 0
		text    = 1/21//hw
		skip    = 0
		map     = 1/1/1/yes
		clear   = y
		clrbar  = 1
                garea   = -6;-111;52;-14
                proj    = MER/0.0;-49.5;0.0
                latlon  = 1//1/1/10
	        gdpfun  = p24i
	        gdattim = F024-F${fnl_hr}-12
		glevel  = 0
		gvcord  = none
		type    = f
		contur  = 2
		cint    = 0
		line    = 0
		fint    = ${qpf_fint}
		fline   = 0;21-30;14-20;5
		hilo    = 31;0/x#2/.1-25./3/50;0/y
		hlsym   = 1.5
		wind    = 0
	        title   = 1/-2/~ ? ${modtitle} HI RES 24-HOUR PRECIPITATION|~ATL 24-HR TOTAL PCPN!0
	        ${run24hrqpf}
	 
                exit
EOF
            fi
	fi

    # METAFILE GENERATION DONE...SEND TO NCOSRV...
       
    #####################################################
    # GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
    # WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
    # FOR THIS CASE HERE.
    #####################################################
    ls -l ukmet.meta.$metafl
    export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

    if [ $SENDCOM = "YES" ] ; then
      cpfs ukmet.meta.$metafl $COMOUT/ukmet_${res}_${PDY}_${cyc}_${metafl}
      if [ $SENDDBN = "YES" ] ; then
        $DBNROOT/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
         $COMOUT/ukmet_${res}_${PDY}_${cyc}_${metafl}
      fi
    fi
 
    done

    curr_hour=`date -u "+%H"`
    curr_min=`date -u "+%M"`

    echo "\n*********************************************************************\n"
    echo "   "
    echo "Time of launch of UKMET metafile -- ${curr_hour}${curr_min}Z"
    echo "   "
    echo "\n*********************************************************************\n"

exit 
