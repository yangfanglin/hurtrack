      program wrtdat
!
!--------------------------------------------------------------------
!  Tim Marchok, ????
!     This program reads in data from an ascii text file and writes 
!     the data back out in GrADS format (direct access).
!     The input for this program is an ascii file containing
!     mean track/intensity .
!     The data in the ascii file should be in f6.1 format to be read in.
!--------------------------------------------------------------------
!  Fanglin Yang, January 2016
!    Include standard deviation and extend to 168 hours.
!--------------------------------------------------------------------
!
      parameter(npts=15)
      real cdat(npts,100),cdat1(npts),cdat2(npts)
      character  INFILE*65,OUTFILE*65,cmodname*8
!
      namelist/namin/INFILE

!     Read name of input file from the namelist....
      read (5,namin,end=1000)
 1000 continue

      print *,'After namelist read, infile= ',infile

      open (unit=11,file=INFILE
     &  ,access='sequential',action='read')

      OUTFILE = INFILE(1:LASTDOT(INFILE))//'.gr'
      open (unit=51,file=OUTFILE,form='unformatted',status='unknown')

      print *,'Name of input ascii track file is  ',infile
      print *,'Name of output GrADS track file is ',outfile
      print *,' '

      n = 0
      do while (.true.)
        n = n + 1
        read (11,31,end=99,err=100) cmodname,(cdat(i,n),i=1,npts)
        write (6,31) cmodname,(cdat(i,n),i=1,npts)
      enddo
  31  format (1x,a4,3x,15(1x,f6.1))
  99  continue

      mm=n/2  
      print *,'Number of models = ',mm
      do k=1,mm
        do i=1,npts
         cdat1(i)=cdat(i,k)
         cdat2(i)=cdat(i,mm+k)
        enddo
        write (51) cdat1   !mean track error
        write (51) cdat2   !track error standard deviation
      enddo
      goto 200
 100  print *,'ERROR writing output file'
 200  continue
      stop
      end
c
c--------------------------------------------
c
c--------------------------------------------
      FUNCTION LASTDOT (STRING)
C
C**   RETURNS THE POSITION OF THE LAST CHARACTER of a 
c     OF A STRING before the last dot in the string.  For
c     example, in the string trkdat.ep.ascii, it would 
c     return "9", for the position of the "p".
C
      CHARACTER*(*) STRING
C
      LAST = LEN(STRING)
C
      DO 10 I = LAST,1,-1
        IF (STRING(I:I).EQ.'.') then
          itmp = i - 1
          GO TO 20
        endif
   10 CONTINUE
C
      LASTDOT = 0
      RETURN
C
   20 LASTDOT = itmp
      RETURN
C
      END

