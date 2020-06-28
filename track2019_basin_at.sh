#!/bin/ksh
set -x

## plot mean tracks of individual storms in the Atlantic
## Fanglin Yang, March 2008: original copy adopted from HWRF. Restructured and added driver scripts.
## Fanglin Yang, March 2013: Generalized for running on WCOSS and THEIA

#-------------------------------------------------------------------------------------
export expdir=/gpfs/dell6/emc/modeling/noscrub/emc.glopara/archive 
export mdlist="v16retro2c"                    ;#experiment names
export mdplot="RT2C"                         ;#names to be shown on plots, limitted to 4 letters
export cyc="00 06 12 18"                     ;#forecast cycles to be included in verification
export doftp="YES"                           ;#whether or not sent maps to ftpdir
export webhostid=emc.glopara       
export webhost=emcrzdm.ncep.noaa.gov
export ftpdir=/home/people/emc/www/htdocs/gmb/$webhostid/vsdb/v16retro2c_final

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
#for storm in Andrea  Barry  Chantal  Dorian  Erin   Fernand   Gabrielle   Humberto   Imelda   Jerry   Karen  Lorenzo   Melissa  Nestor  Olga Pablo   Rebekah   Sebastien ;do
for storm in Dorian  Erin   Fernand Gabrielle; do
 case $storm in
  Andrea)     code1=al012019.dat; DATEST=20190520; DATEND=20190521;;
  Barry)      code1=al022019.dat; DATEST=20190711; DATEND=20190715;;
  Chantal)    code1=al042019.dat; DATEST=20190820; DATEND=20190823;;
  Dorian)     code1=al052019.dat; DATEST=20190824; DATEND=20190907;;
  Erin)       code1=al062019.dat; DATEST=20190826; DATEND=20190829;;
  Fernand)    code1=al072019.dat; DATEST=20190903; DATEND=20190905;;
  Gabrielle)  code1=al082019.dat; DATEST=20190903; DATEND=20190910;;
  Humberto)   code1=al092019.dat; DATEST=20190913; DATEND=20190919;;
  Jerry)      code1=al102019.dat; DATEST=20190917; DATEND=20190924;;
  Imelda)     code1=al112019.dat; DATEST=20190917; DATEND=20190919;;
  Karen)      code1=al122019.dat; DATEST=20190922; DATEND=20190927;;
  Lorenzo)    code1=al132019.dat; DATEST=20190923; DATEND=20191002;;
  Melissa)    code1=al142019.dat; DATEST=20191011; DATEND=20191014;;
  Nestor)     code1=al162019.dat; DATEST=20191018; DATEND=20191019;;
  Olga)       code1=al172019.dat; DATEST=20191025; DATEND=20191025;;
  Pablo)      code1=al182019.dat; DATEST=20191025; DATEND=20191028;;
  Rebekah)    code1=al192019.dat; DATEST=20191030; DATEND=20191101;;
  Sebastien)  code1=al202019.dat; DATEST=20191119; DATEND=20191124;;
 esac
OCEAN=AL

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
if [ -s /nhc/noscrub/data/atcf-noaa/aid_nws/aal01${year}.dat ]; then
 tpcdata=/nhc/noscrub/data/atcf-noaa
 cp ${tpcdata}/aid_nws/aal*${year}*.dat  ${tpctrack}/.
 cp ${tpcdata}/btk/bal*${year}*.dat      ${tpctrack}/.
elif [ -s $scrdir/tpctrack/${year}/aal01${year}.dat ]; then
 tpcdata=$scrdir/tpctrack
 cp ${tpcdata}/${year}/aal*.dat   ${tpctrack}/.
 cp ${tpcdata}/${year}/bal*.dat   ${tpctrack}/.
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

#newlisti=${newlist}"AVNO HWRF GFDL  EMX  UKM OFCL"
#newlistt=${newlist}"AVNO HWRF GFDL  EMX  UKM OFCL"
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
if [ $BASIN = "AL" ]; then place="Atlantic"; fi
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
