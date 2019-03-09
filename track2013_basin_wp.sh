#!/bin/ksh
set -x

## plot mean tracks of individual storms in the Weatern Pacific
## Fanglin Yang, March 2008: original copy adopted from HWRF. Restructured and added driver scripts.
## Fanglin Yang, March 2013: Generalized for running on WCOSS and THEIA

#-------------------------------------------------------------------------------------

export expdir=/global/noscrub/emc.glopara/archive  ;#experiment data archive directory
export mdlist="pr4devbs13"                         ;#experiment names
export mdplot="4dvb"                               ;#names to be shown on plots, limitted to 4 letters
export cyc="00 06 12 18"                           ;#forecast cycles to be included in verification
export doftp="YES"                                 ;#whether or not sent maps to ftpdir
export webhostid=wd20rt
export webhost=emcrzdm.ncep.noaa.gov
export ftpdir=/home/people/emc/www/htdocs/gmb/$webhostid/vsdb/pr4devbs13
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
export rundir=${rundir:-$STMP/$LOGNAME/track2013_wp_pr4devbs13}
mkdir -p ${rundir}; cd $rundir || exit 8


#==================================================================
for storm in Sonamu Shanshan Yagi Leepi Bebinca Rumbia Soulik Cimaron Jebi Mangkhut Utor Trami Kong-rey Toraji Man-yi Usagi Pabuk Wutip Sepat Fitow Danas Nari Wipha Francisco Lekima Krosa Haiyan Podul ; do
 case $storm in
  Sonamu)        code1=wp012013.dat; DATEST=20130103; DATEND=20130108;;
  Shanshan)      code1=wp022013.dat; DATEST=20130223; DATEND=20130223;;
  Yagi)          code1=wp032013.dat; DATEST=20130608; DATEND=20130614;;
  Leepi)         code1=wp042013.dat; DATEST=20130618; DATEND=20130621;;
  Bebinca)       code1=wp052013.dat; DATEST=20130621; DATEND=20130624;;
  Rumbia)        code1=wp062013.dat; DATEST=20130629; DATEND=20130702;;
  Soulik)        code1=wp072015.dat; DATEST=20130708; DATEND=20130714;;
  Cimaron)       code1=wp082013.dat; DATEST=20130717; DATEND=20130719;;
  Jebi)          code1=wp092013.dat; DATEST=20130731; DATEND=20130803;;
  Mangkhut)      code1=wp102013.dat; DATEST=20130806; DATEND=20130807;;
  Utor)          code1=wp112013.dat; DATEST=20130810; DATEND=20130816;;
  Trami)         code1=wp122013.dat; DATEST=20130818; DATEND=20130822;;
  Kong-rey)      code1=wp142013.dat; DATEST=20130826; DATEND=20130831;;
  Toraji)        code1=wp152013.dat; DATEST=20130902; DATEND=20130904;;
  Man-yi)        code1=wp162013.dat; DATEST=20130913; DATEND=20130916;;
  Usagi)         code1=wp172013.dat; DATEST=20130917; DATEND=20130922;;
  Pabuk)         code1=wp192013.dat; DATEST=20130921; DATEND=20130926;;
  Wutip)         code1=wp202013.dat; DATEST=20130927; DATEND=20130930;;
  Sepat)         code1=wp212013.dat; DATEST=20130930; DATEND=20131002;;
  Fitow)         code1=wp222013.dat; DATEST=20131001; DATEND=20131007;;
  Danas)         code1=wp232013.dat; DATEST=20131004; DATEND=20131008;;
  Nari)          code1=wp242013.dat; DATEST=20131009; DATEND=20131015;;
  Wipha)         code1=wp252013.dat; DATEST=20131011; DATEND=20131016;;
  Francisco)     code1=wp262013.dat; DATEST=20131016; DATEND=20131025;;
  Lekima)        code1=wp282013.dat; DATEST=20131021; DATEND=20131025;;
  Krosa)         code1=wp292013.dat; DATEST=20131029; DATEND=20131104;;
  Haiyan)        code1=wp312013.dat; DATEST=20131104; DATEND=20131111;;
  Podul)         code1=wp322013.dat; DATEST=20131114; DATEND=20131116;;
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
if [ $exp = fim ]; then
 dump=.fim.
 nameold=" F8C"
fi

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
newlisti=${newlist}"AVNO"
newlistt=${newlist}"AVNO"

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
if [ $BASIN = "WP" ]; then place="West-Pacific"; fi
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
  put tracks_${bas}.t.txt tracks_${storm}.t.txt
  put tracks_${bas}i.txt tracks_${storm}.i.txt
  quit
EOF
 sftp  ${webhostid}@${webhost} <ftpin
fi


## save tracks
#savedir=${scrdir}/arch_trak/${mdname[0]}$years$yeare
#mkdir -p $savedir
#cp ${execdir}/tracks_${storm}*.gif  ${savedir}/.
#cp ${execdir}/tracks_${bas}.t.txt ${savedir}/tracks_${storm}.t.txt
#cp ${execdir}/tracks_${bas}.i.txt ${savedir}/tracks_${storm}.i.txt


#---end of individual storm 
done
#---end of individual storm 
exit
