#!/bin/ksh
set -x

## plot mean tracks of individual storms in the Weatern Pacific
## Fanglin Yang, March 2008: original copy adopted from HWRF. Restructured and added driver scripts.
## Fanglin Yang, March 2013: Generalized for running on WCOSS and THEIS

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
for storm in Ambo Nepartak Three Lupit Mirinae Nida Omais Conson Chanthu Mindulle Dianmu Lionrock Kompasu Fourteen Namtheun Meranti Seventeen Malakas Rai Megi Chaba Aere Songda Sarika Haima Meari Ma-on Twentyeight Tokage; do
 case $storm in
  Ambo)       code1=wp012016.dat; DATEST=20160626; DATEND=20160628;;
  Nepartak)   code1=wp022016.dat; DATEST=20160702; DATEND=20160710;;
  Three)      code1=wp032016.dat; DATEST=20160715; DATEND=20160720;;
  Lupit)      code1=wp042016.dat; DATEST=20160722; DATEND=20160724;;
  Mirinae)    code1=wp052016.dat; DATEST=20160725; DATEND=20160728;;
  Nida)       code1=wp062016.dat; DATEST=20160729; DATEND=20160803;;
  Omais)      code1=wp072016.dat; DATEST=20160802; DATEND=20160809;;
  Conson)     code1=wp082016.dat; DATEST=20160807; DATEND=20160815;;
  Chanthu)    code1=wp092016.dat; DATEST=20160812; DATEND=20160817;;
  Mindulle)   code1=wp102016.dat; DATEST=20160817; DATEND=20160823;;
  Dianmu)     code1=wp112016.dat; DATEST=20160815; DATEND=20160820;;
  Lionrock)   code1=wp122016.dat; DATEST=20160817; DATEND=20160830;;
  Kompasu)    code1=wp132016.dat; DATEST=20160818; DATEND=20160821;;
  Fourteen)   code1=wp142016.dat; DATEST=20160823; DATEND=20160824;;
  Namtheun)   code1=wp152016.dat; DATEST=20160831; DATEND=20160905;;
  Meranti)    code1=wp162016.dat; DATEST=20160909; DATEND=20160916;;
  Seventeen)  code1=wp172016.dat; DATEST=20160911; DATEND=20160911;;
  Malakas)    code1=wp182016.dat; DATEST=20160911; DATEND=20160920;;
  Rai)        code1=wp192016.dat; DATEST=20160911; DATEND=20160913;;
  Megi)       code1=wp202016.dat; DATEST=20160921; DATEND=20160929;;
  Chaba)      code1=wp212016.dat; DATEST=20160926; DATEND=20161005;;
  Aere)       code1=wp222016.dat; DATEST=20161004; DATEND=20161014;;
  Songda)     code1=wp232016.dat; DATEST=20161004; DATEND=20161013;;
  Sarika)     code1=wp242016.dat; DATEST=20161011; DATEND=20161019;;
  Haima)      code1=wp252016.dat; DATEST=20161013; DATEND=20161021;;
  Meari)      code1=wp262016.dat; DATEST=20161031; DATEND=20161107;;
  Ma-on)      code1=wp272016.dat; DATEST=20161108; DATEND=20161113;;
 Twentyeight) code1=wp282016.dat; DATEST=20161109; DATEND=20161112;;
  Tokage)     code1=wp292016.dat; DATEST=20161123; DATEND=20161128;;
 esac
OCEAN=WP

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
#if [ -s /nhc/noscrub/data/atcf-noaa/aid_nws/aep01${year}.dat ]; then
# tpcdata=/nhc/noscrub/data/atcf-noaa
# cp ${tpcdata}/aid_nws/aep*${year}*.dat  ${tpctrack}/.
# cp ${tpcdata}/btk/bep*${year}*.dat      ${tpctrack}/.
#elif [ -s $scrdir/tpctrack/${year}/aep01${year}.dat ]; then
# tpcdata=$scrdir/tpctrack
# cp ${tpcdata}/${year}/aep*.dat   ${tpctrack}/.
# cp ${tpcdata}/${year}/bep*.dat   ${tpctrack}/.
#else
# echo" HPC track not found, exit"
# exit 8
#fi


JTWC Western Pacific tracks
jtwcdata=/nhc/noscrub/data/atcf-navy
cp ${jtwcdata}/aid/awp*${year}.dat   ${tpctrack}/.
cp ${jtwcdata}/btk/bwp*${year}.dat   ${tpctrack}/.


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

#newlisti=${newlist}"AVNO HWRF GFDL JTWC "
#newlistt=${newlist}"AVNO HWRF GFDL JTWC"
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
