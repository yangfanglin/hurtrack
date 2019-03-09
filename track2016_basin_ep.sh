#!/bin/ksh
set -x

## plot mean tracks of individual storms in the Eastern Pacific
## Fanglin Yang, March 2008: original copy adopted from HWRF. Restructured and added driver scripts.
## Fanglin Yang, March 2013: Generalized for running on WCOSS and THEIA

#-------------------------------------------------------------------------------------
export expdir=/global/noscrub/emc.glopara/archive                            ;#experiment data archive directory
export mdlist="gfs2017 gfs2019 gfs2019c"                              ;#experiment names
export mdplot="FY17 HRD5 HRD6"                                ;#names to be shown on plots, limitted to 4 letters
export cyc="00 06 12 18"                           ;#forecast cycles to be included in verification
export doftp="YES"                                  ;#whether or not sent maps to ftpdir
export webhostid=emc.glopara
export webhost=emcrzdm.ncep.noaa.gov
export ftpdir=/home/people/emc/www/htdocs/gmb/$webhostid/vsdb/fv3q2fy19retro4c
machine=WCOSS

#-------------------------------------------------------------------------------------
#---------------------------------------------------------
#---Most likely you do not need to change anything below--
#---------------------------------------------------------
#-------------------------------------------------------------------------------------
if [ $machine = THEIA ]; then
 export scrdir=/scratch4/NCEPDEV/global/save/Fanglin.Yang/VRFY/hurtrack
 export STMP="/scratch4/NCEPDEV/stmp3"
 export NDATE=/scratch4/NCEPDEV/global/save/Fanglin.Yang/VRFY/vsdb/nwprod/util/exec/ndate
elif [ $machine = WCOSS ]; then
 export scrdir=/global/save/Fanglin.Yang/VRFY/hurtrack
 export STMP="/stmpd2"
 export NDATE=/nwprod/util/exec/ndate
fi
export rundir=${rundir:-$STMP/$LOGNAME/track$$}
mkdir -p ${rundir}; cd $rundir || exit 8


#==================================================================
for storm in One-E Agatha Blas Celia Darby Estelle Frank Georgette Howard Ivette Javier Kay Lester Madeline Newton Orlene Paine Roslyn Ulika Seymour Tina; do
 case $storm in
  One-E)       code1=ep012016.dat; DATEST=20160606; DATEND=20160608;;
  Agatha)      code1=ep022016.dat; DATEST=20160702; DATEND=20160705;;
  Blas)        code1=ep032016.dat; DATEST=20160703; DATEND=20160710;;
  Celia)       code1=ep042016.dat; DATEST=20160706; DATEND=20160716;;
  Darby)       code1=ep052016.dat; DATEST=20160711; DATEND=20160726;;
  Estelle)     code1=ep062016.dat; DATEST=20160715; DATEND=20160722;;
  Frank)       code1=ep072016.dat; DATEST=20160721; DATEND=20160728;;
  Georgette)   code1=ep082016.dat; DATEST=20160721; DATEND=20160727;;
  Howard)      code1=ep092016.dat; DATEST=20160731; DATEND=20160803;;
  Ivette)      code1=ep102016.dat; DATEST=20160802; DATEND=20160808;;
  Javier)      code1=ep112016.dat; DATEST=20160807; DATEND=20160809;;
  Kay)         code1=ep122016.dat; DATEST=20160818; DATEND=20160823;;
  Lester)      code1=ep132016.dat; DATEST=20160824; DATEND=20160907;;
  Madeline)    code1=ep142016.dat; DATEST=20160826; DATEND=20160903;;
  Newton)      code1=ep152016.dat; DATEST=20160904; DATEND=20160907;;
  Orlene)      code1=ep162016.dat; DATEST=20160911; DATEND=20160917;;
  Paine)       code1=ep172016.dat; DATEST=20160918; DATEND=20160921;;
  Roslyn)      code1=ep182016.dat; DATEST=20160925; DATEND=20160929;;
  Ulika)       code1=ep192016.dat; DATEST=20160926; DATEND=20160930;;
  Seymour)     code1=ep202016.dat; DATEST=20161023; DATEND=20161028;;
  Tina)        code1=ep212016.dat; DATEST=20161114; DATEND=20161115;;
  Otto)        code1=ep222016.dat; DATEST=20161125; DATEND=20161126;;
 esac
OCEAN=EP

#---------------------------------------------------------
#---------------------------------------------------------
set -A mdname $mdlist; set -A mdpt $mdplot
execdir=${rundir}/${storm}                     ;# working directory
rm -r $execdir; mkdir -p $execdir
cd $execdir; chmod u+rw *

years=`echo $DATEST |cut -c 1-4 `
yeare=`echo $DATEND |cut -c 1-4 `
if [ $years -ne $yeare ]; then
 echo " years=$years, yeare=$yeare.  Must have years=yeare. exit"
 exit
fi 
export year=$years

## copy HPC/JTWC tracks to working directory (HPC's tracks sometime do not match with real-time tracks)
tpctrack=${execdir}/tpctrack           ;#place to hold HPC original track data
mkdir -p $tpctrack

#TPC Atlantic and Eastern Pacific tracks
if [ -s /nhc/noscrub/data/atcf-noaa/aid_nws/aep01${year}.dat ]; then
 tpcdata=/nhc/noscrub/data/atcf-noaa
 cp ${tpcdata}/aid_nws/aep*${year}*.dat  ${tpctrack}/.
 cp ${tpcdata}/btk/bep*${year}*.dat      ${tpctrack}/.
elif [ -s $scrdir/tpctrack/${year}/aep01${year}.dat ]; then
 tpcdata=$scrdir/tpctrack
 cp ${tpcdata}/${year}/aep*.dat   ${tpctrack}/.
 cp ${tpcdata}/${year}/bep*.dat   ${tpctrack}/.
else
 echo" HPC track not found, exit"
 exit 8
fi


#JTWC Western Pacific tracks
#jtwcdata=/nhc/noscrub/data/atcf-navy
#cp ${jtwcdata}/aid/awp*${year}.dat   ${tpctrack}/.
#cp ${jtwcdata}/btk/bwp*${year}.dat   ${tpctrack}/.


#------------------------------------------------------------------------
#  insert experiment track to TPC track  for all runs and for all BASINs
#------------------------------------------------------------------------
newlist=""
fout=24      
nexp=`echo $mdlist |wc -w`           
ncyc=`echo $cyc |wc -w |sed 's/ //g'`           
if [ $ncyc -eq 3 ]; then ncyc=2; fi
fout=`expr $fout \/ $ncyc `


n=0
if [ $nexp -gt 0 ]; then
for exp in $mdlist; do

## cat experiment track data for each exp 
nameold=`echo $exp |cut -c 1-4 `                 ;#current fcst always uses first 4 letters of experiment name
nameold=`echo $nameold |tr "[a-z]" "[A-Z]" `
#namenew=`echo $exp |cut -c 1-4 `                 
namenew=${mdpt[$n]} ; n=$((n+1))
namenew=`echo $namenew |tr "[a-z]" "[A-Z]" `
export newlist=${newlist}"${namenew} "           ;#donot delete the space at the end

dump=.gfs.
if [ $exp = gfs2016 ]; then nameold="GFSX" ; fi
if [ $exp = gfs2017 ]; then nameold="FY17" ; fi
if [ $exp = gfs2019 ]; then nameold="FY19" ; fi
if [ $exp = gfs2019c ]; then nameold="FY19" ; fi


outfile=${execdir}/atcfunix.$exp.$year
if [ -s $outfile ]; then rm $outfile; fi
touch $outfile
indir=${expdir}/$exp
date=${DATEST}00    
until [ $date -gt ${DATEND}18 ] ; do
   infile=$indir/atcfunix${dump}$date
   if [ -s $infile ]; 
     if [ -s infiletmp ]; then rm infiletmp; fi
     sed "s?$nameold?$namenew?g" $infile >infiletmp
     then cat infiletmp >> $outfile 
   fi
   date=`$NDATE +$fout $date`
done


## insert experiment track into TPC tracks
for BASIN in $OCEAN; do
$scrdir/sorc/insert_new.sh $exp $BASIN $year $tpctrack $outfile $execdir
done   
done         ;#end of experiment loop

else
 ln -fs $tpctrack/* .
fi
#------------------------------------------------------------------------


#------------------------------------------------------------------------
#  prepare data for GrADS graphics
#------------------------------------------------------------------------
for BASIN in $OCEAN; do
bas=`echo $BASIN |tr "[A-Z]" "[a-z]" `

## copy test cards, replace dummy exp name MOD# with real exp name
cp ${scrdir}/sorc/card.i .
cp ${scrdir}/sorc/card.t .
cat >stormlist <<EOF
$code1
EOF
cat card.i stormlist >card${year}_${bas}.i
cat card.t stormlist >card${year}_${bas}.t

#newlisti=${newlist}"AVNO HWRF GFDL OFCL "
#newlistt=${newlist}"AVNO HWRF GFDL OFCL"
#newlisti=${newlist}"AVNO"
#newlistt=${newlist}"AVNO"
newlisti=${newlist}
newlistt=${newlist}


nint=`echo $newlisti |wc -w`     ;#number of process for intensity plot, to replace NUMINT in card.i
ntrc=`echo $newlistt |wc -w`     ;#number of process for track plot, to replace NUMTRC in card.t
nint=`expr $nint + 0 `           ;#remove extra space
ntrc=`expr $ntrc + 0 `
sed -e "s/MODLIST/${newlisti}/g" -e "s/NUMINT/${nint}/g" card${year}_$bas.i >card_$bas.i   
sed -e "s/MODLIST/${newlistt}/g" -e "s/NUMTRC/${ntrc}/g" card${year}_$bas.t >card_$bas.t   


## produce tracks.t.txt etc
cp $tpctrack/b*${year}.dat .
${scrdir}/sorc/nhcver.x card_${bas}.t tracks_${bas}.t  $execdir
${scrdir}/sorc/nhcver.x card_${bas}.i tracks_${bas}.i  $execdir


## create grads files tracks_${bas}.t.dat etc for plotting
 ${scrdir}/sorc/top_tvercut.sh ${execdir}/tracks_${bas}.t.txt $scrdir/sorc
 ${scrdir}/sorc/top_ivercut.sh ${execdir}/tracks_${bas}.i.txt $scrdir/sorc


## copy grads scripts and make plots                        
if [ $BASIN = "EP" ]; then place="East-Pacific"; fi
period="${storm}__${DATEST}_${DATEND}_${ncyc}cyc"
cp ${scrdir}/sorc/*iver*.gs .
cp ${scrdir}/sorc/*tver*.gs .

 grads -bcp "run top_iver.gs tracks_${bas}.i  $year $place $period"
 grads -bcp "run top_tver_250.gs tracks_${bas}.t  $year $place $period"

mv tracks_${bas}.i.gif  tracks_${storm}.i.gif
mv tracks_${bas}.t.gif  tracks_${storm}.t.gif
#----------------------------
done     ;# end of BASIN loop
#----------------------------


if [ $doftp = "YES" ]; then
cat << EOF >ftpin
  cd $ftpdir
  mkdir track
  cd track
  binary
  promt
  mput tracks_${storm}*.gif
  put tracks_al.t.txt tracks_${storm}.t.txt
  put tracks_al.i.txt tracks_${storm}.i.txt
  quit
EOF
 sftp  ${webhostid}@${webhost} <ftpin
fi


## save tracks
#savedir=${scrdir}/arch_trak/${mdname[0]}$years$yeare
#mkdir -p $savedir
#cp ${execdir}/tracks_${storm}*.gif  ${savedir}/.
#cp ${execdir}/tracks_al.t.txt ${savedir}/tracks_${storm}.t.txt
#cp ${execdir}/tracks_al.i.txt ${savedir}/tracks_${storm}.i.txt


#---end of individual storm 
done
#---end of individual storm 
exit
