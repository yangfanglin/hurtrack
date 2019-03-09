function main(inpargs)

'reinit'
_fname = subwrd(inpargs,1)
year = subwrd(inpargs,2)
basin = subwrd(inpargs,3)
period = subwrd(inpargs,4)
datafile = _fname%'.dat'
outfile  = _fname%'.txt'
sigfile  = _fname%'.sig'

_cbasin    = 'Hurricane Track Errors - '%basin ' '%year
_cmodtyp   = ' '%period                     
_topylabel = 'Average Track Error (nm)'

* Set the upper and lower y-axis bounds for the 
* top and bottom plots....

tvrhi  = 400
tvrlo  =   0
topyincr = 50

*------------------------------------------------------*
'open '_fname'.ctl'
'enable print '_fname'.meta'
'set display color white'
'clear'

rc = setcols()

* Get number of models by checking the ctl file
* for the number of time levels (each model is 
* stored on a different time level)....

'q file 1'
trec = sublin(result,5)
tsize = subwrd(trec,12)
nmodels = tsize

*'set vpage 0 8.5 5.55 11.0'
'set parea 1.3 8.0 5.5 10.0'

'set xaxis 0 168 12'
'set vrange 'tvrlo' 'tvrhi
'set yaxis 'tvrlo' 'tvrhi' 'topyincr
'set missconn on'
'set grads off'
'set grid horizontal 1 27'

*------------------------
rc = readmods(datafile,nmodels)
modct = 1
while (modct <= nmodels) 
*------------------------

  'set t 'modct
  modcol   = modct+1
  linetype = solid
  marktype = modct+1
 'set ccolor 'modcol

  if (linetype = 'solid')
    'set cstyle 1'
    'set cthick 7'
  else
    'set cstyle 5'
    'set cthick 7'
  endif

  'set cmark 'marktype
  'set digsize 0.10'
  'd terr'

*-------------------------
*--draw error bars
* 'define stdp=terr+1.96*tstd'
* 'define stdm=terr-1.96*tstd'
*  i=1
*  while (i<=15)
*     'd ave(stdp,x='i',x='i')'
*     rc=sublin(result,2)
*     tmp=subwrd(rc,4)
*     'q gr2xy 'i' 'tmp
*     rc=sublin(result,1)
*     xp=subwrd(rc,3)
*     yp=subwrd(rc,6)
* 
*     'd ave(stdm,x='i',x='i')'
*     rc=sublin(result,2)
*     tmp=subwrd(rc,4)
*     'q gr2xy 'i' 'tmp
*     rc=sublin(result,1)
*     xm=subwrd(rc,3)
*     ym=subwrd(rc,6)
* 
*     'set line 'modcol' 3 6'
*     'draw line 'xm' 'ym' 'xp' 'yp
*     'draw line 'xm-0.05' 'ym' 'xm+0.05' 'ym
*     'draw line 'xp-0.05' 'yp' 'xp+0.05' 'yp
*   i=i+1
*  endwhile
*-------------------------


  if (modct = 1)
    'q gxinfo'
    xdum=sublin(result,3)
    ydum=sublin(result,4)
    xl = subwrd(xdum,4)
    xr = subwrd(xdum,6)
    ylo = subwrd(ydum,4)
    yhi = subwrd(ydum,6)
    ypstart = yhi - 0.15
    ytstart = yhi + 0.5
    ybstart = ylo - 0.40
    ytmp = yhi + ylo
    ymid = ytmp / 2
    xdiff = xr - xl
    xtstart = (xdiff/2) + xl
    xbstart = xl - 0.1
    hsiz = xdiff * 0.013
    vsiz = hsiz + 0.023
    xleg = xl+0.1
  endif

  pstring = _modname.modct
  rc = plotleg(xleg,ypstart,modct,modcol,linetype,pstring,marktype)

  if (modct = 1)
    xylabst = xbstart - 0.4
    'set string 1 bc 6 90'
    'set strsiz 0.14 0.14'
    'draw string 'xylabst' 'ymid' '_topylabel

    'set string 1 bc 6 0'
    'set strsiz 0.15 0.15'
    'draw string 'xtstart' 'ytstart' '_cbasin

    ytstart = ytstart - 0.3
    'set string 1 bc 6'
    'set strsiz 0.135 0.135'
    'draw string 'xtstart' 'ytstart' '_cmodtyp

    rc = readcases(outfile)
    rc = plotcases(xl,ylo,hsiz,vsiz)

    'set grid off'
    'set xlab off'
    'set ylab off'

  endif
*------------------------
  modct = modct + 1
endwhile
*------------------------

*--read t-test confidence level numbers and print on graphics 
    rc = readsig(sigfile)
    rc = plotsig(xl,ylo,hsiz,vsiz)

'print'
'disable print'

'printim '_fname'.gif x766 y990'
'quit'

*---------------------------------------------------*
*                                                   *
*---------------------------------------------------*
function plotleg(xpos,yt,modct,pcolor,pstyle,pstring,marktype)

* This function adds another entry onto the legend

ytmp1 = modct - 1
ytmp2 = ytmp1 * 0.30
ypos  = yt - ytmp2

'set string 'pcolor' l 7'
'set strsiz 0.10 0.13'
'draw string 'xpos' 'ypos' 'pstring

if (pstyle = 'dash') 
  'set line 'pcolor' 5 7'
else
  'set line 'pcolor' 1 4'
endif

xllt = xpos + 0.5
xlrt = xpos + 1.0
'draw line 'xllt' 'ypos' 'xlrt' 'ypos

xcenter = (xllt + xlrt) / 2
'draw mark 'marktype' 'xcenter' 'ypos' 0.11'

return 0


*---------------------------------------------------*
*                                                   *
*---------------------------------------------------*
function plotcases(xl,ylo,hsiz,vsiz)

* This function plots the number of cases under the 
* appropriate hour value on the x-axis.

ystart = ylo - 0.4
xstart = xl - 0.7

'set string 1 l 5'
'set strsiz 'hsiz' 'vsiz
'draw string 'xstart' 'ystart' #CASES' 

'set string 1 c 6 0'
'set strsiz 'hsiz' 'vsiz

ict = 1
while (ict <= 15)

* if (ict = 6 | ict = 8 | ict = 10)
*   ict = ict + 1
*   continue
* endif

  'q ll2xy 'ict' 1'
  crec = sublin(result,1)
  xpos = subwrd(crec,1)

  cstr = '('_numcase.ict')'
  'set string 1 c 5'
  'draw string 'xpos' 'ystart' 'cstr

  ict = ict + 1
 
endwhile

return

*---------------------------------------------------*
*                                                   *
*---------------------------------------------------*
function plotsig(xl,ylo,hsiz,vsiz)

* This function plots the number of t-test confidence
* level numbers at the bottom of the graphy
* if value greater than 95, use bold red color
* if value greater than 90, use bold blue color

ystart = ylo - 0.9
xstart = xl - 0.7

'set string 1 l 6'
'set strsiz 0.13 0.13'
'draw string 2.0 'ystart' Confidence Level (%) of Student-t Tests' 

say 'nsig= '_nsig

n=1
while (n<=_nsig)
say 'ss= '_ss.n.1

ystart = ystart - 0.25
'set string 1 l 7'
'set strsiz 'hsiz' 'vsiz
'draw string 0.2 'ystart' '_ss.n.1 

i = 1
while (i <= 15)
  j=i+1
  'q ll2xy 'i' 1'
  crec = sublin(result,1)
  xpos = subwrd(crec,1)
  'set strsiz 'hsiz' 'vsiz
  'set string 1 c 6'
  if ( _ss.n.j >= 95); 'set string 4 c 6' ;endif
* if ( _ss.n.j >= 95); 'set string 2 c 6' ;endif
  'draw string 'xpos' 'ystart' '_ss.n.j
  i = i + 1
endwhile
n=n+1
endwhile


return

*---------------------------------------------------*
*                                                   *
*---------------------------------------------------*
function readmods(datafile,nmodels)

* Read in all of the model names from the _fname.dat file.
* This file is a text file that contains the data which is
* actually being plotted from the binary file in this 
* script....

maxmodels = nmodels * 2
ict = 1
while (ict <= maxmodels)

  res = read(datafile)
  rc  = sublin(res,1)
  if(rc != 0)
    if(rc = 2)
      say 'End of track/intensity datafile '
      say ' '
      break
    endif
    if(rc = 1); say 'rc=1: OPEN ERROR FOR 'datafile; endif
    if(rc = 8); say 'rc=8: 'datafile' OPEN FOR WRITE ONLY'; endif
    if(rc = 9); say 'rc=9: I/O ERROR FOR 'datafile; endif
    return 99
  endif

  mrec = sublin(res,2)
  _modname.ict = subwrd(mrec,1)

  ict = ict + 1

endwhile

return


*---------------------------------------------------*
*                                                   *
*---------------------------------------------------*
function readcases(outfile)

* Read the track verification output file to get the 
* number of cases at each forecast hour.

while (1)

  res = read(outfile)
  rc  = sublin(res,1)
  if(rc != 0)
    if(rc = 2)
      say 'End of verification output file: 'outfile
      say ' '
      break
    endif
    if(rc = 1); say 'rc=1: OPEN ERROR FOR 'outfile; endif
    if(rc = 8); say 'rc=8: 'outfile' OPEN FOR WRITE ONLY'; endif
    if(rc = 9); say 'rc=9: I/O ERROR FOR 'outfile; endif
    return 99
  endif

  outrec = sublin(res,2)
  word1  = subwrd(outrec,1)

  if (word1 = '#CASES')
    _numcase.1  = subwrd(outrec,2)
    _numcase.2  = subwrd(outrec,3)
    _numcase.3  = subwrd(outrec,4)
    _numcase.4  = subwrd(outrec,5)
    _numcase.5  = subwrd(outrec,6)
    _numcase.6  = subwrd(outrec,7)
    _numcase.7  = subwrd(outrec,8)
    _numcase.8  = subwrd(outrec,9)
    _numcase.9  = subwrd(outrec,10)
    _numcase.10  = subwrd(outrec,11)
    _numcase.11  = subwrd(outrec,12)
    _numcase.12  = subwrd(outrec,13)
    _numcase.13  = subwrd(outrec,14)
    _numcase.14  = subwrd(outrec,15)
    _numcase.15  = subwrd(outrec,16)
    break
  endif

endwhile

return

*---------------------------------------------------*
*                                                   *
*---------------------------------------------------*
function readsig(sigfile)

* Read t-test confidence levels

n=0
while (1)

  res = read(sigfile)
  rc  = sublin(res,1)
  if(rc != 0)
    if(rc = 2)
      say 'Reach end of confidence file: 'sigfile
      say ' '
      break
    endif
    if(rc = 1); say 'rc=1: OPEN ERROR FOR 'sigfile; endif
    if(rc = 8); say 'rc=8: 'sigfile' OPEN FOR WRITE ONLY'; endif
    if(rc = 9); say 'rc=9: I/O ERROR FOR 'sigfile; endif
    return 99
  endif

  n=n+1
  outrec = sublin(res,2)
  i=1
  while ( i <=16) 
   _ss.n.i  = subwrd(outrec,i)
*  say _ss.n.i
   i=i+1
  endwhile
endwhile
  _nsig = n
* say 'nsig= '_nsig
return

*---------------------------------------------------*
function setcols()

* 20 = red
* 21 = bright green
* 22 = blue
* 23 = greenish-yellow (from ens nogaps)
* 24 = bright purple (from old eta track verif)
* 25 = brown (from ens NCEP mean)
* 26 = pink (from ens ECMWF hrc)
* 27 = light grey
* 28 = dark green

'set rgb 20 200   0   0'
'set rgb 21   0 215   0'
'set rgb 22  60 150 255'
'set rgb 23 125 165   0'
'set rgb 24 255   8 235'
'set rgb 25 220 140   7'
'set rgb 26 255   0 255'
'set rgb 27 225 225 225'
'set rgb 28   0 115   0'

return
