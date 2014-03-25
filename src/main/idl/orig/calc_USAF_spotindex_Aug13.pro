; calc_USAF_spotindex_Aug13.pro 
;
; this procedure based on calc_wdc_ssbvuv_05.pro
; expanded and upgraded to include more options and new sunspot data (eg Debrecen)
; started April 2012
; read WDC (and other) files of sunspot regions and calculate the
; sunspot blocking function, year by year : 1982 - 2008
;
; Notes:
; - the ssbl is determined for both bolometric and UV 320 nm radiation
; - the ssbl is determined only for the whole disk - but not in N&S hems
; - only one file is written (not the specfic station data individually)
; - the dependence of constrast on area is included
;
; ** NOTES for eventual upgrading of this procedure..
; need to address changing number of stations - decide which to
; keep or not
; also need to assess if "seeing" can be used to give a weighting based on
; quality
; need to streamline/generalize input and output file names
;
; write annual output files:  - with total and UV plus standard devs
; NOTE: nedd to run 2010 with both old old file and new Denig file
; so as to catch all data - then make composite SSB file by hand
;
rd=1
print,'Read in data, calculate sunspot blocking, write files  ....0'
print,'Plots ....1'
read,'Enter option',rd
ver='Apr12'
if(rd eq 1) then goto,plotit
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;     READ IN THE (generic) SOLAR ORIENTATION
; NOTE *** this is for a nominal year -  with 29 FEB = 28 FEB
;
close,5
openr,5,'/Users/hofmann/Documents/FCDR_Solar/betasun.dat'
beta=fltarr(366)
betad=fltarr(366)
;
dumi='    '
readf,5,dumi
kl=0
for ki=1,12 do begin
readf,5,io,no
;print,io,no
  for kj=1,no do begin
  readf,5,dumi
  beta(kl)=dumi
  betad(kl)=io+kj
;
;	print here if required
  fmt2='("  KL=",I3,"  KI=",I3,"  KJ=",I3,"  BETAD=",F8.2,"  BETA=",F8.4)'
;  print,format=fmt2,kl,ki,kj,betad(kl),beta(kl)
  kl=kl+1
  endfor
endfor
close,5
print,' Finished reading BETASUN with ',kl,' data points'
;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; read in the sunspot info and calculate blocking from USAF files
;
startyear=1982
;startyear=2013
;endyear=2013
startyear=2012
endyear=2012
;
; cycle through years from startyear (=1982) to endyear
for iyear=startyear,endyear do begin
if(iyear le 1999) then yy=iyear-1900
if(iyear ge 2000) then yy=iyear-2000
;
infile0='/Users/hofmann/Documents/FCDR_Solar/'
if(iyear lt 2000) then $
       infile='usaf_mwl.'+string(yy,'$(i2)')
if((iyear ge 2000) and (iyear le 2004)) then $
       infile=infile0+'usaf_mwl.0'+string(yy,'$(i1)')
if((iyear ge 2005) and (iyear lt 2010)) then $
       infile=infile0+'USAF.0'+string(yy,'$(i1)')
if(iyear eq 2010) then $
       infile=infile0+'USAF.10'
if(iyear eq 2011) then $
   infile=infile0+'usaf_'+string(yy,'$(i2)')+'.txt'
if(iyear eq 2012) then $
   infile=infile0+'solar_regions_reports_20'+string(yy,'$(i2)')+$
     '-processed.txt'
if(iyear eq 2013) then $
   infile=infile0+'solar_regions_reports_20'+string(yy,'$(i2)')+$
     'ytd-processed.txt'
 ;
; to check the values in Bill Denig's file - read the data from the end of
;  2010 from this file - to compare with existing 2010 file
; if(iyear eq 2010) then $
;    infile='~/data/solaractivity/sunspot_regions/USAF/USAF_Denig_2010-2012.txt'
; if(iyear gt 2010) then $
;    infile='~/data/solaractivity/sunspot_regions/USAF/USAF_Denig_2010-2012.txt'
;
;outfile='/home/lean/data/solaractivity/spotindex/SSB_USAF_'+$
;   string(iyear,'$(i4)')+'_'+ver+'.txt'
outfile='/Users/hofmann/Documents/FCDR_Solar/SSB_USAF_'+$
string(iyear,'$(i4)')+'_'+ver+'.txt' 
;
print,' Year is',iyear
print,' Infile is ',infile
print,' Outfile is ',outfile
print,'   '
print,'   '

;
;	NSERIAL are the station ID's of the individual observing stations
;	1=LEAR
;	2=CULG
;	3=SVTO
;	4=RAMY
;	5=BOUL
;	6=MWIL
;	7=HOLL
;	8=PALE
;	9=MANI
;      10=ATHN
;	OTHERS???
; NOTE *** string in 1995 and into 1996 there is a new station -
; called KANDILLI - that is not yet (as of DEC 96) included in these
; average ssb calculations
;	
;	*****  NOTES **************
;	Calculates the sunspot blocking function for
;	each of 8 individual stations
;	area is in units of the solar hemisphere (not disc) -
;	i.e., WDC area/1E6
;
; use variable contrast with area - cf Brandt et al
;
;	**** NOTE: B0 angle adjustment is included 
; this is a generic sun-earth distance with the value for 29 FEB equal
; to the value for 28 FEB
;
; more notes on contrast -
; for total radiation - Allen, 1979, p.184, umbra/photosphere=0.24
; and penumbra/photosphere=0.77
; also umra radius/penumbra radius=0.42
; thus umbral area = piiRumb^2 and penumbral area=pii(Rpen^2-Rumb^2)
; total spot area=piiRpen^2
; thus, area weighted contrast is ..
; 0.24piiRumb^2/piiRpen^2+0.77pii(Rpen^2-Rumb^2)/piiRpen^2=
; Cumb*0.1764+Cpen*0.8236
; 0.04234+0.634=0.6765
; and contrast-1=0.3235	; use this value now for bolometric
; and add area dependence ... contrast=0.2231+0.0244log10(A) - where A is
; total sunspot area in millionths of solar hemisphere
;
;
excess=0.3235
rsun=6.9599E10
au=1.495979E13
excess320=0.464	  ; use this value of UV
;
; the coeffs for 320 nm center-to-limb variation
; from Allen, 1979, p.171 are
cl320=[0.88,0.03]
; where I/I0=1.-cl320(0)-cl320(1)+cl320(0)*mu+cl320(1)*mu*mu
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;	Open files for reading in data and writing results
;
close,1,8
openr,1,infile
openw,8,outfile
fmt='("SSB :",I6," WITH AREA-DEPENDENT EXCESS:"," BOL=",F5.2," UV320=",F5.2)'
tt='   calc_spotindex_Apr12.pro'
printf,8,systime(0),tt
printf,8,format=fmt,iyear,excess,excess320
print,format=fmt,iyear,excess,excess320
;
ltest=fix(iyear/4)*4
ndays=365
if(ltest eq iyear)then ndays=366
if(iyear lt 2000) then iy=(iyear-1900)*10000.
if(iyear eq 2000) then iy=0
if(iyear gt 2000) then iy=(iyear-2000)*10000.
print,' IYEAR=',iyear,'   IY=',iy,'   NDAYS=',ndays
;
idate=fltarr(ndays)
numobs=fltarr(ndays)
area=fltarr(170,ndays)
amu=fltarr(170,ndays)
istn=fltarr(170,ndays)
alat=fltarr(170,ndays)
group=fltarr(170,ndays)
magf=fltarr(170,ndays)
spotnum=fltarr(170,ndays)
ssblock=fltarr(10,ndays)	; total Ps
ssbuv=fltarr(10,ndays)		;  sunspot blocking at 315 nm
nserial=fltarr(10)
;
avssbt=fltarr(ndays)		; average
stdevt=fltarr(ndays)		; standard deviation
avssbu=fltarr(ndays)
stdevu=fltarr(ndays)
;
nserial=findgen(10)+1
;
;     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;     GENERATE THE ARRAY OF DATES IN IDATE
if(ndays eq 366) then goto, cont740
;     GET HERE FOR YEAR THAT IS NOT A LEAP YEAR
for i=1,ndays do begin
   if(i le 31) then idate(i-1)=iy+101+(i-1)
   if((i gt 31) and (i le 59)) then idate(i-1)=iy+201+(i-32)
   if((i gt 59) and (i le 90)) then idate(i-1)=iy+301+(i-60)
   if((i gt 90) and (i le 120)) then idate(i-1)=iy+401+(i-91)
   if((i gt 120) and (i le 151)) then idate(i-1)=iy+501+(i-121)
   if((i gt 151) and (i le 181)) then idate(i-1)=iy+601+(i-152)
   if((i gt 181) and (i le 212)) then idate(i-1)=iy+701+(i-182)
   if((i gt 212) and (i le 243)) then idate(i-1)=iy+801+(i-213)
   if((i gt 243) and (i le 273)) then idate(i-1)=iy+901+(i-244)
   if((i gt 273) and (i le 304)) then idate(i-1)=iy+1001+(i-274)
   if((i gt 304) and (i le 334)) then idate(i-1)=iy+1101+(i-305)
   if((i gt 334) and (i le 365)) then idate(i-1)=iy+1201+(i-335)
endfor
goto, cont741
;
cont740:
;     GET HERE FOR A YEAR THAT IS A LEAP YEAR
for i=1,ndays do begin
   if(i le 31) then idate(i-1)=iy+101+(i-1)
   if((i gt 31) and (i le 60)) then idate(i-1)=iy+201+(i-32)
   if((i gt 60) and (i le 91)) then idate(i-1)=iy+301+(i-61)
   if((i gt 91) and (i le 121)) then idate(i-1)=iy+401+(i-92)
   if((i gt 121) and (i le 152)) then idate(i-1)=iy+501+(i-122)
   if((i gt 152) and (i le 182)) then idate(i-1)=iy+601+(i-153)
   if((i gt 182) and (i le 213)) then idate(i-1)=iy+701+(i-183)
   if((i gt 213) and (i le 244)) then idate(i-1)=iy+801+(i-214)
   if((i gt 244) and (i le 274)) then idate(i-1)=iy+901+(i-245)
   if((i gt 274) and (i le 305)) then idate(i-1)=iy+1001+(i-275)
   if((i gt 305) and (i le 335)) then idate(i-1)=iy+1101+(i-306)
   if((i gt 335) and (i le 366)) then idate(i-1)=iy+1201+(i-336)
endfor
cont741:
;
;     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;     READ IN THE SUNSPOT GROUP INFORMATION
cont1000:
on_ioerror,cont702
; read a dumi variable and extract the relevant data - different from Fortran
readf,1,dumi
print,dumi
IC=strmid(dumi,0,2)
my=fix(strmid(dumi,2,2))
mm=fix(strmid(dumi,4,2))
md=fix(strmid(dumi,6,2))
mut=strmid(dumi,9,4)
lathem=strmid(dumi,14,1)
xlat=strmid(dumi,15,2)
if(xlat eq '  ') then xlat=' 0'
xlat=float(xlat)
longhem=strmid(dumi,17,1)
along=strmid(dumi,18,2)
if(along eq '  ') then along=' 0'
along=float(along)
wils=strmid(dumi,20,4)
fld=strmid(dumi,25,1)
mwil=strmid(dumi,27,5)
smw=strmid(dumi,32,1)
noaa=strmid(dumi,33,5)
snoa=strmid(dumi,38,1)
zc=strmid(dumi,39,1)
pc=strmid(dumi,40,1)
cmpct=strmid(dumi,41,1)
numspot=strmid(dumi,43,2)
; check for no spots
if(numspot eq '  ') then numspot=' 0'
numspot=fix(numspot)
longext=strmid(dumi,46,2)
if(longext eq '  ') then longext='  0'
longext=fix(longext)
iarea=strmid(dumi,48,4)
if(iarea eq '    ') then iarea='-888'
iarea=float(iarea)
; check for missing area data ..NOTE - didn't need to do this is
; fortran version - assumed to be zero (but then included in count
; of number of spots ??? - these are primarily MWIL data)
IMPY=strmid(dumi,53,2)
IMPM=strmid(dumi,55,2)
CIMPD=strmid(dumi,57,4)
MPY=strmid(dumi,62,2)
MPM=strmid(dumi,64,2)
CMPD=strmid(dumi,66,4)
ISER=strmid(dumi,71,3)
AQU=strmid(dumi,75,1)
STATION=strmid(dumi,76,4)
; print,'test 1'
;
mdate=my*10000.+mm*100.+md
; print,dumi
; print,mdate,' ',mut,' ',lathem,xlat,' ',longhem,along,' ',wils,$
;    ' ',fld,' ',mwil,' ',noaa,' ',numspot,$
;    ' ',longext,' ',iarea,' ',station
;
  if(lathem eq 'S') then xlat=-xlat
  if(longhem eq 'E') then along=-along
  js=0
  if(station eq 'LEAR') then js=1
  if(station eq 'CULG') then js=2
  if(station eq 'SVTO') then js=3
  if(station eq 'RAMY') then js=4
  if(station eq 'BOUL') then js=5
  if(station eq 'MWIL') then js=6
  if(station eq 'HOLL') then js=7
  if(station eq 'PALE') then js=8
  if(station eq 'MANI') then js=9
  if(station eq 'ATHN') then js=10
;
; NOTE *** KANDILLI not yet included in the average ** as of DEC 96
;
  if(js eq 0) then print,' Ivalid station ',station
  if(js eq 0) then print,dumi
;
; now put the regions into the area and alat arrays for each day
for i=0,ndays-1 do begin
; print,i,mdate,idate(i)
    if(mdate ne idate(i)) then goto, cont701
    if(iarea eq -888.) then goto,cont701
    numobs(i)=numobs(i)+1
    if(numobs(i) gt 170.) then print,' NUMOBS=',numobs(i)
    num=numobs(i)
    area(num-1,i)=iarea
    alat(num-1,i)=xlat
; print,num,area(num-1,i),alat(num-1,i)
;
;	adjust for B0 
    date=idate(i)
; determine bsun for data from betad and beta arrays
;
;	For a leap year, 29 Feb set equal to 28 Feb
      	LB=-1
      	IY=fix(date/10.^4)
      	DD=date-IY*10000.
        cont30:
    	LB=LB+1
      	if(betad(lb) ne dd) then goto, cont30
      	bsun=beta(lb)
    blat=xlat-bsun
    if(abs(blat) ge 90.) then blat=90
    if(abs(along) ge 90.) then along=90

;	convert degrees to radians

    amu(num-1,i)=cos(blat*!pi/180.)*cos(along*!pi/180.)
; note that this quantity is not given in the 2011 file from Denig
    if((noaa ne '     ') and (noaa ne ' ////')) then group(num-1,i)=fix(noaa)
    
    spotnum(num-1,i)=numspot
    istn(num-1,i)=js
    if(station eq 'MWIL') then magf(num-1,i)=fld
cont701: 
endfor
;
goto, cont1000
cont702: print,iyear,' Finished reading file ..last date was ',mdate
;     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;
;     CALCULATE THE SUNSPOT BLOCKING FUNCTION FOR EACH OF THE EIGHT STATIONS
;	ON EACH DAY, THEN AVERAGE
;
for i=0,ndays-1 do begin
num=numobs(i)
if(num eq 0) then goto, cont611
;
; cycle through all the daily valid observations, sorting into the eight
; stations
    for n=0,num-1 do begin
; print for checking e.e.g. duplicate record 
; if(idate(i) eq 861221) then $
;    print,idate(i),n,istn(n,i),amu(n,i),area(n,i),group(n,i)
        for k=0,9 do begin
	if(istn(n,i) ne nserial(k)) then goto, cont601
;	check for duplicate data from an individual station
	idupl=0
           for m=0,num-1 do begin
	   if(istn(m,i) ne nserial(k)) then goto, cont603
	   if(amu(m,i) ne amu(n,i)) then goto, cont603
	   if(area(m,i) ne area(n,i)) then goto, cont603
	   if(group(m,i) ne group(n,i)) then goto, cont603
	   idupl=idupl+1
;	   set duplicate data to -888 (i.e., no data) IF M NE N
	   if(m ne n) then area(m,i)=-888.0
           cont603:
           endfor
if(idupl ge 2) then print,' idupl=',idupl
if(idupl ge 2) then print,idate(i),n,istn(n,i),amu(n,i),area(n,i),group(n,i)
;
;
; *** CALCULATE SUNSPOT BLOCKING HERE ***
; bypass duplicate record
if(area(n,i) eq -888.) then goto,cont601
; bolometric:
  sb=amu(n,i)*(3*amu(n,i)+2)/2.*area(n,i)*(0.2231+0.0244*alog10(area(n,i)))
; print for checking ...861221 has duplicate record
; if(idate(i) eq 861221) then print,i,n,amu(n,i),area(n,i),sb
  ssblock(k,i)=ssblock(k,i)+sb
; UV at 320 nm:
  ctl=1.-cl320(0)-cl320(1)+cl320(0)*amu(n,i)+cl320(1)*amu(n,i)*amu(n,i)
  sbuv=5.0*amu(n,i)*ctl/2.*area(n,i)*(0.2231+0.0244*alog10(area(n,i)))
  ssbuv(k,i)=ssbuv(k,i)+sbuv*excess320/excess
        cont601:
        endfor
    endfor
goto,cont612
;
cont611:
; set to -1 for no observations
ssblock(0:9,i)=-1
ssbuv(0:9,i)=-1
;
cont612:
fmt677='(I8,10F10.2)'
; NOTE: hemispheric data will be equal to -1 for no observation and zero for
; no measured sunspots
; print,format=fmt677,IDATE(I),SSBLOCK(0,I),SSBLOCK(1,I),SSBLOCK(2,I),$
;     	SSBLOCK(3,I),SSBLOCK(4,I),SSBLOCK(5,I),SSBLOCK(6,I),SSBLOCK(7,I)$
;     	,SSBLOCK(8,I),SSBLOCK(9,I)
;
;	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;	calculate mean values for SSBLOCK, SSBUV for this day
; sdlim = factor for rejecting data (> sdlim * stdev from avssb)
sdlim=4
;
; use total sunspot blocking data  - UV will follow proportionally
allt=ssblock(*,i)
allu=ssbuv(*,i)
r=where(allt gt 0,cnt)
if(cnt gt 1.) then resultt=moment(allt(r),sdev=stdt)
if(cnt gt 1.) then resultu=moment(allu(r),sdev=stdu)
;
if(cnt le 1.) then stdevt(i)=-999 else stdevt(i)=stdt
if(cnt eq 0.) then avssbt(i)=-999 else $
             if(cnt eq 1) then avssbt(i)=allt(r) else $
             if(cnt gt 1) then avssbt(i)=resultt(0)
if(cnt le 1.) then stdevu(i)=-999 else stdevu(i)=stdu
if(cnt eq 0.) then avssbu(i)=-999 else $
             if(cnt eq 1) then avssbu(i)=allu(r) else $
             if(cnt gt 1) then avssbu(i)=resultu(0)
;
;---------------------------------------------------------------------------
; for the jan97.rev files bypass this bit here
; had tried to include this is the jan96 version but made a mistake anyway---
; and jan96 and jan97 versions are almost identical
goto,contt
;
; check for major outliers 
; recalculate average by throwing out outliers
if(cnt ge 4.) then $ 
;  NOTE - error here was use of stdevt instead of stdevt(i) but not sure
; what difference this made ... so reado without throwing out any data
; ****   r=where((allt gt 0) and (abs(allt-avt) le stdevt*sdlim),cnt) ***
;
   r=where((allt gt 0) and (abs(allt-avt) le stdevt(i)*sdlim),cnt)
; reset the average  and stdev according to the new count
if(cnt ge 3.) then begin
resultt=moment(allt(r),sdev=sdtt)
resultu=moment(allu(r),sdev=sdtu)
stdevt(i)=sdtt
avssbt(i)=resultt(0)
stdevu(i)=stdu
avssbu(i)=resultu(0)
end
;
contt:
fmt678='(I12,4F10.2)'
printf,8,format=fmt678,IDATE(I),AVSSBT(i),STDEVT(i),AVSSBU(i),STDEVU(i)
;print,format=fmt678,IDATE(I),AVSSBT(i),STDEVT(i),AVSSBU(i),STDEVU(i)
;
; end of all days for the year
endfor
print,'  Sunspot blocking function for YEAR=',iyear
;
close,1,8
endfor
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
plotit:
plot,avssbt
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
cont100:
end
