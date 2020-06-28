#!/bin/ksh
set -x

## plot mean tracks of individual storms in the Atlantic
## Fanglin Yang, March 2008: original copy adopted from HWRF. Restructured and added driver scripts.
## Fanglin Yang, March 2013: Generalized for running on WCOSS and THEIA

#-------------------------------------------------------------------------------------
export expdir=/gpfs/dell6/emc/modeling/noscrub/emc.glopara/archive 
export mdlist="v16retro1e"                    ;#experiment names
export mdplot="V16E"                         ;#names to be shown on plots, limitted to 4 letters
export cyc="00 06 12 18"                     ;#forecast cycles to be included in verification
export doftp="YES"                           ;#whether or not sent maps to ftpdir
export webhostid=emc.glopara       
export webhost=emcrzdm.ncep.noaa.gov
export ftpdir=/home/people/emc/www/htdocs/gmb/$webhostid/vsdb/v16retro1e          

#-------------------------------------------------------------------------------------
#---------------------------------------------------------
#---Most likely you do not need to change anything below--
#---------------------------------------------------------
#-------------------------------------------------------------------------------------
export scrdir=/gpfs/dell2/emc/modeling/noscrub/Fanglin.Yang/VRFY/hurtrack
export STMP="/gpfs/dell3/stmp"
export NDATE=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.0/exec/ips/ndate
export rundir=${rundir:-$STMP/$LOGNAME/track$$}
mkdir -p ${rundir}; cd $rundir || exit 8


#==================================================================
for  storm in Pabuk     Wutip   Sepat   Mun     Danas   Goring Nari     Wipha   Francisco       Lekima  Krosa   Bailu   Podul   Kajiki  Lingling  Faxai Marilyn Peipah  Tapah   Mitag   Hagibis Neoguri Bualoi  Matmo   Halong  Nakri   Fengshen        Kalmaegi        Fung-wong       Kammuri Phanfone ; do
 case $storm in
  Pabuk)     code1=wp012019.dat; DATEST=20181231; DATEND=20190104;;
  Wutip)     code1=wp022019.dat; DATEST=20190218; DATEND=20190302;;
  Sepat)     code1=wp032019.dat; DATEST=20190624; DATEND=20190628;;
  Mun)       code1=wp042019.dat; DATEST=20190701; DATEND=20190704;;
  Danas)     code1=wp052019.dat; DATEST=20190714; DATEND=20190721;;
  Goring)    code1=wp062019.dat; DATEST=20190717; DATEND=20190719;;
  Nari)      code1=wp072019.dat; DATEST=20190724; DATEND=20190727;;
  Wipha)     code1=wp082019.dat; DATEST=20190730; DATEND=20190804;;
  Francisco) code1=wp092019.dat; DATEST=20190801; DATEND=20190808;;
  Lekima)    code1=wp102019.dat; DATEST=20190802; DATEND=20190813;;
  Krosa)     code1=wp112019.dat; DATEST=20190805; DATEND=20190816;;
  Bailu)     code1=wp122019.dat; DATEST=20190819; DATEND=20190826;;
  Podul)     code1=wp132019.dat; DATEST=20190824; DATEND=20190831;;
  Faxai)     code1=wp142019.dat; DATEST=20190902; DATEND=20190909;;
  Lingling)  code1=wp152019.dat; DATEST=20190831; DATEND=20190907;;
  Kajiki)    code1=wp162019.dat; DATEST=20190830; DATEND=20190906;;
  Mitag)     code1=wp192019.dat; DATEST=20190925; DATEND=20191003;;
  Hagibis)   code1=wp202019.dat; DATEST=20191004; DATEND=20191013;;
  Neoguri)   code1=wp212019.dat; DATEST=20191015; DATEND=20191021;;
  Bualoi)    code1=wp222019.dat; DATEST=20191018; DATEND=20191025;;
  Matmo)     code1=wp232019.dat; DATEST=20191028; DATEND=20191031;;
  Halong)    code1=wp242019.dat; DATEST=20191101; DATEND=20191108;;
  Nakri)     code1=wp252019.dat; DATEST=20191104; DATEND=20191111;;
  Fengshen)  code1=wp262019.dat; DATEST=20191109; DATEND=20191117;;
  Kalmaegi)  code1=wp272019.dat; DATEST=20191109; DATEND=20191122;;
  Fung-wong) code1=wp282019.dat; DATEST=20191117; DATEND=20191123;;
  Kammuri)   code1=wp292019.dat; DATEST=20191124; DATEND=20191206;;
  Phanfone)  code1=wp302019.dat; DATEST=20191219; DATEND=20191229;;
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

#JTWC Western Pacific tracks
if [ -s /nhc/noscrub/data/atcf-navy/aid/awp01${year}.dat ]; then
 jtwcdata=/nhc/noscrub/data/atcf-navy
 cp ${jtwcdata}/aid/awp*${year}.dat   ${tpctrack}/.
 cp ${jtwcdata}/btk/bwp*${year}.dat   ${tpctrack}/.
elif [ -s $scrdir/tpctrack/${year}/awp01${year}.dat ]; then
 tpcdata=$scrdir/tpctrack
 cp ${tpcdata}/${year}/awp*.dat   ${tpctrack}/.
 cp ${tpcdata}/${year}/bwp*.dat   ${tpctrack}/.
else
 echo" HPC track not found, exit"
 exit 8
fi

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
if [ $exp = prfv3rt1 ]; then nameold="PRFV"; fi
if [ $exp = gfs2017 ]; then nameold="FY17" ; fi
if [ $exp = gfs2019 ]; then nameold="FY19" ; fi
if [ $exp = gfs2019b ]; then nameold="FY19" ; fi
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

#newlisti=${newlist}"AVNO HWRF GFDL  EMX  UKM JTWC"
#newlistt=${newlist}"AVNO HWRF GFDL  EMX  UKM JTWC"
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

mv tracks_${bas}.i.png  tracks_${storm}.i.png
mv tracks_${bas}.t.png  tracks_${storm}.t.png
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
  mput tracks_${storm}*.png
  put tracks_al.t.txt tracks_${storm}.t.txt
  put tracks_al.i.txt tracks_${storm}.i.txt
  quit
EOF
 sftp  ${webhostid}@${webhost} <ftpin
fi


## save tracks
#savedir=${scrdir}/arch_trak/${mdname[0]}$years$yeare
#mkdir -p $savedir
#cp ${execdir}/tracks_${storm}*.png  ${savedir}/.
#cp ${execdir}/tracks_al.t.txt ${savedir}/tracks_${storm}.t.txt
#cp ${execdir}/tracks_al.i.txt ${savedir}/tracks_${storm}.i.txt


#---end of individual storm 
done
#---end of individual storm 
exit
