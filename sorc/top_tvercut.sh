#!/bin/ksh
set -x

#-----------------------------------------------------------------
# This script was written by Tim Marchok (timothy.marchok@noaa.gov)
# This script is used to cut apart the output files from TPC's
# verification program and grab the average track errors and the 
# errors relative to CLIPER and write all those values back out to
# another ascii file that will be used as input to a program that 
# converts the data to GrADS format.  The awk portion of the script
# puts missing values of -999.
# Usage: sh tvercut.sh  full_path_file
# where full_path_file is full pathway name of file to be parsed. 
#----------------------------------------------------------------
# Fanglin.Yang@noaa.gov, January 2016
# 1. Extend the verification to 168 hours and for every 12 hours.
# 2. Include standard deviation in output for significance test.
#----------------------------------------------------------------

export full_path_file=$1
export scrdir=$2          

ifile=`  basename ${full_path_file}`
datdir=`  dirname ${full_path_file}`

ifbasenum=` echo $ifile | awk -F. '{print NF}'`
let ifbasenum=ifbasenum-1
ifbase=` echo $ifile | cut -d. -f1-${ifbasenum}`

outfile="${ifbase}.dat"
gradsfile="${ifbase}.gr"
ctlfile="${ifbase}.ctl"

#----------------------------------------------
#-- mean track errors
awk '

  {
    if (match($0," AVERAGE TRACK ERRORS") || match($0," average track errors")) {
      getline
      while (1) {
        getline
        if (match($0,"#CASES")) {
          break
        }
        else {
          model = $1
          h00   = $2
          h12   = $3
          h24   = $4
          h36   = $5
          h48   = $6
          h60   = $7
          h72   = $8
          h84   = $9
          h96   = $10
          h108  = $11
          h120  = $12
          h132  = $13
          h144  = $14
          h156  = $15
          h168  = $16
          if (h00  == 0.0) { h00  = -999.0 }
          if (h12  == 0.0) { h12  = -999.0 }
          if (h24  == 0.0) { h24  = -999.0 }
          if (h36  == 0.0) { h36  = -999.0 }
          if (h48  == 0.0) { h48  = -999.0 }
          if (h60  == 0.0) { h60  = -999.0 }
          if (h72  == 0.0) { h72  = -999.0 }
          if (h84  == 0.0) { h84  = -999.0 }
          if (h96  == 0.0) { h96  = -999.0 }
          if (h108 == 0.0) { h108 = -999.0 }
          if (h120 == 0.0) { h120 = -999.0 }
          if (h132 == 0.0) { h132 = -999.0 }
          if (h144 == 0.0) { h144 = -999.0 }
          if (h156 == 0.0) { h156 = -999.0 }
          if (h168 == 0.0) { h168 = -999.0 }
          printf (" %-4s    %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n",model,h00,h12,h24,h36,h48,h60,h72,h84,h96,h108,h120,h132,h144,h156,h168)
        }
      }
    }
  } ' ${full_path_file} >${datdir}/${outfile}
#----------------------------------------------

#----------------------------------------------
#-- track error standard deviation
awk '

  {
    if (match($0," ERROR STANDARD DEVIATION") || match($0," error standard deviation")) {
      getline
      while (1) {
        getline
        if (match($0,"#CASES")) {
          break
        }
        else {
          model = $1
          h00   = $2
          h12   = $3
          h24   = $4
          h36   = $5
          h48   = $6
          h60   = $7
          h72   = $8
          h84   = $9
          h96   = $10
          h108  = $11
          h120  = $12
          h132  = $13
          h144  = $14
          h156  = $15
          h168  = $16
          if (h00  == 0.0) { h00  = -999.0 }
          if (h12  == 0.0) { h12  = -999.0 }
          if (h24  == 0.0) { h24  = -999.0 }
          if (h36  == 0.0) { h36  = -999.0 }
          if (h48  == 0.0) { h48  = -999.0 }
          if (h60  == 0.0) { h60  = -999.0 }
          if (h72  == 0.0) { h72  = -999.0 }
          if (h84  == 0.0) { h84  = -999.0 }
          if (h96  == 0.0) { h96  = -999.0 }
          if (h108 == 0.0) { h108 = -999.0 }
          if (h120 == 0.0) { h120 = -999.0 }
          if (h132 == 0.0) { h132 = -999.0 }
          if (h144 == 0.0) { h144 = -999.0 }
          if (h156 == 0.0) { h156 = -999.0 }
          if (h168 == 0.0) { h168 = -999.0 }
          printf (" %-4s    %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n",model,h00,h12,h24,h36,h48,h60,h72,h84,h96,h108,h120,h132,h144,h156,h168)
        }
      }
    }
  } ' ${full_path_file} >>${datdir}/${outfile}
#----------------------------------------------

${scrdir}/wrtdat.sh ${datdir}/${outfile}

nm=` cat ${datdir}/${outfile} | wc -l`
nmodels=`expr $nm \/ 2`                         

sed -e "s/_FNAME/${gradsfile}/g" \
    -e "s/_NMODELS/${nmodels}/g" \
    ${scrdir}/shell.ctl >${datdir}/${ctlfile}

exit
