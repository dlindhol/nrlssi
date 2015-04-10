; construct_nrlssi2_28Jan15.pro
;
; new model of solar spectral irradiance variability - for NOAA CDR
; consistent with SORCE observations - both SIM and TIM
;
; uses SORCE data obtained from web to develop models of both TSI and SSI
; this program based originally on ~/models/SEE_irrad_ssi/model_sorce_ssi_Jan11
; and ~/models/.SORCE_irrad/tsi/model_sorce_tsi_2012 - COMBINED
;
; NOTE: use the GOME Mg index throughout - including NRLSSI and NRLTSI calculations
; NOTE: problem with 2010 sunspot region info from latest site...
;
; NOTE: the ratio between the facular coeff for Mg (Vierecek) 
; and Mg (GOME) is 1.68150 - determined this from modelling using different
; indices: Mgquiet = 0.26268 for Vierecek and mgquiet=0.14990 for GOME
; ..ratio of quiet values (ie offsets) is 1.75 
;
; note: identify quiet sun as doy 207 of 2008  - 25th July - 
; ....use sbquiet=0, mgquiet=0.1501, tiquiet=1360.448
;
; added 3C model of TSI that includes testing an additional sunspot term..
; didnt improve model though ...need to revisit this in the 
; sunspot blocking calculations
;
; 28 AuG 2014 - added new SIM and SOLSTICE datasets prepared for 
; Sept 14 SSI workshop in Boulder
;
; 20 Nov - next generation of the model - using SSB with area-iondependent
; contrast and various other different tweeks
; use (only) SIM V20  - not V19)
; added TCTE data
; added uncertantiy estimates using matrices from John Emmert
;
; 21Nov 2014 - included option to use area-dependent or area-independent
; contrasts for SSB; NOTE - no new SSI file available at this time
;
; 25 Nov 2014 - start determining uncertainties
; 2 Dec 2014 - added suspot count to SSB file to help evaluate error budget
; 3 Dec 2014 - updated SORCE SSI data to SIM V21 - option to use
; SIM V20 or V21 and compare
; 30 Dec 2014 - use SIM V21 data file extended to same range as V20
; NOTE- also found (by Odele) error in SSB after 2010 - corrected this
; use separate upper and lower sigma limits for excluding noisy SIM data
;
; 31 Dec 14 - updated save file of parameters to include coefs to
; calculate uncertainties
; this version has uncertnatiy calculaions and assumes default SIM V21
; includes plot routines for "final" C-ATBD
; all files updated (including NRLSSI) for "final" model version on 23 Jan 2015
; 26 Jan 2015 began production of "final" version
; 28 Jan - updated TCTE data
;
@~/data/solaractivity/ft_geo/rd_geo_4.pro
@~/data/solaractivity/mgindex/interp_1.pro
@~/data/solaractivity/mgindex/interp_2.pro
@~/data/solaractivity/mgindex/interp_3.pro
@~/data/solaractivity/mgindex/interp_4.pro
@~/data/solaractivity/mgindex/interp_5.pro
@~/idlpros/box_smooth.pro
@~/idlpros/pg.pro
@~/idlpros/arcov_invert.pro
;
;-------------------------------------------------------------------------
rd=1
print,'  Read inputs    0'
print,'  Smooth mg, sb, ti, si, ca & la etc  time series    2'
print,'  Calculate NRLTSI2 variability model    3'
print,'  Calculate CaK & Lyalpha models          4'
print,'  Calculate Quiet Sun Spectrum    5'
print,'  Calculate SORCE SSI variability model    6'
print,'  Calculate NRLSSI2 variability model    7'
print,'  Calculate bin totals     8'
print,'  Calculate average spectra at min & max  9'
print,'  Calculate Reference Spectra (& write file)      10'
print,'  Periodograms ....50'
print,'  Write files ....500'
print,'  Make SAV file of model parameters  ...501'
print,'  Make SAV file of data arrays (this is large) ...502'
print,'  Print uncertainties for Tables, on seleced day ...503'
print,'  Plots 1'
read,' Enter option  ',rd
if(rd eq 0) then goto,readit
if(rd eq 1) then goto,plotit
if(rd eq 2) then goto,smoothit
if(rd eq 3) then goto,calctsi
if(rd eq 4) then goto,calccala
if(rd eq 5) then goto,calcquietspec
if(rd eq 6) then goto,calcsimssi
if(rd eq 7) then goto,calcnrlssi2
if(rd eq 8) then goto,binit
if(rd eq 9) then goto,avit
if(rd eq 10) then goto,calcrefspec
if(rd eq 50) then goto,pgit
if(rd eq 500) then goto,writeit
if(rd eq 501) then goto,saveparams
if(rd eq 502) then goto,saveit
if(rd eq 503) then goto,printuncert
;
;--------------------------------------------------------------
readit:
;
;;;;;;; CHANGE
modver='28Jan15'
;
;;;;;; Sept 14 workshop SSI database  SOLSTICE V13, SIM V20
simver=20
;;;;;;; 2Dec 2014 release - SIM V21
; simver=21
;;;;;;; 30Dec 2014 release - SIM V21
simver=21
;
; Read,'Use SIM Version 20 or 21 ',simver
adc=0
; Read,'Use area-independ (=0) or area-depend (=1) contrasts ',adc
seltim=0		; default is 0 - this is what was used for 26Jan15 model
; Read,'USe SORCE TIM only =0 or SORCE-TCTE composite =1 ',seltim
selmg=0
; default is GOME - use V+G only for testing
; Read,'select Mg index to use GOME=0,  Vireck=1 ',selmg
; set TSI offset for nrlssi and nrlssi2
nrloff=-5.05
;
; put all data on the same time grid that covers SORCE: 2003-present
;;;;;;; CHANGE
endyear=2014            ; last year (with data) of time series
ndy=julday(1,1,endyear+1)-julday(1,1,2003)
dy=findgen(ndy)+1     ; day number after 1 JAN 2003
jd=julday(1,1,2003)+dy-1
caldat,jd,datem,dated,datey
;
;--------------------------------------------------------------
; read in Yvonne's model estimate of separate sunspot and faculae effects
close,1
openr,1,'~/data/spectrum/yvonne_mod9_may99.txt'
yv9=dblarr(4,1108)
readf,1,yv9
close,1
; yv9(0,*) is wavelength in nm
; yv9(1,*) is solar flux
; yv9(2,*) is flux in faculae  
; yv9(3,*) is flux in spots   - adopted temp of 5150K
;
; expect that....
; yv9(3,*)/yv9(1,*) is sunspot contrast - and subtract 1 for residual
;                                           sunspot contrast 
; yv9(2,*)/yv9(1,*) is facular contrast - and subtract 1 for residual
;                                            facular contrast 
;----------------------------------------------------------------------
;
; restore model coefficients for calculating UV spectrum from save files
fn='~/CoI_missions/TSIS/NRLSSI_transition/MOD4_SOL_V0009_w1.sav'
restore,filename=fn
uvwl=wl		; rename the UV wavelength grid to avoid confusion
;                  with longer wavelength array - established later
; in these save files have ...
;  wl,inst,instrument,ver,sdlim,weight,
;  cuvfpxps,cuvfpxpsd,scontrast,uvfregress,uvfregressd,
;  refuvf,refps,refpx,quvf,qps,qpx,coefres,coefresd
;
; NOTE that refpx in this sav file is on the MgSEC scale
;
; E.G.  uvfregress(10,311)      ; regression coeffs with px and ps
; in the above array the elements are for the following data from REGRESS:
; 0= a0
; 1= coef for px
; 2= coef for UVps
; 3= standard dev for pxindex coef
; 4= standard dev for ps coef
; 5= ftest
; 6= correlation coeff for pxindex
; 7= correlation coeff for UVps
; 8= multiple regression correlation coeff
; 9= chisq
;
; the reconstructed irradiances are determined from the 
; detrended multiple regression analysis ...
;
; the UV spectrum reconsructed for given px and ps inpouts is..
; rcuv=dblarr(311)
; ee=1+uvfregressd(0,wl)+uvfregressd(1,wl)*(px-refpx)/refpx+$
;                 uvfregressd(2,wl)*(psuv-refps)/refps
; rcuv(wl)=refuvf(wl)*ee/100.
;
;-------------------------------------------------------------------------
; read in the NRLSSI spectral parameter arrays needed to calculate irradiance
; these parameters are only used for wavelengths longer than 400 nm
close,1
openr,1,'~/CoI_missions/TSIS/NRLSSI_transition/NRLSSI_spectrum_parameters.txt'
dumi='   '
for k=1,9 do begin
readf,1,dumi
if(k eq 7) then excess0=float(strmid(dumi,10,12))
if(k eq 7) then adjspot=float(strmid(dumi,36,12))
if(k eq 8) then pxqs=float(strmid(dumi,8,12))
endfor
;
dat=dblarr(4)
readf,1,dat
pxmin=dat(0)
pxmax=dat(1)
psmin=dat(2)
psmax=dat(3)
for k=11,13 do begin
readf,1,dumi
if(k eq 13) then pxmmin=float(strmid(dumi,10,10))
endfor
readf,1,nwl
print,'Number of VIS/IR spectral wavelengths is ',nwl
readf,1,dumi
specdat=dblarr(4,nwl)
readf,1,specdat
close,1
; specdat(0,*) is wl
; specdat(1,*) is irrqs
; specdat(2,*) is ssy
; specdat(3,*) is fac
;
; Calculate irrad at some wl for ps and px as follows:
; delatps=irrqs(wl)*ps/1.e6/excess0*(1-ssy(wl))*adjspot
; dpelatx=(px-px0)*fac(wl)
; irrad=irrqs(wl)-delatps+delatpx
print,'excess0=',excess0,'   adjspot=',adjspot
print,'pxqs=',pxqs
print,'pxmmin=',pxmmin
;
;----------------------------------------------------------------------
; read in SOLSPEC spectrum
; NOTE: need to check that this is the latest
close,1
openr,1,'~/data/spectrum/solspec_uvvi_v9_b.dat'
sspec=dblarr(2,962)
readf,1,sspec
; sspec(0,*) is wavelength in nm
; sspec(1,*) is irradiance - units are mW/m2/nm
close,1
;
;----------------------------------------------------------------------
; read in the Kurucz solar spectrum
;
; read in sun2
openr,1,'~/models/modtran3/databases.dir/sun2'
sun2=dblarr(2,49933)
readf,1,sun2
close,1
;
; sun2(0,*) is in wavenumber (cm-1)
; 1./sun2(1,*)*1000. is in micron
; sun2(1,*) is in W/cm^2/cm
; sun2(1,*) X 1.e4 is in W/m^2/cm
; sun2(1,*) X 1.e(4-3+7) is in mW/m^2/nm
;
; for plotting - use
; plot,1./sun2(0,*)*1.e4,sun2(1,*)*sun2(0,*)*sun2(0,*)
;
;----------------------------------------------------------------------
; read in SORCE WHI spectrum
close,1
openr,1,'~/data/spectrum/ref_solar_irradiance_whi-2008_ver2.dat'
dumi='   '
for k=1,142 do readf,1,dumi
wspec=dblarr(5,24000)
readf,1,wspec
; wspec(0,*) is wavelength in nm
; wspec(1,*) is irradiance - units are W/m2/nm
close,1
;
;----------------------------------------------------------------------
; read in WRC spectrum - from Phil Jenkins
close,1
openr,1,'~/data/spectrum/WRC_AM0Values.txt'
dumi='   '
readf,1,dumi
wrc=dblarr(3,920)
readf,1,wrc
; wrc(0,*) is wavelength in nm
; wrc(1,*) is irradiance - units are mW/cm2
close,1
;
;-------------------------------------------------------------------------
;;------ accumulate TSI & SSI data on daily grid from 2003 to present
dumi='   '
;
; wavelength grid for SORCE SSI data
nwv=2412-115
wv=findgen(nwv)+115.5		;center of wavelength bin
;;;;; set up arrays
tim=fltarr(ndy)-99.
tcte=fltarr(ndy)-99.
ti=fltarr(ndy)-99.		; combined tsi time series
si=fltarr(nwv,ndy)-99.		; use latest SORCE SSI
mgg=fltarr(ndy)-99.		; gome Mg
mgv=fltarr(ndy)-99.		; Viereck Mg
sb=fltarr(ndy)-99.
ft=fltarr(ndy)-99.
rz=fltarr(ndy)-99.
mwf=fltarr(ndy)-99.
mws=fltarr(ndy)-99.
;
;--------------------------------------------------------------
; read in GOME Mg composite index 
close,1
fn='~/data/solaractivity/mgindex/gome/'
fn=fn+'GOME_MgII_composite_21Jan15.dat'
openr,1,fn
dumi='   '
for k=1,21 do readf,1,dumi
;;;;; CHANGE
ng=13246.-21.
gome=dblarr(5,ng)
; gome(0,*) is decimal year
; gome(1,*) is month
; gome(2,*) is day
; gome(3,*) is Mg index
; gome(4,*) is source identifier
readf,1,gome
close,1
;
; put on grid from 2003 to present
for n=0,ng-1 do begin
arr=julday(gome(1,n),gome(2,n),fix(gome(0,n)))-julday(1,1,2003) 
if((arr ge 0) and (arr lt ndy)) then mgg(arr)=gome(3,n)
endfor
;
; note that there is one anomalously low values - fix this manually
g=where((mgg gt 0) and (mgg lt 0.1495))
mgg(g)=(mgg(g-1)+mgg(g+1))/2.
;
;------------------------------------------------------------------
; read in the Mg data on Viereck scale (but extended with GOME
;
close,1
;::: CHANGE
openr,1,'~/data/solaractivity/facindex/MgcompositeG_1978_2015_22Jan15.txt'
; NOTE - the length of data read in from this file needs to match the period of the
; overall data - otherwise, need to adjust code
dumi='   '
for k=1,7 do begin
readf,1,dumi
endfor
nv=13521-7
mgdat=fltarr(7,nv)
readf,1,mgdat
close,1
;
; put on grid from 2003 to present
for n=0,nv-1 do begin
arr=julday(mgdat(1,n),mgdat(2,n),fix(mgdat(0,n)))-julday(1,1,2003) 
if((arr ge 0) and (arr lt ndy)) then mgv(arr)=mgdat(6,n)
endfor
;
; note that there is one anomalously low values - fix this manually
v=where((mgv gt 0) and (mgv lt 0.2624))
mgv(v)=(mgv(v-1)+mgv(v+1))/2.
;
;;--------------------------------------------------------------
; select which Mg index to use for the model
; NTE - mgquiet is such that the Mg index is never zero
if(selmg eq 0) then begin
mg=mgg
mgquiet=0.1502
endif
if(selmg eq 1) then begin
mg=mgv
mgquiet=0.26268
endif
;--------------------------------------------------------------
; read in the ssb data - from new files made with both area-dependent and
; area-independent contrast
; NOTE sbquiet=0
;;;; CHANGE 
for yr=2003,endyear do begin
close,1
file='~/data/solaractivity/spotindex/SSB/SSB_USAF_'+$
                         string(yr,'$(i4)')+'_Dec14.txt'
openr,1,file
dumi='   '
ytst=fix(yr/4.)*4
if(ytst eq yr) then ndays=366 else ndays=365
readf,1,dumi & print,dumi
readf,1,dumi & print,dumi
sbdat=fltarr(6,ndays)
; the WDC files have data, SSB-ADC, stdev, SSB-AIC, stdev, spotnum
; - since these were derived from multi-station data
readf,1,sbdat
; the relevant SSB data is in column 1 - with one data point per day of the
; year, and -999 for missing data
; accumulate arrays - so as to save sdevs of sb
if(yr eq 2003) then sbdatall=transpose(sbdat)
if(yr gt 2003) then sbdatall=[sbdatall,transpose(sbdat)]
; put the SSB into the correct location in the PS array
narr=julday(1,1,yr)-julday(1,1,2003)
if(adc eq 1) then ss=sbdat(1,*)
if(adc eq 0) then ss=sbdat(3,*)
if(narr ge 0) then sb(narr)=ss(0:*)
endfor
;
;---------------------------------
; read in ft for checking px and rz for checking ps
;;;; CHANGE
for yr=2003,endyear do begin
rd_geo_4,yr,dat
nds=n_elements(dat(0,*))
print,'Year is',yr,' with ',nds,' days'
;   set decimal year array on half day grid
day=(findgen(nds)+0.5)/float(nds)+yr
ddd=findgen(nds)+1
yyy=fltarr(nds)+yr
ff=transpose(dat(1,*))          ; f10
kk=transpose(dat(2,*))          ; kp
rr=transpose(dat(0,*))          ; rz
aa=transpose(dat(3,*))          ; ap
narr=julday(1,1,yr)-julday(1,1,2003)
ff=transpose(dat(1,*))
ft(narr)=ff(0:*)
rr=transpose(dat(0,*))
rz(narr)=rr(0:*)
close,1
endfor
;
; check for spurious points
ft0=ft
r=where(ft0 lt 50,cnt)
if(cnt gt 0) then begin
print,' Spurious low data in Ft',cnt
print,'Need to interpolate.... depends on where data are missing'
ft(r(0))=(ft(r(0)-1)+ft(r(0)+1))/2.
ft(r(1))=(ft(r(1)-1)+ft(r(1)+1))/2.
ft(r(2))=(ft(r(2)-1)+ft(r(2)+1))/2.
ft(r(3))=(ft(r(3)-1)+ft(r(3)+1))/2.
endif
r=where(ft0 gt 800,cnt)
if(cnt gt 0) then begin
print,' Spurious high data in Ft',cnt
print,'Need to interpolate.... depends on where data are missing'
ft(r(0))=(ft(r(0)-1)+ft(r(0)+1))/2.
endif
;
; convert to mg values - for checking later
r1=mg gt 0
r2=ft gt 0
r=where(r1*r2)
cf0=poly_fit(ft(r),mg(r),1)
ftpx=poly(ft,cf0)
;
; fill in true zero values when sunspot number is zero
; these are valid numbers
r1=rz eq 0
r2=sb lt 0
r=where(r1*r2)
sb(r)=0 
;
; correct eroneous value in mid 2011
r1=dy/365.25+2003 gt 2011.4
r2=dy/365.25+2003 lt 2011.5
r3=sb gt 1500
r=where(r1*r2*r3)		; there should be one value
sb(r(0))=(sb(r(0)-1)+sb(r(0)+1))/2.
;
; interpolate missing values
;;;;;; CHECK, CHANGE as needed
sb0=sb
dati=rz
dat=sb0
interp_1,dat
interp_3,dat,dati
interp_4,dat,dati
interp_5,dat,dati
sb=dat
;
;;;;;;; CHECK, CHANGE as needed
; do some additional linear interpolation on selected subsets - 
; need to determine appropriate time intervals by hand
r1=dy/365.25+2003 gt 2009.95
r2=dy/365.25+2003 lt 2010.75
r3=sb ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sb(rb),dy(rb),dy(ra))
sb(ra)=dati
;
;--------------------------------------------------------------
; read in SORCE TIM data
close,1
;;;; CHANGE 
scfn='sorce_tsi_L3_c24h_latest_23Jan15.txt'
openr,1,'~/CoI_missions/SORCE/TSI_data/'+scfn
;
dumi='   '
for k=1,120 do begin
readf,1,dumi
endfor
ntim=4463-120
timdat=dblarr(15,ntim)
readf,1,timdat
close,1
; put on common grid after 2003
for n=0,ntim-1 do begin
; NOTE: may need to check this julday hh,mm,ss values - for higher time res
narr=timdat(1,n)-julday(1,1,2003,0,0,0)
; for daily use
narr=timdat(1,n)-julday(1,1,2003)
; alternative to use for daily means
xx=timdat(0,n)
yy=fix(xx/10000.)
mm=fix((xx-yy*10000.)/100.)
dd=xx-mm*100.-yy*10000.
narr=julday(mm,dd,yy)-julday(1,1,2003)
if(narr lt ndy) then tim(narr)=timdat(4,n)
endfor
; reset missing values
r=where(tim le 0)
tim(r)=-99.
tiquiet=1360.45
;
;------------------------------------------------
; TCTE TIM data
close,1
openr,1,'~/data/scon/meas/tcte_tsi_L3_c24h_latest_28Jan15.txt'
;
dumi='   '
;;;;;;;; CHANGE
for k=1,120 do begin
readf,1,dumi
endfor
;;;;;;;; CHANGE
ntcte=525-120
tctedat=dblarr(15,ntcte)
readf,1,tctedat
close,1
; put on common grid
for n=0,ntcte-1 do begin
; NOTE: may need to check this julday hh,mm,ss values - for higher time res
narr=tctedat(2,n)-julday(1,1,2003,0,0,0)
; for daily use
narr=tctedat(2,n)-julday(1,1,2003)
; alternative to use for daily means
xx=tctedat(0,n)
yy=fix(xx/10000.)
mm=fix((xx-yy*10000.)/100.)
dd=xx-mm*100.-yy*10000.
narr=julday(mm,dd,yy)-julday(1,1,2003)
if(narr lt ndy) then tcte(narr)=tctedat(4,n)
endfor
;
; make compsite ti time series - start with tim and integrate tcte
ti0=tim
ti1=ti0
r=where((tim le 0) and (tcte gt 0))
ti1(r)=tcte(r)
if(seltim eq 0) then ti=ti0
if(seltim eq 1) then ti=ti1
;
; -------------------------------------------------------
; retrieve SORCE SSI data from web site
;
close,1
if(simver eq 20) then $
      sifn='sorce_ssi_L3_c24h_0000nm_2413nm_20030301_20130730_V20.txt'
if(simver eq 21) then $
      sifn='sorce_ssi_L3_c24h_0000nm_2413nm_20030227_20130730_V21.txt'
openr,1,'~/CoI_missions/SORCE/SSI_data/'+sifn
;
dumi='   '
for j=0,78 do readf,1,dumi
nsor=double(strmid(dumi,36,10))		; number of data records
print,'Reading SIM VERSION',simver,'number of data records is ',nsor
ssidat=dblarr(9,nsor)
readf,1,ssidat
;
; the ssidat are daily mean spectra
; ***DATA DEFINITIONS***, number = 9 (name, type, format)
; nominal_date_yyyymmdd, R8, f10.1
; nominal_date_jdn, R8, f10.1
; min_wavelength, R4, f8.2 (nm)
; max_wavelength, R4, f8.2 (nm)
; instrument_mode_id, I2, i3
; data_version, I2, i3
; irradiance, R4, e11.4 (W/m^2/nm)
; irradiance_uncertainty, R4, e11.4 (W/m^2/nm, 1 sigma)
; quality, R4, f8.4 (avg # days between nominal date and measurement times)
; ***END DATA DEFINITIONS***
;
; cycle through each day and find the SSI spectrum for that day
; then interpolate to 1 nm grid
sordy=ssidat(1,*)-julday(1,1,2003)+1   ; array of day number for source record
for n=0,ndy-1 do begin
; select sorce spectrum for this day 
rd=where(sordy eq dy(n),cntdy)
sorwl=(ssidat(2,rd)+ssidat(3,rd))/2.
sorflx=ssidat(6,rd)
; regrid the spectrum separately for each instrument
;;;;; SOLSTICE FUV
r1=sorwl gt 115.0
r2=sorwl lt 180
r3=sorflx gt 0
rw=where(r1*r2*r3,cntw)
; for a full FUV spectrum there should be 65 points
if(cntw eq 65) then begin
; interpolate onto 1 nm grid 
ngg=fix(sorwl(rw(cntw-1))-sorwl(rw(0))+1)
gg=findgen(ngg)+sorwl(rw(0))
yy=interpol(sorflx(rw),sorwl(rw),gg)
; put this spectrum into the approriate part of the si array
si(gg(0)-115.5:gg(0)-115.5+ngg-1,n)=yy
endif
;
;;;;; SOLSTICE MUV
r1=sorwl gt 180.0
r2=sorwl lt 310
r3=sorflx gt 0
rw=where(r1*r2*r3,cntw)
; for a full muv spectrum there should be 130 points
if(cntw eq 130) then begin
; interpolate onto 1 nm grid 
ngg=fix(sorwl(rw(cntw-1))-sorwl(rw(0))+1)
gg=findgen(ngg)+sorwl(rw(0))
yy=interpol(sorflx(rw),sorwl(rw),gg)
; put this spectrum into the approriate part of the si array
si(gg(0)-115.5:gg(0)-115.5+ngg-1,n)=yy
endif
;
;;;;; SIM
r1=sorwl gt 310.1
r2=sorwl lt 2412
r3=sorflx gt 0.01
rw=where(r1*r2*r3,cntw)
; note - avoid 310.02 since this has zero flux typically
; for a full vis-ir spectrum there should be >700 points
if(cntw gt 600) then begin
; interpolate onto 1 nm grid - unlike FUV and MUV the SIM data are 
; not on 1 nm grid so need to specify the grid to be from 310.5 to 2400.5
ngg=fix(sorwl(rw(cntw-1))-sorwl(rw(0))+1)
gg=findgen(ngg)+sorwl(rw(0))
yy=interpol(sorflx(rw),sorwl(rw),gg)
; put this spectrum into the approriate part of the si array
si(gg(0)-115.5:gg(0)-115.5+ngg-1,n)=yy
endif
; end of cycling through days of grid
endfor
;
if(simver eq 20) then si20=si
if(simver eq 21) then si21=si
;-------------------------------------------------------------------------
;;------  accumulate mg and ssb model components on daily grid from 1978 to present
; also NRLSSI and NRLTSI original versions
;
ndyall=julday(1,1,endyear+1)-julday(1,1,1978)
dyall=findgen(ndyall)+1     ; day number after 1 JAN 1978
jdall=julday(1,1,1978)+dyall-1
caldat,jdall,mmall,ddall,yyrall
;
mgallg=fltarr(ndyall)-99.
mgallv=fltarr(ndyall)-99.
sball=fltarr(ndyall)-99.
wls=fltarr(ndyall)-99.		; Wang Lean Sheeley TSI model
;
; composite GOME Mg index 
; put the Mg data into the correct location in the mg array
for nn=0,ng-1 do begin
arr=julday(gome(1,nn),gome(2,nn),gome(0,nn))-julday(1,1,1978)
; NOTE- choose the time series with missing values already interpolated 
if((arr ge 0) and (arr lt ndyall)) then mgallg(arr)=gome(3,nn)
endfor
;
; note that there is one anomalously low values - fix this manually
g=where((mgallg gt 0) and (mgallg lt 0.1495))
mgallg(g)=(mgallg(g-1)+mgallg(g+1))/2.
;
; composite Viereck (scale) Mg index 
; put the Mg data into the correct location in the mg array
for nn=0,nv-1 do begin
arr=julday(mgdat(1,nn),mgdat(2,nn),mgdat(0,nn))-julday(1,1,1978)
; NOTE- choose the time series with missing values already interpolated 
if(arr ge 0) then mgallv(arr)=mgdat(5,nn)
endfor
;
; note that there is one anomalously low values - fix this manually
v=where((mgallv gt 0) and (mgallv lt 0.2624))
mgallv(v)=(mgallv(v-1)+mgallv(v+1))/2.
;
;;--------------------------------------------------------------
; select which Mg index to use for the model
; NTE - mgquiet is siuch that the Mg index is never zero
if(selmg eq 0) then mgall=mgallg
if(selmg eq 1) then mgall=mgallv
;
;--------------------------------------------------------------
; read in the ssb data - from files in 2012 in spot index directory
;;;; CHANGE 
for yr=1978,endyear do begin
close,1
if(yr le 1981) then $
            file='~/data/solaractivity/spotindex/SSB/SSB_GW_'+$
                         string(yr,'$(i4)')+'_Nov14.dat'
if(yr ge 1982) then  $
  file='~/data/solaractivity/spotindex/SSB/SSB_USAF_'+$
                         string(yr,'$(i4)')+'_Dec14.txt'
openr,1,file
dumi='   '
ytst=fix(yr/4.)*4
if(ytst eq yr) then ndays=366 else ndays=365
readf,1,dumi & print,dumi
readf,1,dumi & print,dumi
;
if(yr le 1981) then sbdat=fltarr(3,ndays)
; the GW files have date, SSB-ADC, SSB-AIC
if(yr ge 1982) then sbdat=fltarr(6,ndays)
; the WDC files have data, total SSB, stdev, UV SSB, stdev
; - since these were derived from multi-station data
readf,1,sbdat
; the relevant SSB data is in column 1 - with one data point per day of the
; year, and -999 for missing data
; put the SSB into the correct location in the PS array
narr=julday(1,1,yr)-julday(1,1,1978)
if(yr le 1981) then begin
if(adc eq 0) then ss=sbdat(2,*)
if(adc eq 1) then ss=sbdat(1,*)
endif
if(yr ge 1982) then begin
if(adc eq 0) then ss=sbdat(3,*)
if(adc eq 1) then ss=sbdat(1,*)
endif
if(narr ge 0) then sball(narr)=ss(0:*)
endfor
;
; ---------------------------------
; read in ftall and rzall for checking mgall and sball 
ftall=fltarr(ndyall)
rzall=fltarr(ndyall)
;;;; CHANGE
for yr=1978,endyear do begin
rd_geo_4,yr,dat
nds=n_elements(dat(0,*))
print,'Year is',yr,' with ',nds,' days'
;   set decimal year array on half day grid
day=(findgen(nds)+0.5)/float(nds)+yr
ddd=findgen(nds)+1
yyy=fltarr(nds)+yr
ff=transpose(dat(1,*))          ; f10
kk=transpose(dat(2,*))          ; kp
rr=transpose(dat(0,*))          ; rz
aa=transpose(dat(3,*))          ; ap
narr=julday(1,1,yr)-julday(1,1,1978)
ff=transpose(dat(1,*))
ftall(narr)=ff(0:*)
rr=transpose(dat(0,*))
rzall(narr)=rr(0:*)
close,1
endfor
;
; check for spurious points
ftall0=ftall
r=where(ftall0 lt 50,cnt)
print,' Spurious low data in Ft',cnt
print,'Need to interpolate.... depends on where data are missing'
; select (by hand) the isolated days of missing values
for n=0,5 do begin
ftall(r(n))=(ftall(r(n)-1)+ftall(r(n)+1))/2.
endfor
r=where(ftall0 gt 800,cnt)
print,' Spurious high data in Ftall',cnt
print,'Need to interpolate.... depends on where data are missing'
ftall(r(0))=(ftall(r(0)-1)+ftall(r(0)+1))/2.
;
; fill in true zero values when sunspot number is zero
; these are valid numbers
r1=rzall eq 0
r2=sball lt 0
r=where(r1*r2)
sball(r)=0 
; correct eroneous value in mid 2011
r1=dyall/365.25+1978 gt 2011.4
r2=dyall/365.25+1978 lt 2011.5
r3=sball gt 1500
r=where(r1*r2*r3)		; there should be one value
sball(r(0))=(sball(r(0)-1)+sball(r(0)+1))/2.
;
; interpolate missing values
;;;;;; CHECK, CHANGE as needed
sball0=sball
dati=rzall
dat=sball0
interp_1,dat
interp_3,dat,dati
interp_4,dat,dati
interp_5,dat,dati
sball=dat
;
;;;;;;; CHECK, CHANGE as needed
; do some additional linear interpolation on selected subsets - 
; need to determine appropriate time intervals by hand
r1=dyall/365.25+1978 gt 1983.95
r2=dyall/365.25+1978 lt 1984.05
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
r1=dyall/365.25+1978 gt 1985.4
r2=dyall/365.25+1978 lt 1985.7
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
r1=dyall/365.25+1978 gt 1987.1
r2=dyall/365.25+1978 lt 1987.2
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
r1=dyall/365.25+1978 gt 1986.95
r2=dyall/365.25+1978 lt 1987.04
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
r1=dyall/365.25+1978 gt 1995.97
r2=dyall/365.25+1978 lt 1996.03
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
r1=dyall/365.25+1978 gt 1996.05
r2=dyall/365.25+1978 lt 1996.1
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
r1=dyall/365.25+1978 gt 1997.05
r2=dyall/365.25+1978 lt 1997.2
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
r1=dyall/365.25+1978 gt 2009.95
r2=dyall/365.25+1978 lt 2010.75
r3=sball ge 0
ra=where(r1*r2)
rb=where(r1*r2*r3)
dati=interpol(sball(rb),dyall(rb),dyall(ra))
sball(ra)=dati
;
;----------------------------------------------------------------------
; read in existing NRL TSI model 
close,1
dumi='   '
fn='~/models/sparc/tsi/mar2001/extend/TSI_WLS_day_23Jan15_G.txt'
; daily values from 1882 to 2014 inclusive
openr,1,fn
for j=0,2 do readf,1,dumi
wlsdat=fltarr(5,48577)
readf,1,wlsdat
; extract TSI since 1978
narr=julday(1,1,1978)-julday(1,1,1882)
wls(0:ndyall-1)=wlsdat(4,narr:*)
close,1
;
; extract array for dy grid (2003 onwards)
nrlti=fltarr(ndy)
narr=julday(1,1,2003)-julday(1,1,1882)
nrlti(0:ndy-1)=wlsdat(4,narr:*)
;
;----------------------------------------------------------------------
; read in existing NRLSSI MODEL 
;
nband=3780
wldat=fltarr(2,nband)
close,1
;;;;;;;;;;;CHANGE
openr,1,'~/models/sparc/ssi/katja/katja_spectra_1978_2014d_23Jan15_G.txt'
dumi='   '
readf,1,dumi & print,dumi
readf,1,dumi & print,dumi
readf,1,dumi & print,dumi
readf,1,dumi & print,dumi
dat=fltarr(nband)
readf,1,dat
wldat(0,*)=dat
readf,1,dumi &print,dumi
readf,1,dat
wldat(1,*)=dat
readf,1,dumi &print,dumi
readf,1,dumi &print,dumi
;
; now cycle thru days & read spectra from 1978 to 2014, inclusive
nnrl=julday(1,1,endyear+1)-julday(1,1,1978)
; NOTE that these files have data corresponding directly to the dyall array..check
if(nnrl ne ndyall) then print,' NRLSSI time array not equal to dyall '
nrltiall=fltarr(nnrl)
nrlsiall=fltarr(nband,nnrl)
nrlsi=fltarr(nband,ndy)
dat0=fltarr(4)
dat=fltarr(nband)
for n=0,nnrl-1 do begin
readf,1,dat0
yrd=dat0(0)
mnd=dat0(1)
dyd=dat0(2)
narr=julday(dat0(1),dat0(2),dat0(0))-julday(1,1,1978)
nrltiall(narr)=dat0(3)     ; calculated directly from TSI model
readf,1,dat
nrlsiall(*,narr)=dat
;
; extrat NRLSSI spectra for dy grid (from 2003 onwards)
narr=julday(dat0(1),dat0(2),dat0(0))-julday(1,1,2003)
if(narr ge 0) then nrlsi(*,narr)=dat
endfor
;
nrlwv=wldat(0,*)		; this is the center wavelength of the bin
nrlwvb=wldat(1,*)		; this is the width of the bin
;
; add up nrlsiall flux to find total
; note = this assumes that dyall = nnrl
if(nnrl ne ndyall) then print,'NRLSSI not all days of grid'
nrlsialltot=fltarr(ndyall)
for n=0,ndyall-1 do begin
xx=nrlsiall(*,n)
nrlsialltot(n)=total(xx*nrlwvb)/1000.
endfor
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; read in Sac Pk Ca K data - use for checking regression approach for UV
;
ca=fltarr(ndy)-99.
caall=fltarr(ndyall)-99.
close,1
fn='~/data/solaractivity/spcak/SacPk_cak_parameters_21Jan15.txt'
;
openr,1,fn
dumi='   '
nsp=4023
spcak=fltarr(10,nsp)
; array elements are 
; MM DD  YYYY  EMDX       VIORED   K2VK3   DELK1    DELK2     DELWB   K3
readf,1,dumi
readf,1,spcak
close,1
; put on common grid
for k=0,nsp-1 do begin
arr=julday(spcak(0,k),spcak(1,k),spcak(2,k))-julday(1,1,2003)
if(arr ge 0) then ca(arr)=spcak(9,k)
arr=julday(spcak(0,k),spcak(1,k),spcak(2,k))-julday(1,1,1978)
if(arr gt 0) then caall(arr)=spcak(9,k)
endfor
;
caquiet=0.06
;;----------------------------------------------------
; -------read in Mt Willson spot and facular indices and put into 
; spot and fac arrays
close,1
fn='~/data/solaractivity/MtWillson/MtWillson_fac_spot_1970_11Dec12.txt'
openr,1,fn
dumi='   
nmw=11331
mwdat=fltarr(3,nmw)
; mwdat(0,*) is day number after noon 23 May 1968 (JD 2440000 is j0.0 in this file)
; mwdat(1,*) is plage index
; mwdat(2.*) is spot index
readf,1,mwdat
close,1
;
;;;----------------------------------------------------
; read in composite Lyman alpha record
fn='~/data/spectrum/LASP_composite_Lya_26Jan15.txt/
openr,1,fn
dumi='   '
readf,1,dumi
nla=24811
ladat=fltarr(4,nla)
laall=fltarr(ndyall)-99.
for n=0,nla-1 do begin
readf,1,dumi
ladat(0,n)=strmid(dumi,0,4)			; year
ladat(1,n)=strmid(dumi,4,3)			; day of year
ladat(2,n)=strmid(dumi,8,5)			; Lya irrad
ladat(3,n)=strmid(dumi,14,2)			; type
arr=julday(1,1,ladat(0,n))+ladat(1,n)-julday(1,1,1978)-1
if((arr ge 0) and (arr lt ndy))then laall(arr)=ladat(2,n)
endfor
close,1
;
laquiet=3.41
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
smoothit:
sm=40
; smooth the mg and sb time series
; do this by smoothing twice with box_smooth
xx=sb
box_smooth,xx,sm,smxx1
box_smooth,smxx1,sm,smxx2
smsb=smxx2
xx=sball
box_smooth,xx,sm,smxx1
box_smooth,smxx1,sm,smxx2
smsball=smxx2
;
xx=mg
box_smooth,xx,sm,smxx1
box_smooth,smxx1,sm,smxx2
smmg=smxx2
;
xx=mgall
box_smooth,xx,sm,smxx1
box_smooth,smxx1,sm,smxx2
smmgall=smxx2
;
xx=ca
box_smooth,xx,sm,smxx1
smca=smxx1
;
xx=caall
box_smooth,xx,sm,smxx1
smcaall=smxx1
;
xx=laall
box_smooth,xx,sm,smxx1
box_smooth,smxx1,sm,smxx2
smlaall=smxx2
;
; smooth the ti time series
; do this by smoothing twice with box_smooth
xx=ti
box_smooth,xx,sm,smxx1
box_smooth,smxx1,sm,smxx2
smti=smxx2
;
; smooth the 1 nm gridded daily mean SORCE SSI time series in si array
; similarly
smsi=fltarr(nwv,ndy)
; cycle through all wavelengths on the 1 nm grid
for j=0,nwv-1 do begin
xx=si(j,*)
r=where(xx gt 0)
; check for outliers
result=moment(xx(r),sdev=sdev)
r=where(abs(xx-result(0)) gt sdev*3.,cnt)
if(cnt gt 0) then xx(r)=-99
; repeat for smaller spikes
r=where(xx gt 0)
result=moment(xx(r),sdev=sdev)
r=where(abs(xx-result(0)) gt sdev*3.,cnt)
if(cnt gt 0) then xx(r)=-99
; repeat again for smaller spikes
r=where(xx gt 0)
result=moment(xx(r),sdev=sdev)
r=where(abs(xx-result(0)) gt sdev*3.,cnt)
if(cnt gt 0) then xx(r)=-99
;
box_smooth,xx,sm,smxx
smsi(j,*)=smxx
endfor
;
if(simver eq 20) then smsi20=smsi
if(simver eq 21) then smsi21=smsi
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calctsi:
;
; TWO COMPONENT MULTIPLE REGRESSION ANALYSIS of SORCE TSI observations
;
; calculate the TSI model in three different ways:
;  1 - using direct time series
;  2 - using residual from mean values (as used for SSI model)
;  3 - using zero mean unit variance time series
;
tsityp=['Direct','Detrended','ZeroMean']
ntt=n_elements(tsityp)
;
daystart=julday(1,1,2003)-julday(1,1,2003)+1
daystop=julday(12,31,endyear)-julday(1,1,2003)+1
;  otherwise..select a sub interval
; daystart=julday(4,1,2004)-julday(1,1,2003)+1
; daystop=julday(12,31,2007)-julday(1,1,2003)+1
ss1=dy ge daystart
ss2=dy le daystop
;
xx=fltarr(2,ndy)
; arrays for holding the parameters to reconstruct the fractional changes
tiparam=fltarr(11,ntt)		; 11 parameters for three different models
; 0 = a0 fitted
; 1 = result(0) - fitted coef for mg term
; 2 = result(1) - fitted coef for sb term
; etc
; reconstructed time series - flux plus facular and sunspot components -
; for three differnet models
rcti=fltarr(ndy,3,ntt)-99.
rctiunc=fltarr(ndy,4)-99.	; uncertainty components-  direct regression
rctiall=fltarr(ndyall,3,ntt)-99.
;
print,'SORCE TI 2C model: '
; use actual data for the regression
r1=mg gt 0
r2=sb ge 0
r3=ti gt 0
r4=smmg gt 0
r5=smsb gt 0
r6=smti gt 0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for tt=0,ntt-1 do begin
; for tt=0,0 do begin
; print results:
;------------------------------------------------------------------
;  DIRECT REGRESSION - including matric inversion, for comparison
if(tt eq 0) then begin
xx(0,*)=mg-mgquiet
xx(1,*)=sb
yy=ti-tiquiet
rfit=where(ss1*ss2*r1*r2*r3,cntfit)
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
tiparam(0,tt)=a0
tiparam(1,tt)=result(0)
tiparam(2,tt)=result(1)
tiparam(3:4,tt)=sigma		; sigma
tiparam(5:6,tt)=cc		; correlation
tiparam(7,tt)=cnt		; number of days used for the regression
tiparam(8,tt)=rmul
tiparam(9,tt)=ftest
tiparam(10,tt)=chisq
;
; reconstruct the flux from the fitting parameters
rci=a0+result(0)*xx(0,*)+result(1)*xx(1,*)+tiquiet
; also reconstruct individual components
rcf=result(0)*xx(0,*)+a0       ; facular component
rcs=result(1)*xx(1,*)      ; sunspot component
rcti(*,0,tt)=rci		; reconstructed irradiance
rcti(*,1,tt)=rcf		; reconstructed facular component
rcti(*,2,tt)=rcs		; reconstructed spot component
; reset missing values
r=where(mg lt 0,cnt)
if(cnt gt 0) then rcti(r,0:2,tt)=-99.
r=where(sb lt 0,cnt)
if(cnt gt 0) then rcti(r,0:2,tt)=-99.
;
; calculate historical values use sball and mgall time series 
rci=a0+result(0)*(mgall-mgquiet)+result(1)*sball+tiquiet
; and reconsruct individual components
rcf=result(0)*(mgall-mgquiet)+a0	; facular component
rcs=result(1)*sball  	; sunspot component
rctiall(*,0,tt)=rci		; reconstructed irradiance
rctiall(*,1,tt)=rcf		; reconstructed facular component
rctiall(*,2,tt)=rcs		; reconstructed spot component
; reset missing values
r=where(mgall lt 0,cnt)
if(cnt gt 0) then rctiall(r,0:2,tt)=-99.
r=where(sball lt 0,cnt)
if(cnt gt 0) then rctiall(r,0:2,tt)=-99.
;
; also calculate coeffs using matrix inversion - from John Emmert
; first fill in missing values to zero instead of -99 ..note - 
qqdat=yy(rfit)
ppdat=fltarr(3,cntfit)
ppdat(0,*)=1.
ppdat(1,*)=xx(0,rfit)
ppdat(2,*)=xx(1,rfit)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression - ie in the result array
qresid=qqt-ppdat##coeff0		; this should match w0 ??
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cntfit)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((4)*indgen(3)))
;
;-----------------------------------------------------------------------------
; calculate uncertainties for direct regression model (only)
if(tt eq 0) then begin
rctiunc(*,1)=qsigma(0)
mgu=0.20		; mg index uncertainty
facunc2=(qsigma(1)/coeff0(1))^2+((xx(0,*)*mgu)/xx(0,*))^2
; NOTE - this next bit assumes that sbdatall and xx arrys have the same number
; of days
; sbu=sbdatall(*,4)/sqrt(sbdatall(*,5))
; r=where(sbu le 0)
sbu=0.2		; this is the average stdev/sqrt(spotcnt-1)
spotunc2=(qsigma(2)/coeff0(2))^2+((xx(1,*)*sbu)/xx(1,*))^2
rctiunc(*,2)=abs(result(0)*xx(0,*))*sqrt(facunc2)		; facular 
;                                                              uncertainty
rctiunc(*,3)=abs(result(1)*xx(1,*))*sqrt(spotunc2)	; sunspot uncertainty
; total uncertainty
rctiunc(*,0)=rctiunc(*,1)+rctiunc(*,2)+rctiunc(*,3)
endif	
;
;;;;;; print results
print,'NRLTSI2 model 2C '+tsityp(tt)
print,dy(rfit(0))/365.25+2003,dy(rfit(cntfit-1))/365.25+2003,a0,result(0),result(1),rmul

ttt='                   const   sigma     Mg-coef     sigma    SB-coef'
ttt=ttt+'      sigma'
print,ttt
fmt='(a15,f9.4,f20.3,f10.4,f12.6,f12.8)'
print,format=fmt,tsityp(tt)+' regress',a0,result(0),sigma(0),$
         result(1),sigma(1)
fmt='(a15,f9.4,f8.4,f12.3,f10.4,f12.6,f12.8)'
print,format=fmt,tsityp(tt)+' matrix ',coeff0(0),qsigma(0),coeff0(1),$
               qsigma(1),coeff0(2),qsigma(2)
; save matrix-derived coefs and uncertainites
tsicoeff=coeff0
tsisigma=qsigma
endif
;
;------------------------------------------------------------------
;  DETRENED REGRESSION
if(tt eq 1) then begin
rfit=where(ss1*ss2*r1*r2*r3*r4*r5*r6,cntfit)
;  need to add an offet so as not to hav log of negative number
xx(0,*)=mg-smmg
xx(1,*)=sb-smsb
yy=ti-smti
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
tiparam(0,tt)=a0
tiparam(1,tt)=result(0)
tiparam(2,tt)=result(1)
tiparam(3:4,tt)=sigma		; sigma
tiparam(5:6,tt)=cc		; correlation
tiparam(7,tt)=cnt		; number of days used for the regression
tiparam(8,tt)=rmul
tiparam(9,tt)=ftest
tiparam(10,tt)=chisq
;
; reconstruct the flux from the fitting parameters
rci=a0+result(0)*(mg-mgquiet)+result(1)*sb+tiquiet
; also reconsruct individual components
rcf=result(0)*(mg-mgquiet)       ; facular component
rcs=result(1)*sb  	; sunspot component
rcti(*,0,tt)=rci		; reconstructed irradiance
rcti(*,1,tt)=rcf		; reconstructed facular component
rcti(*,2,tt)=rcs		; reconstructed spot component
;
; calculate historical values use sball and mgall time series 
rci=a0+result(0)*(mgall-mgquiet)+result(1)*sball+tiquiet
; and reconsruct individual components
rcf=result(0)*(mgall-mgquiet)	; facular component
rcs=result(1)*sball 	; sunspot component
rctiall(*,0,tt)=rci		; reconstructed irradiance
rctiall(*,1,tt)=rcf		; reconstructed facular component
rctiall(*,2,tt)=rcs		; reconstructed spot component
;
; also calculate coeffs using matrix inversion - from John Emmert
; first fill in missing values to zero instead of -99 ..note - 
qqdat=yy(rfit)
ppdat=fltarr(3,cntfit)
ppdat(0,*)=1.
ppdat(1,*)=xx(0,rfit)
ppdat(2,*)=xx(1,rfit)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression - ie in the result array
qresid=qqt-ppdat##coeff0		; this should match w0 ??
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cntfit)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((4)*indgen(3)))
;
;;;;;; print results
print,'NRLTSI2 model 2C '+tsityp(tt)
print,dy(rfit(0))/365.25+2003,dy(rfit(cntfit-1))/365.25+2003,a0,result(0),result(1),rmul
fmt='(a18,f7.4,f20.4,f9.4,f12.6,f12.8)'
print,ttt
print,format=fmt,tsityp(tt)+' regress',a0,result(0),sigma(0),$
         result(1),sigma(1)
fmt='(a18,f7.4,f8.4,f12.4,f9.4,f12.6,f12.8)'
print,format=fmt,tsityp(tt)+' matrix ',coeff0(0),qsigma(0),coeff0(1),$
               qsigma(1),coeff0(2),qsigma(2)
; save matrix-derived coefs and uncertainites
tsidcoeff=coeff0
tsidsigma=qsigma
;
endif
;------------------------------------------------------------------
; ZERO MEAN UNIT VARIANCE REGRESSION
if(tt eq 2) then begin
; use zero mean, unit variance sb and mg time series - & save the values
; used to make this transformation
xxstat=fltarr(2,2)
yystat=fltarr(2)
r=where(r1)
res=moment(mg(r),/double,sdev=sdev)
xx(0,*)=(mg-res(0))/sdev
xxstat(0,0)=res(0)
xxstat(0,1)=sdev
r=where(r2)
res=moment(sb(r),/double,sdev=sdev)
xx(1,*)=(sb-res(0))/sdev
xxstat(1,0)=res(0)
xxstat(1,1)=sdev
r=where(r3)
res=moment(ti(r),/double,sdev=sdev)
yy=(ti-res(0))/sdev
yystat(0)=res(0)
yystat(1)=sdev
rfit=where(ss1*ss2*r1*r2*r3,cntfit)
;
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
;
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
tiparam(0,tt)=a0
tiparam(1,tt)=result(0)
tiparam(2,tt)=result(1)
tiparam(3:4,tt)=sigma		; sigma
tiparam(5:6,tt)=cc		; correlation
tiparam(7,tt)=cnt		; number of days used for the regression
tiparam(8,tt)=rmul
tiparam(9,tt)=ftest
tiparam(10,tt)=chisq
;
; reconstruct the flux from the fitting parameters
rci=(a0+result(0)*xx(0,*)+result(1)*xx(1,*))*yystat(1)+yystat(0)
; also reconsruct individual components
rcf=result(0)*xx(0,*)*yystat(1)+yystat(0)        ; facular component
rcs=result(1)*xx(1,*)*yystat(1)       ; sunspot component
rcti(*,0,tt)=rci		; reconstructed irradiance
rcti(*,1,tt)=rcf-tiquiet+a0		; reconstructed facular component
rcti(*,2,tt)=rcs		; reconstructed spot component
;
; also calculate historical values use sball and mgall time series 
rci=(a0+result(0)*(mgall-xxstat(0,0))/xxstat(0,1)+$
         result(1)*(sball-xxstat(1,0))/xxstat(1,1))*yystat(1)+yystat(0)
; and reconsruct individual components
rcf=result(0)*(mgall-xxstat(0,0))+xxstat(0,0) ; facular component
rcs=result(1)*(sball-xxstat(1,0))+xxstat(1,0)   ; sunspot component
rctiall(*,0,tt)=rci		; reconstructed irradiance
rctiall(*,1,tt)=rcf		; reconstructed facular component
rctiall(*,2,tt)=rcs		; reconstructed spot component
; save arrays of stats
tixxstat=xxstat
tiyystat=yystat
;
;;;;;; print results
print,'NRLTSI2 model 2C '+tsityp(tt)
print,dy(rfit(0))/365.25+2003,dy(rfit(cntfit-1))/365.25+2003,a0,result(0),result(1),rmul
print,ttt
fmt='(a18,f7.4,f18.4,f11.4,f12.6,f12.8)'
print,format=fmt,tsityp(tt)+' regress',a0,result(0),sigma(0),$
         result(1),sigma(1)
endif
;
; end of cycling through three differnet types of regression
endfor
;----------------------------------------------------------------------------
goto,cont100
; use this for testing...and future model development
; but using 3 components doesnt work seem to imrpove the model
;----------------------------------------------------------------------------
; THREE COMPONENT MULTIPLE REGRESSION ANALYSIS of SORCE TSI observations
print,'    '
;
; calculate the TSI model in three different ways with two sunspot terms:
;  1 - using direct time series
;  2 - using residual from mean values (as used for SSI model)
;
ss1=dy ge daystart
ss2=dy le daystop
;
xx=fltarr(3,ndy)
; arrays for holding the parameters to reconstruct the fractional changes
tiparam3=fltarr(14,2)		; 14 parameters for two different models
; 0 = a0 fitted
; 1 = result(0) - fitted coef for mg term
; 2 = result(1) - fitted coef for sb term
; 3 = result(1) - fitted coef for alog10(sb) term
; etc
; reconstructed time series - irradiance plus facular and sunspot components -
; for three different models
rcti3=fltarr(ndy,3,2)
rcti3all=fltarr(ndyall,3,2)
;
print,'SORCE TI 3C model: '
; use actual data for the regression
r1=mg gt 0
r2=sb gt 0		; exclude zero values
r3=ti gt 0
r4=smmg gt 0
r5=smsb gt 0
r6=smti gt 0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for tt=0,1 do begin
;------------------------------------------------------------------
;  DIRECT REGRESSION - inlcluding matric inversion, for comparison
if(tt eq 0) then begin
xx(0,*)=mg-mgquiet
xx(1,*)=sb
xx(2,*)=alog10(sb)
yy=ti-tiquiet
rfit=where(ss1*ss2*r1*r2*r3,cntfit)
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
tiparam3(0,tt)=a0
tiparam3(1,tt)=result(0)
tiparam3(2,tt)=result(1)
tiparam3(3,tt)=result(2)
tiparam3(4:6,tt)=sigma		; sigma
tiparam3(7:9,tt)=cc		; correlation
tiparam3(10,tt)=cnt		; number of days used for the regression
tiparam3(11,tt)=rmul
tiparam3(12,tt)=ftest
tiparam3(13,tt)=chisq
;
; reconstruct the flux from the fitting parameters
rci=a0+result(0)*xx(0,*)+result(1)*xx(1,*)+$
     result(2)*xx(2,*)+tiquiet
; also reconstruct individual components
rcf=result(0)*xx(0,*)+a0       ; facular component
rcs=result(1)*xx(1,*)+result(2)*xx(2,*)       ; sunspot component
rcti3(*,0,tt)=rci		; reconstructed irradiance
rcti3(*,1,tt)=rcf		; reconstructed facular component
rcti3(*,2,tt)=rcs		; reconstructed spot component
;
; calculate historical values use sball and mgall time series 
rci=a0+result(0)*(mgall-mgquiet)+result(1)*sball+$
          result(2)*alog10(sball)+tiquiet
; and reconsruct individual components
rcf=result(0)*mgall+a0	; facular component
rcs=result(1)*sball+result(2)*alog10(sball)	; sunspot component
rcti3all(*,0,tt)=rci		; reconstructed irradiance
rcti3all(*,1,tt)=rcf		; reconstructed facular component
rcti3all(*,2,tt)=rcs		; reconstructed spot component
;
endif
;
;------------------------------------------------------------------
;  DETRENED REGRESSION
if(tt eq 1) then begin
rfit=where(ss1*ss2*r1*r2*r3*r4*r5*r6,cntfit)
;  need to add an offet so as not to hav log of negative number
xx(0,*)=mg-smmg
xx(1,*)=sb-smsb
xx(2,*)=alog10(sb-smsb+1000)
yy=ti-smti
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
tiparam3(0,tt)=a0
tiparam3(1,tt)=result(0)
tiparam3(2,tt)=result(1)
tiparam3(3,tt)=result(2)
tiparam3(4:6,tt)=sigma		; sigma
tiparam3(7:9,tt)=cc		; correlation
tiparam3(10,tt)=cnt		; number of days used for the regression
tiparam3(11,tt)=rmul
tiparam3(12,tt)=ftest
tiparam3(13,tt)=chisq
;
; reconstruct the flux from the fitting parameters
rci=a0+result(0)*(mg-mgquiet)+result(1)*sb+$
                        result(2)*alog10(sb+1000.)+tiquiet
; also reconsruct individual components
rcf=result(0)*(mg-mgquiet)       ; facular component
rcs=result(1)*sb+result(2)*alog10(sb+1000.)	; sunspot component
rcti3(*,0,tt)=rci		; reconstructed irradiance
rcti3(*,1,tt)=rcf		; reconstructed facular component
rcti3(*,2,tt)=rcs		; reconstructed spot component
;
; calculate historical values use sball and mgall time series 
rci=a0+result(0)*(mgall-mgquiet)+result(1)*sball+$
              result(2)*alog10(sball+1000.)+tiquiet
; and reconsruct individual components
rcf=result(0)*(mgall-mgquiet)	; facular component
rcs=result(1)*sball+result(2)*alog10(sball+1000.)	; sunspot component
rcti3all(*,0,tt)=rci		; reconstructed irradiance
rcti3all(*,1,tt)=rcf		; reconstructed facular component
rcti3all(*,2,tt)=rcs		; reconstructed spot component
endif
;
; print results:
print,'NRLTSI2 model 3C '+tsityp(tt)
print,dy(rfit(0))/365.25+2003,dy(rfit(cntfit-1))/365.25+2003,a0,result(0),$
           result(1),result(2),rmul
;
; also calculate coeffs using matrix inversion - from John Emmert
; first fill in missing values to zero instead of -99 ..note - 
qqdat=yy(rfit)
ppdat=fltarr(4,cntfit)
ppdat(0,*)=1.
ppdat(1,*)=xx(0,rfit)
ppdat(2,*)=xx(1,rfit)
ppdat(3,*)=xx(2,rfit)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression - ie in the result array
qresid=qqt-ppdat##coeff0		; this should match w0 ??
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cntfit)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((4)*indgen(3)))
; fmt='(i3,a11,2f9.2,f9.4,a15,f9.4)'
tit='                   const         Mg-coef      sigma      SB-coef      sigma'
tit=tit+' log(SB)-coef     sigma  '
print,tit
print,tsityp(tt)+' regress',a0,result(0),sigma(0),result(1),sigma(1),$
          result(2),sigma(2)
print,tsityp(tt)+' matrix ',coeff0(0),coeff0(1),qsigma(1),coeff0(2),qsigma(2),$
                                  coeff0(3),qsigma(3)
; save matrix-derived coefs and uncertainites
tsidcoeffm=coeff0
tsidsigmam=qsigma
;
endfor
;
goto,cont100
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
calccala:
;
; TWO COMPONENT MULTIPLE REGRESSION ANALYSIS of Sac Pk CaK & LASP Lyalpha 
; for checking the UV scaling used in the model 
; use the entire time series - beasue daa are noisy and some days are missing
; calculate the CaK model in two different ways to achieve the scaling:
;  1 - using direct time series
;  2 - using residual from mean values (as used for SSI model)
;
daystart=julday(1,1,1985)-julday(1,1,1978)+1
daystop=julday(12,31,2011)-julday(1,1,1978)+1
;  otherwise..select a sub interval
ss1=dyall ge daystart
ss2=dyall le daystop
;
xx=fltarr(2,ndyall)
; arrays for holding the parameters to reconstruct the fractional changes
caparam=fltarr(11,2)
laparam=fltarr(11,2)		; 11 parameters for two different models, each
; 0 = a0 fitted
; 1 = result(0) - fitted coef for mg term
; 2 = result(1) - fitted coef for sb term
; etc
; reconstructed time series - flux plus facular and sunspot components -
; for three differnet models
rccaall=fltarr(ndyall,3,2)
rclaall=fltarr(ndyall,3,2)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print,'------------------------------------------------      '
print,'SacPk CaK model: ',dyall(rfit(0))/365.25+1978,dyall(rfit(cnt-1))/365.25+1978
for tt=0,1 do begin
; use actual data for the regression
r1=mgall gt 0
r2=sball ge 0
r3=caall gt 0
r4=smmgall gt 0
r5=smsball gt 0
r6=smcaall gt 0
;
;------------------------------------------------------------------
;  DIRECT REGRESSION - including matric inversion, for comparison
if(tt eq 0) then begin
xx(0,*)=mgall-mgquiet
xx(1,*)=sball
yy=caall-caquiet
rfit=where(ss1*ss2*r1*r2*r3,cntfit)
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
caparam(0,tt)=a0
caparam(1,tt)=result(0)
caparam(2,tt)=result(1)
caparam(3:4,tt)=sigma		; sigma
caparam(5:6,tt)=cc		; correlation
caparam(7,tt)=cnt		; number of days used for the regression
caparam(8,tt)=rmul
caparam(9,tt)=ftest
caparam(10,tt)=chisq
;
; reconstruct the CaK flux from the fitting parameters
rci=a0+result(0)*xx(0,*)+result(1)*xx(1,*)+caquiet
; also reconstruct individual components
rcf=result(0)*xx(0,*)+a0       ; facular component
rcs=result(1)*xx(1,*)      ; sunspot component
rccaall(*,0,tt)=rci		; reconstructed irradiance
rccaall(*,1,tt)=rcf		; reconstructed facular component
rccaall(*,2,tt)=rcs		; reconstructed spot component
;
; also calculate coeffs using matrix inversion - from John Emmert
; first fill in missing values to zero instead of -99 ..note - 
qqdat=yy(rfit)
ppdat=fltarr(3,cntfit)
ppdat(0,*)=1.
ppdat(1,*)=xx(0,rfit)
ppdat(2,*)=xx(1,rfit)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression - ie in the result array
qresid=qqt-ppdat##coeff0		; this should match w0 ??
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cntfit)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((4)*indgen(3)))
; fmt='(i3,a11,2f9.2,f9.4,a15,f9.4)'
tit='                         const    Mg-coef    sigma    SB-coef     sigma'
tit=tit+'      correl'
print,tit
fmt='(A20,3F10.5,2E12.4,F9.4)'
print,format=fmt,'Direct CaK regress',a0,result(0),sigma(0),result(1),sigma(1),rmul
print,format=fmt,'Direct Cak matrix ',coeff0(0),coeff0(1),qsigma(1),coeff0(2),$
                 qsigma(2),rmul
; save matrix-derived coefs and uncertainites
cakcoeff=coeff0
caksigma=qsigma
endif
;
;------------------------------------------------------------------
;  DETRENED REGRESSION
if(tt eq 1) then begin
rfit=where(ss1*ss2*r1*r2*r3*r4*r5*r6,cntfit)
;  need to add an offet so as not to hav log of negative number
xx(0,*)=mgall-smmgall
xx(1,*)=sball-smsball
yy=caall-smcaall
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
caparam(0,tt)=a0
caparam(1,tt)=result(0)
caparam(2,tt)=result(1)
caparam(3:4,tt)=sigma		; sigma
caparam(5:6,tt)=cc		; correlation
caparam(7,tt)=cnt		; number of days used for the regression
caparam(8,tt)=rmul
caparam(9,tt)=ftest
caparam(10,tt)=chisq
;
; calculate recostruction usins sball and mgall time series 
rci=a0+result(0)*(mgall-mgquiet)+result(1)*sball+caquiet
; and reconsruct individual components
rcf=result(0)*(mgall-mgquiet)	; facular component
rcs=result(1)*sball 	; sunspot component
rccaall(*,0,tt)=rci		; reconstructed irradiance
rccaall(*,1,tt)=rcf		; reconstructed facular component
rccaall(*,2,tt)=rcs		; reconstructed spot component
;
; also calculate coeffs using matrix inversion - from John Emmert
; first fill in missing values to zero instead of -99 ..note - 
qqdat=yy(rfit)
ppdat=fltarr(3,cntfit)
ppdat(0,*)=1.
ppdat(1,*)=xx(0,rfit)
ppdat(2,*)=xx(1,rfit)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression - ie in the result array
qresid=qqt-ppdat##coeff0		; this should match w0 ??
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cntfit)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((4)*indgen(3)))
; fmt='(i3,a11,2f9.2,f9.4,a15,f9.4)'
tit='                         const    Mg-coef    sigma    SB-coef     sigma'
tit=tit+'      correl'
print,tit
fmt='(A20,3F10.5,2E12.4,F9.4)'
print,format=fmt,'Detrend CaK regress',a0,result(0),sigma(0),result(1),sigma(1),rmul
print,format=fmt,'Detrend Cak matrix ',coeff0(0),coeff0(1),qsigma(1),coeff0(2),$
                 qsigma(2),rmul
; save matrix-derived coefs and uncertainites
cakdcoeff=coeff0
cakdsigma=qsigma
endif
;
endfor
;
; repeat using Lyalpha
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print,'------------------------------------------------      '
print,'Lyman Alpha model: ',dyall(rfit(0))/365.25+1978,dyall(rfit(cnt-1))/365.25+1978
for tt=0,1 do begin
; use actual data for the regression
r1=mgall gt 0
r2=sball ge 0
r3=laall gt 0
r4=smmgall gt 0
r5=smsball gt 0
r6=smlaall gt 0
;
;------------------------------------------------------------------
;  DIRECT REGRESSION - inlcluding matric inversion, for comparison
if(tt eq 0) then begin
xx(0,*)=mgall-mgquiet
xx(1,*)=sball
yy=laall-laquiet
rfit=where(ss1*ss2*r1*r2*r3,cntfit)
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
laparam(0,tt)=a0
laparam(1,tt)=result(0)
laparam(2,tt)=result(1)
laparam(3:4,tt)=sigma		; sigma
laparam(5:6,tt)=cc		; correlation
laparam(7,tt)=cnt		; number of days used for the regression
laparam(8,tt)=rmul
laparam(9,tt)=ftest
laparam(10,tt)=chisq
;
; reconstruct the Lya flux from the fitting parameters
rci=a0+result(0)*xx(0,*)+result(1)*xx(1,*)+laquiet
; also reconstruct individual components
rcf=result(0)*xx(0,*)+a0       ; facular component
rcs=result(1)*xx(1,*)      ; sunspot component
rclaall(*,0,tt)=rci		; reconstructed irradiance
rclaall(*,1,tt)=rcf		; reconstructed facular component
rclaall(*,2,tt)=rcs		; reconstructed spot component
;
; also calculate coeffs using matrix inversion - from John Emmert
; first fill in missing values to zero instead of -99 ..note - 
qqdat=yy(rfit)
ppdat=fltarr(3,cntfit)
ppdat(0,*)=1.
ppdat(1,*)=xx(0,rfit)
ppdat(2,*)=xx(1,rfit)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression - ie in the result array
qresid=qqt-ppdat##coeff0		; this should match w0 ??
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cntfit)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((4)*indgen(3)))
; fmt='(i3,a11,2f9.2,f9.4,a15,f9.4)'
print,tit
print,format=fmt,'Direct Lya regress',a0,result(0),sigma(0),result(1),sigma(1),rmul
print,format=fmt,'Direct Lya matrix ',coeff0(0),coeff0(1),qsigma(1),coeff0(2),qsigma(2),rmul
endif
;
;------------------------------------------------------------------
;  DETRENED REGRESSION
if(tt eq 1) then begin
rfit=where(ss1*ss2*r1*r2*r3*r4*r5*r6,cntfit)
;  need to add an offet so as not to hav log of negative number
xx(0,*)=mgall-smmgall
xx(1,*)=sball-smsball
yy=laall-smlaall
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
laparam(0,tt)=a0
laparam(1,tt)=result(0)
laparam(2,tt)=result(1)
laparam(3:4,tt)=sigma		; sigma
laparam(5:6,tt)=cc		; correlation
laparam(7,tt)=cnt		; number of days used for the regression
laparam(8,tt)=rmul
laparam(9,tt)=ftest
laparam(10,tt)=chisq
;
; calculate recostruction usins sball and mgall time series 
rci=a0+result(0)*(mgall-mgquiet)+result(1)*sball+laquiet
; and reconsruct individual components
rcf=result(0)*(mgall-mgquiet)	; facular component
rcs=result(1)*sball 	; sunspot component
rclaall(*,0,tt)=rci		; reconstructed irradiance
rclaall(*,1,tt)=rcf		; reconstructed facular component
rclaall(*,2,tt)=rcs		; reconstructed spot component
print,format=fmt,'Detrend Lya regress',a0,result(0),sigma(0),result(1),sigma(1),rmul
endif
;
endfor
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calcquietspec:
; note: integral must be tquiet which is 1360.448 W/m^2
; calculate the basic quiet sun reference spectrum on grid from 
;
; 115.5 to 99999.5 nm - use units of W per m^2 per nm 
wlstart=115.5
wlend=99999.5			; this is the full wavelength range of the model	
ngridq=wlend-wlstart+1
wlgridq=findgen(ngridq)+wlstart
quiet=dblarr(ngridq)
;
; for a preliminary value use the quiet sun irradiance from NRLSSI
quiet(84:*)=specdat(1,*)/1000.
quiet0=quiet
;
; bin the WHI spectrum into the 1 nm bins of wlgrid
wspec1=fltarr(ngridq)
for n=0,2284 do begin
r1=wspec(0,*) ge wlgridq(n)-0.5
r2=wspec(0,*) lt wlgridq(n)+0.5
r=where(r1*R2,cnt)
if(cnt gt 0) then wspec1(n)=total(wspec(3,r))/cnt
endfor
;
; fill in the short wl quiet spectrum with wspec1 - up to 309.5 nm
quiet(0:194)=wspec1(0:194)
; at longer wavelengths the WHI spectrum has poorer resolution than SOLSPEC
; from 310.5 to 330.5 scale the nrlssi spectrum down to match WHI
quiet(195:219)=quiet0(195:219)*0.95
; from 670.5 to 689.5 scale the nrlssi spectrum down to match WHI
quiet(555:574)=quiet0(555:574)*0.99
; from 690.5 to 775.5 scale the nrlssi spectrum down to match WHI
quiet(575:660)=quiet0(575:660)*0.98
; from 690.5 to 775.5 scale the nrlssi spectrum down to match WHI
quiet(575:660)=quiet0(575:660)*0.985
; from 792.5 to 979.5
quiet(677:865)=quiet0(677:865)*0.98
; from 1160.5 to 1275.5
quiet(1045:1160)=quiet0(1045:1160)*0.99
; from 1303.5 to 1955.5
quiet(1188:1840)=quiet0(1188:1840)*1.01315
; from 1956.5 to 2400.5
quiet(1841:2285)=quiet0(1841:2285)*1.0141
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calcsimssi:
;
; TWO COMPONENT MULTIPLE REGRESSION ANALYSIS of SORCE SSI observations
; multiple regression of each 1 nm time sereis
; with the sb and mg indices -using detrended time series
; daily time series are detrened by ratioing to smoothed time series
;
; use fractional changes for the regression
; or use direct residuals from the running mean smoothed values
selfrac=1
; Read,'Use fractional changes (=0) or absolute residuals (=1)  ',selfrac
;; make an array of quiet sun for si, i.e., on the wv grid - extract the
; first part of the wlgridq and quiet arrays
siquiet=quiet(0:nwv-1)
;
; select the time interval to calculate the SSI model
; for full time interval use...
daystart=julday(1,1,2003)-julday(1,1,2003)+1
daystop=julday(12,31,endyear)-julday(1,1,2003)+1
;  otherwise..select a sub interval
; daystart=julday(4,1,2004)-julday(1,1,2003)+1
; daystop=julday(12,31,2009)-julday(1,1,2003)+1
ss1=dy ge daystart
ss2=dy le daystop
;
xx=fltarr(2,ndy)
; arrays for holding the parameters to reconstruct the changes
siparam=fltarr(nwv,14)
; 0 =average flux
; 1 = average mg (faculae)
; 2 = average sb (spots)
; 3 = a0 fitted
; 4 = result(0) - fitted coef for mg
; 5 = result(1) - fitted coef for sb
; etc
;
; reconstructed time series - flux plus facular and sunspot components
rcsi=fltarr(nwv,ndy,3)
rcsiall=fltarr(nwv,ndyall,3)
sicoeff=fltarr(nwv,3)
sisigma=fltarr(nwv,3)
;
r1=mg gt 0
r2=smmg gt 0
r3=sb ge 0
r4=smsb ge 0
r=where(r1*r2*r3*r4)		; for checking time series
;
rdd=where(ss1*ss2,cnt)
; cycle through all 1 nm bins of SORCE SSI datasets
sdlimu=3
sdliml=5
print,'NRLSSI2 SORCE model:',dy(rdd(0))/365.25+2003,dy(rdd(cnt-1))/365.25+2003
tt=' wavelength        const     Mg-coef    sigma     SB-coef      sigma'
tt=tt+'      rmul'
print,tt
;;;; cycle through wavelengths
for n=0,nwv-12 do begin
; for n=1000,1000 do begin
yy1=si(n,*)
yy2=smsi(n,*)
; NOTE: this may not eliminate all spikes etc so may need to revisit this
r5=yy1 gt 0
r6=yy2 gt 0
rr=where(r5*r6,cnt)
; edit out spikes - first time for big spikes
result=moment(yy1(rr)-yy2(rr),sdev=sdev)
r7=yy1-yy2-result(0) lt sdev*sdlimu
r8=yy1-yy2-result(0) gt -sdev*sdliml
rr=where(r5*r6*r7*r8,cnt)
; edit out spikes - repeat for smaller spikes
result=moment(yy1(rr)-yy2(rr),sdev=sdev)
r9=yy1-yy2-result(0) lt sdev*sdlimu
r10=yy1-yy2-result(0) gt -sdev*sdliml
rr=where(r5*r6*r7*r8*r9*r10,cnt)
; edit out spikes - repeat for smaller spikes
result=moment(yy1(rr)-yy2(rr),sdev=sdev)
r11=yy1-yy2-result(0) lt sdev*sdlimu
r12=yy1-yy2-result(0) gt -sdev*sdliml
;
rfit=where(r1*r2*r3*r4*r5*r6*r7*r8*r9*r10*r11*r12*ss1*ss2,cntfit)
;
ffav=total(yy1(rfit))/cnt
mgav=total(mg(rfit))/cnt
sbav=total(sb(rfit))/cnt
if(selfrac eq 0) then begin
yy=(yy1-yy2)/ffav
xx(0,*)=(mg-smmg)/mgav
xx(1,*)=(sb-smsb)/sbav
endif
if(selfrac eq 1) then begin
yy=(yy1-yy2)
xx(0,*)=(mg-smmg)
xx(1,*)=(sb-smsb)
endif
;
result=regress(xx(*,rfit),yy(rfit),yfit=yfit,const=a0,sigma=sigma,/double,$
               ftest=ftest,correlation=cc,mcorrelation=rmul,chisq=chisq)
;
; save the model parameters: average flux, mg and sb,
; a0, result(1) and result(2)
siparam(n,0)=ffav
siparam(n,1)=mgav
siparam(n,2)=sbav
siparam(n,3)=a0
siparam(n,4)=result(0)
siparam(n,5)=result(1)
siparam(n,6:7)=sigma		; sigma
siparam(n,8:9)=cc		; correlation
siparam(n,10)=cntfit		; number of days used for the regression
siparam(n,11)=rmul
siparam(n,12)=ftest
siparam(n,13)=chisq
;
; reconstruct the flux from the fitting parameters
; but using the regular sb and mg time series, not the detrended ones
if(selfrac eq 0) then begin
rci=a0+result(0)*(mg-mgav)/mgav+result(1)*(sb-sbav)/sbav
; also reconsruct individual components
rcf=result(0)*(mg-mgav)/mgav+a0        ; facular component
rcs=result(1)*(sb-sbav)/sbav        ; sunspot component
rcsi(n,*,0)=rci*ffav+ffav		; reconstructed irradiance
rcsi(n,*,1)=rcf*ffav		; reconstructed facular component
rcsi(n,*,2)=rcs*ffav		; reconstructed spot component
; reset missing values
r=where(mg lt 0)
rcsi(n,r,0:2)=-99.
r=where(sb lt 0)
rcsi(n,r,0:2)=-99.
endif
;----------------------------------------------------------------------------
if(selfrac eq 1) then begin
rci=a0+result(0)*(mg-mgquiet)+result(1)*sb
; 
rci=a0+result(0)*(mg-mgquiet)+result(1)*sb
; also reconsruct individual components
rcf=result(0)*(mg-mgquiet)        ; facular component
rcs=result(1)*sb        ; sunspot component
rcsi(n,*,0)=rci+ffav	; reconstructed irradiance
rcsi(n,*,1)=rcf		; reconstructed facular component
rcsi(n,*,2)=rcs		; reconstructed spot component
; reset missing values
r=where(mg lt 0)
rcsi(n,r,0:2)=-99.
r=where(sb lt 0)
rcsi(n,r,0:2)=-99.
endif
;
; also calculate coeffs using matrix inversion - from John Emmert
; first fill in missing values to zero instead of -99 ..note - 
qqdat=yy(rfit)
ppdat=fltarr(3,cntfit)
ppdat(0,*)=1.
ppdat(1,*)=xx(0,rfit)
ppdat(2,*)=xx(1,rfit)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression - ie in the result array
qresid=qqt-ppdat##coeff0		; this should match w0 ??
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cntfit)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((4)*indgen(3)))
;
;;;;;; print results here 
fmt='(f7.2,a8,2f11.7,f11.7,2e12.4,f8.4)'
print,format=fmt,wv(n),' regress',a0,result(0),sigma(0),$
         result(1),sigma(1),rmul
fmt='(f7.2,a8,2f11.7,f11.7,2e12.4)'
print,format=fmt,wv(n),' matrix ',coeff0(0),coeff0(1),$
               qsigma(1),coeff0(2),qsigma(2)
; save matrix-derived coefs and uncertainites
sicoeff(n,*)=coeff0
sisigma(n,*)=qsigma
;
endfor
;
if(simver eq 20) then begin
siparam20=siparam
rcsi20=rcsi
sicoeff20=sicoeff
sisigma20=sisigma
endif
if(simver eq 21) then begin
siparam21=siparam
rcsi21=rcsi
sicoeff21=sicoeff
sisigma21=sisigma
endif
;---------------------------------
; smooth the reconstructions for comparison with detrended observations
; smooth each of the 1 nm gridded daily mean time series in rcsi array
smrcsi=fltarr(nwv,ndy)
; cycle through all wavelengths on the 1 nm grid
for j=0,nwv-12 do begin
xx=rcsi(j,*,0)
r=where(xx gt 0)
; check for outliers
result=moment(xx(r),sdev=sdev)
r=where(abs(xx-result(0)) gt sdev*3.,cnt)
if(cnt gt 0) then xx(r)=-99
; repeat for smaller spikes
r=where(xx gt 0)
result=moment(xx(r),sdev=sdev)
r=where(abs(xx-result(0)) gt sdev*3.,cnt)
if(cnt gt 0) then xx(r)=-99
; repeat again for smaller spikes
r=where(xx gt 0)
result=moment(xx(r),sdev=sdev)
r=where(abs(xx-result(0)) gt sdev*3.,cnt)
if(cnt gt 0) then xx(r)=-99
;
box_smooth,xx,sm,smxx1
box_smooth,smxx1,sm,smxx2
smrcsi(j,*)=smxx2
endfor
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calcnrlssi2:
;
; this proceeds to calculate NRLSSI2 using whatever the SIM model used
; in terms of dataset, mg index, method etc
; uncertaintites are also estimated 
;
; select wavelengths to print - for uncertainty table
prntwl=[120.5,250.5,500.5,1000.5]
quietunc=[0.1,0.05,0.05,0.05]		; add an assumed unertianty 
;      quiet sun at these wavelengths
prntday=303
nprnt=n_elements(prntwl)
;
;-------------------------------------------------------------------------
; at this point have modeled the SORCE SIM data on a 1 nm grid, but at the 
; SIM resolution. which is worse than 1 nm - 
; so convert the SIM fitting parameters into
; equiivalent sunspot and facular contrasts and then apply these to the
; reference spectrum to develop new NRLSSI2 model
;
;; determine the best array of scaling coefficients on the 
; entire 1 nm wlgrid arrays for both Mg and Sb then apply these to calculate
; the delta irradiance changes
;
; develop the model by adding the facular and sunspot changes to the quiet sun
; on the wlgrid - use the coefficients for the models that uses absolute residuals 
;
siconst0=fltarr(ngridq)	; this is the constant term from the regression..
;  it is nominally zero
siconst0(0:2280)=siparam(0:2280,3)
faccfd=fltarr(ngridq)		; fac coeff from detrended time series
faccf=fltarr(ngridq)		; fac coeff adjusted for detrending to cycle
; insert the SORCE model coefs
; note: wlgridq(175)=290.5 nm
faccfd(0:1482)=siparam(0:1482,4)
faccf(0:175)=siparam(0:175,4)*caparam(1,0)/caparam(1,1)
faccf(176:1482)=siparam(176:1482,4)*tiparam(1,0)/tiparam(1,1)
; insert Yvonne's model at longer wavelengths - 
; first need to grid this onto 1 nm grid
yv9fac=interpol(yv9(2,*)/yv9(1,*)-1,yv9(0,*),wlgridq)
; the relevant quantity is multiplied by the quiet sun to give actual energy units
faccfd(1483:*)=yv9fac(1483:*)*quiet(1483:*)
faccf(1483:*)=yv9fac(1483:*)*quiet(1483:*)
print,'adjust faccf for IR wavelengths'
; to scale up this part of the facular spetrum to better match SORCE...use...
; different scalings - may be  different for differnt SIM versions 
faccfd(1483:*)=yv9fac(1483:*)*quiet(1483:*)*2.
faccf(1483:*)=yv9fac(1483:*)*quiet(1483:*)*2.
;
spotcfd=fltarr(ngridq)
spotcf=fltarr(ngridq)
; insert the SORCE model coefs
spotcfd(0:1483)=siparam(0:1483,5)
spotcf(0:175)=siparam(0:175,5)
spotcf(176:1483)=siparam(176:1483,5)*tiparam(2,0)/tiparam(2,1)
; spotcf(176:1483)=siparam(176:1483,5)
; insert Yvonne's model at longer wavelengths - 
; first need to grid this onto 1 nm grid
yv9spot=interpol(yv9(3,*)/yv9(1,*)-1,yv9(0,*),wlgridq)
; the relevant quantity is mulptlied by the quiet sun to give 
; actual energy units
spotcfd(1484:*)=yv9spot(1484:*)*quiet(1484:*)/1.e6
spotcf(1484:*)=yv9spot(1484:*)*quiet(1484:*)/1.e6
;  but there seems to be need for another scaling here...
;  when using area-dependent contrasts
if(adc eq 1) then begin
spotcfd(1484:*)=yv9spot(1484:*)*quiet(1484:*)*4.0/1.e6
spotcf(1484:*)=yv9spot(1484:*)*quiet(1484:*)*4.0/1.e6
endif
;
; put the sigmas from the regression of the SIM observations onto the
; full 1 nm grid
rcsisigma=fltarr(ngridq,3)
rcsisigma(0:nwv-1,0)=sisigma(*,0)		; constant
rcsisigma(0:nwv-1,1)=sisigma(*,1)		; mg
rcsisigma(0:nwv-1,2)=sisigma(*,2)		; sb
;
; adjust wavelength uncertainties from 1000 to 2300 to be greater than 
; direct statistical uncerantites
; note wqv and sisigma arrays equal the shorter wavelength part of the
; wlgridq and rcsisigma arrays
r1=wv ge 1000
r2=wv le 2300
for kk=0,2 do begin
r=where(r1*R2,cnt)
aa=[wv(r(0)),wv(r(cnt-1))]
bb=[sisigma(r(0),kk),sisigma(r(0),kk)*2.5]
cf=poly_fit(aa,bb,1)
rcsisigma(r,kk)=poly(wv(r),cf)
; fill in longer wavelength uncertnaties
rr=where(wlgridq ge 2300)
rcsisigma(rr,kk)=sisigma(r(0),kk)*2.5
endfor
;
nrl2=0.
nrl2unc=0.
nrl2=fltarr(ngridq,ndy)	
nrl2unc=fltarr(ngridq,ndy)
nrl2tot=fltarr(ndy)
factot=fltarr(ndy)
spottot=fltarr(ndy)
;
; set up time-independent components of the uncertainty	
faccfunc=(rcsisigma(*,1)/faccfd)		; NOTE: this is relative uncertainty
; add additional uncertainty due to scaling the detrend coefs
faccfunc(0:175)=sqrt(faccfunc(0:175)^2.+(caksigma(1)/cakcoeff(1))^2.+$
                                (cakdsigma(1)/cakdcoeff(1))^2.)
faccfunc(176:2234)=sqrt(faccfunc(176:2234)^2.+(tsisigma(1)/tsicoeff(1))^2.+$
                                (tsidsigma(1)/tsidcoeff(1))^2.)
spotcfunc=abs((rcsisigma(*,2)/spotcfd))
; add additional uncertainty due to scaling the detrend coefs
; NOTE: this is relative uncertainty
; add additional uncertainty due to scaling the detrend coefs
spotcfunc(176:2234)=sqrt(spotcfunc(176:2234)^2.+(tsisigma(2)/tsicoeff(2))^2.+$
                                (tsidsigma(2)/tsidcoeff(2))^2.)
;
; now calculate time-dependent fluxes and uncertainties	
;--------- Intiital calculations from SIM regression
for n=0,ndy-1 do begin
if((mg(n) gt 0) and (sb(n) ge 0)) then begin
dfac=(mg(n)-mgquiet)*faccf
dspot=sb(n)*spotcf
flx=quiet+siconst0+dfac+dspot
nrl2(*,n)=flx
facunc1=abs(faccf*(mg(n)-mgquiet))*sqrt(faccfunc^2.+mgu^2.)
spotunc1=abs(spotcf*sb(n))*sqrt(spotcfunc^2.+sbu^2.)
nrl2unc(*,n)=rcsisigma(*,0)+facunc1+spotunc1	; these are absolute values
factot(n)=total(dfac)
spottot(n)=total(dspot)
nrl2tot(n)=total(flx)
;
; print selected values on specified day
if(dy(n) eq prntday) then begin
print,'------------------------------------------------------------'
print,'Initial NRLSSI calculation from SIM regression:'
tt='   DAY   WAVEL     FLX            QUIET        '
tt=tt+'FACCF      DFAC         SPOTCF       DSPOT        CONST'
print,tt
fmt1='(f6.0,f8.1,7e13.3)'
fmt2='(a6,e21.3,6e13.3)'
for jj=0,nprnt-1 do begin
r=where(wlgridq eq prntwl(jj))
print,format=fmt1,dy(n),prntwl(jj),nrl2(r,n),quiet(r),$
               faccf(r),dfac(r),spotcf(r),dspot(r),siconst0(r)
print,format=fmt2,'UNC',nrl2unc(r,n),quietunc(jj)*quiet(r),$
        abs(faccfunc(r)*faccf*(mg(n)-mgquiet)),facunc1(r),$
        abs(spotcfunc(r)*spotcf*sb(n)),spotunc1(r),rcsisigma(r,0)
endfor
endif
;
endif
endfor
;
nrl2tot0=nrl2tot
factot0=factot
spottot0=spottot
;
;----------------------------------------------------------------------------
; the initial sunspot darkening uand facular brighteing nderestimate the tsi 
; change found for TSI - 
; determine the calibration of this underestimation in initial model resduals 
resid=rcti(*,2,0)-spottot0
r1=spottot0 le 0
r2=rcti(*,2,0) le 0
r3=sb ge 0
r=where(r1*r2*r3,cnt)
spotcfe=poly_fit(sb(r),resid(r),1)
; estimate uncertainties in this regression with matrix
qqdat=resid(r)
ppdat=fltarr(2,cnt)
ppdat(0,*)=1.
ppdat(1,*)=sb(r)
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression 
qresid=qqt-ppdat##coeff0		
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cnt)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((3)*indgen(2)))
coeff0spot=coeff0
qsigmaspot=qsigma
print,'------------------------------------------------------------'
print,'Total resids vs sb:'
print,'coef0 ',spotcfe(0),coeff0spot(0),qsigmaspot(0)
print,'coef1 ',spotcfe(1),coeff0spot(1),qsigmaspot(1)
;
; determine relationship betWeen the residuals and Mg 
; calibrate this in new model resduals 
resid=rcti(*,1,0)-factot0
r1=factot0 gt 0
r2=rcti(*,1,0) gt 0
r3=mg gt 0
r=where(r1*r2*r3)
cf=poly_fit(mg(r)-mgquiet,resid(r),1)
; remove spikes
result=moment(resid(r)-poly(mg(r)-mgquiet,cf),sdev=sdev)
q1=abs(resid-poly(mg-mgquiet,cf)) lt sdev*2.
r=where(r1*r2*r3*q1,cnt)
faccfe=poly_fit(mg(r)-mgquiet,resid(r),1)
; estimate uncertainties in this regression
qqdat=resid(r)
ppdat=fltarr(2,cnt)
ppdat(0,*)=1.
ppdat(1,*)=mg(r)-mgquiet
qqt=transpose(qqdat)
coeff0=invert(transpose(ppdat)##ppdat)##transpose(ppdat)##qqt	
; these are the initial estimates of the coefs that should
;           match those from linear regression 
qresid=qqt-ppdat##coeff0		
qsigma0=sqrt(total(qresid*qresid)/(cntfit-2))
lag=findgen(10)
acfqresid=a_correlate(qresid,lag)
vinv=arcov_invert(acfqresid(1),cnt)
; this is the inverse V matrix - use this to estimate better uncertanties
qcoeff=qsigma0^2.*invert(transpose(ppdat)##vinv##ppdat)
; the diagonal terms are the new sigmas
qsigma=sqrt(qcoeff((3)*indgen(2)))
coeff0fac=coeff0
qsigmafac=qsigma
print,'------------------------------------------------------------'
print,'Total resids vs mg-mgquiet:'
print,'coef0 ',faccfe(0),coeff0fac(0),qsigmafac(0)
print,'coef1 ',faccfe(1),coeff0fac(1),qsigmafac(1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; recalculate nrl2 model adding in these adjustments... it must be applied
; across all wavelengths i.e., this is the bolometric adjustment - 
; converted to equivalent tsb
nrl2=0
nrl2=fltarr(ngridq,ndy)			
for n=0,ndy-1 do begin
if((mg(n) gt 0) and (sb(n) ge 0)) then begin
; facular component
deltati=poly(mg(n)-mgquiet,faccfe)
deltamg=deltati/tiparam(1,0)
deltamgunc=deltamg*sqrt((qsigmafac(1)/coeff0fac(1))^2.+$
       (tsisigma(2)/tsicoeff(2))^2.+mgu^2.)
dfac=(mg(n)-mgquiet+deltamg)*faccf
; spot component
deltati=poly(sb(n),spotcfe)
; transform this into an adjustment to sb
deltasb=deltati/tiparam(2,0)
deltasbunc=deltasb*sqrt((qsigmaspot(1)/coeff0spot(1))^2.+$
       (tsisigma(2)/tsicoeff(2))^2.+sbu^2.)
dspot=(sb(n)+deltasb)*spotcf
flx=quiet+siconst0+dfac+dspot
nrl2(*,n)=flx
; add in additional uncertainty
facunc1=abs(faccf*(mg(n)-mgquiet))*sqrt(faccfunc^2.+mgu^2.)  ; same as previous		
uu2=faccfunc^2.+(qsigmafac(1)/coeff0fac(1))^2.+$
       (tsisigma(1)/tsicoeff(1))^2.+mgu^2.
facunc2=abs(faccf*deltamg)*sqrt(uu2)  
spotunc1=abs(spotcf*sb(n))*sqrt(spotcfunc^2.+sbu^2.)		; same as previous
uu2=spotcfunc^2.+(qsigmaspot(1)/coeff0spot(1))^2.+$
       (tsisigma(2)/tsicoeff(2))^2.+sbu^2.
spotunc2=abs(spotcf*deltasb)*sqrt(uu2)   
; note tiparam(0:2,0) is same array as tsicoeff (with tsisigma from matrix)
nrl2unc(*,n)=nrl2unc(*,n)+facunc2+spotunc2	; these are absolute values
;
; print selected values on specified day
if(dy(n) eq prntday) then begin
print,'------------------------------------------------------------'
print,'Second NRLSSI calculation from SIM regression plus spot plus fac regressions:'
print,'Fac signal = ',mg(n)-mgquiet,(mg(n)-mgquiet)*mgu,'  Spot signal = ',$
        sb(n),sb(n)*sbu
print,'Fac increm = ',deltamg,deltamgunc,'  Spot increm = ',deltasb,deltasbunc
print,tt
fmt='(f6.0,f8.1,6e13.3)'
for jj=0,nprnt-1 do begin
r=where(wlgridq eq prntwl(jj))
print,format=fmt1,dy(n),prntwl(jj),nrl2(r,n),$
           quiet(r),faccf(r),dfac(r),spotcf(r),dspot(r),siconst0(r)
print,format=fmt2,'UNC',nrl2unc(r,n),quietunc(jj)*quiet(r),$
            abs(faccfunc(r)*faccf*(mg(n)-mgquiet)),facunc1(r)+facunc2(r),$
            abs(spotcfunc(r)*spotcf*sb(n)),$
            spotunc1(r)+spotunc2(r),rcsisigma(r,0)
endfor
endif
;
factot(n)=total(dfac)
spottot(n)=total(dspot)
nrl2tot(n)=total(flx)
endif
endfor
;
;-----------  save arrays -------------
if(simver eq 20) then begin
nrl220=nrl2
faccf20=faccf
spotcf20=spotcf
endif
if(simver eq 21) then begin
nrl221=nrl2
faccf21=faccf
spotcf21=spotcf
endif
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calcrefspec:
;
; use NRLSSI2 parameters to calculated reference spectrum on 1 nm grid
; NOTE - default is to use SIM V21 
;
reftit=['Sept 2001','May 2004','July 2008']
refday1=[1,1,1]
refmon1=[9,5,7]
refyr1=[2001,2004,2008]
refday2=[31,31,31]
refmon2=[9,5,7]
refyr2=[2001,2004,2008]
nref=n_elements(refday1)
nrl2refspec=dblarr(ngridq,nref,2)
totti=dblarr(nref)
;
for n=0,nref-1 do begin
dy1=julday(refmon1,refday1,refyr1)-julday(1,1,1978)+1
dy2=julday(refmon2,refday2,refyr2)-julday(1,1,1978)+1
r1=dyall ge dy1(n)
r2=dyall lt dy2(n)
r3=mgall gt 0
r4=sball ge 0
r=where(r1*r2*r3*r4,cnt)
mgref=double(total(mgall(r))/cnt)
sbref=double(total(sball(r))/cnt)
;
; facular component
deltati=poly(mgref-mgquiet,double(faccfe))
deltamg=deltati/tiparam(1,0)
dfac=(mgref-mgquiet+deltamg)*double(faccf)
; spot component
deltati=poly(sbref,double(spotcfe))
; transform this into an adjustment to sb
deltasb=deltati/tiparam(2,0)
dspot=(sbref+deltasb)*double(spotcf)
nrl2refspec(*,n,0)=double(quiet+dfac+dspot)
totti(n)=total(rctiall(r,0,0))/cnt
;
; now detemrine the reference spectrum from the 1nm spectra = where available
mgref1=0
sbref1=0
if(refyr1(n) ge 2003) then begin
dy1=julday(refmon1,refday1,refyr1)-julday(1,1,2003)+1
dy2=julday(refmon2,refday2,refyr2)-julday(1,1,2003)+1
r1=dy ge dy1(n)
r2=dy lt dy2(n)
r3=mg gt 0
r4=sb ge 0
r=where(r1*r2*r3*r4,cnt)
mgref1=total(mg(r))/cnt
sbref1=total(sb(r))/cnt
xx=nrl2(*,r)
;
for j=0,ngridq-1 do begin
yy=double(xx(j,*))
nrl2refspec(j,n,1)=double(total(yy)/cnt)
endfor
endif
;
print,'Reference Spectrum:',reftit(n),refday1(n),refmon1(n),refyr1(n),refday2(n),$
          refmon2(n),refyr2(n)
print,'Mgref = ',mgref,'  sbref = ',sbref,'  Mgref1  ',mgref1,'   sbref1   ',sbref1
print,'Total = ',double(total(nrl2refspec(*,n,0))),'    rctiall = ',totti(n)
print,'Total = ',double(total(nrl2refspec(*,n,1)))
;
endfor
;
; write filw of reference spectra
fnref='NRLSSI2_Reference_Spectra.txt'
close,1
openw,1,fnref
printf,1,systime(0)
printf,1,'NRLSSI2 Reference Spectra in W per m^2 per nm (Version 28Jan15)'
printf,1,'  WAV (nm)     ',reftit(0),'     ',reftit(1),'        ',reftit(2),$
             '        QUIET'
printf,1,'   TSI ',totti(0),totti(1),totti(2),total(quiet)
fmt='(f8.1,4e16.4)'
for n=0,ngridq-1 do begin
printf,1,format=fmt,wlgridq(n),nrl2refspec(n,0,0),nrl2refspec(n,1,0),$
       nrl2refspec(n,2,0),quiet(n)
endfor
close,1
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
binit:
; calculate broad spectral bands for making time series comparisons
; Make bins of fluxes on common time grid
; cycle thru and make wavelength bands on common grid
;
bnwv1=[121,140,200,220,250,300,400,600,700,1000,1550,1650,1750,2000,540]
bnwv2=[122,180,210,240,300,400,600,700,1000,1300,1650,1750,2000,2300,640]
nbn=n_elements(bnwv1)
bnsi=fltarr(nbn,ndy)-99.	   ; SORCE ssi since 2003 -wkshop Sept 14
bnnrl2=fltarr(nbn,ndy)-99.	   ; NRLSSI2 since 2003
bnrcsi=fltarr(nbn,ndy)-99.	   ; model from SORCE since 2003
bnnrl=fltarr(nbn,ndy)-99.	   ; NRLSSI - original model since 2003
;
; SORCE si - gridded  - since 2003
for nn=0,ndy-1 do begin
yy=si(*,nn)
for n=0,nbn-1 do begin
r1=wv ge bnwv1(n)
r2=wv lt bnwv2(n)
r3=yy gt 0
r=where(r1*r2*r3,cnt)
if(cnt gt fix((bnwv2(n)-bnwv1(n))*.5)) then $
           bnsi(n,nn)=total(yy(r))/cnt*(bnwv2(n)-bnwv1(n))
endfor
endfor
;
; reconstructed SI - SIM model
for nn=0,ndy-1 do begin
yy=rcsi(*,nn,0)
for n=0,nbn-1 do begin
r1=wv ge bnwv1(n)
r2=wv lt bnwv2(n)
r3=yy gt 0
r=where(r1*r2*r3,cnt)
if(cnt gt fix((bnwv2(n)-bnwv1(n))*.5)) then $
           bnrcsi(n,nn)=total(yy(r))/cnt*(bnwv2(n)-bnwv1(n))
endfor
endfor
;
; NRLSSI
; cycle thru all days since 2003
for nn=0,ndy-1 do begin
yy=nrlsi(*,nn)
; cycle through wavelength bins
for n=0,nbn-1 do begin
r1=nrlwv-nrlwvb/2. ge bnwv1(n)
r2=nrlwv+nrlwvb/2. le bnwv2(n)
r3=yy gt 0
r=where(r1*r2*r3,cnt)
bnnrl(n,nn)=total(yy(r)*nrlwvb(r))/1000.
endfor
; end of cycling thru bands
; end of cycling thru days
endfor
;
; NRL2
; cycle thru all days since 2003
for nn=0,ndy-1 do begin
yy=nrl2(*,nn)
; cycle through wavelength bins
for n=0,nbn-1 do begin
r1=wlgridq ge bnwv1(n)
r2=wlgridq le bnwv2(n)
r3=yy gt 0
r=where(r1*r2*r3,cnt)
bnnrl2(n,nn)=total(yy(r))/cnt*(bnwv2(n)-bnwv1(n))
endfor
; end of cycling thru bands
; end of cycling thru days
endfor
if(simver eq 20) then begin
bnnrl220=bnnrl2
bnsi20=bnsi
endif
if(simver eq 21) then begin
bnnrl221=bnnrl2
bnsi21=bnsi
endif
;
goto,cont100
; edit out spurious points from the time series
temp0=bnsi1(n,*)
r1=temp0 gt 0
r=where(r1)
result=moment(xx(r),sdev=sdev)
r2=abs(xx-result(0)) lt sdev*5
r=where(r1*r2)
si1(n,r)=xx(r)
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
avit:
; calculate averages of NRLSSI and NRLSSI2 spectra for common period
; at cycle max and cycle min
; cycle max
;
; cycle 24 max....
yrmin1=2008.905
yrmin2=2008.982
yrmax1=2013.03
yrmax2=2013.06
; cycle 23 max....
; yrmin1=2008.905
; yrmin2=2008.982
; yrmax1=2004.09
; yrmax2=2004.16
;
tempmax=0
tempmin=0
nrlav=0
; NRLSSI model ...wavelength array is nrlwv
nrlav=fltarr(nband,2)
; cycle max
r1=dy/365.25+2003 ge yrmax1
r2=dy/365.25+2003 lt yrmax2
rmax=where(r1*r2)
; cycle min
r1=dy/365.25+2003 ge yrmin1
r2=dy/365.25+2003 lt yrmin2
rmin=where(r1*r2)
tempmax=nrlsi(*,rmax)/1000.
tempmin=nrlsi(*,rmin)/1000.
for n=0,nband-1 do begin
xx=tempmax(n,*)
q=where(xx gt 0,cnt)
nrlav(n,0)=total(xx(q))/cnt
xx=tempmin(n,*)
q=where(xx gt 0,cnt)
nrlav(n,1)=total(xx(q))/cnt
endfor
;
tempmax=0
tempmin=0
rcsiav=0
; SIM model - directly from SORCE ...wavelength array is
rcsiav=fltarr(nwv,2)
; cycle max
r1=dy/365.25+2003 ge yrmax1
r2=dy/365.25+2003 lt yrmax2
rmax=where(r1*r2)
r1=dy/365.25+2003 ge yrmin1
r2=dy/365.25+2003 lt yrmin2
rmin=where(r1*r2)
tempmax=rcsi(*,rmax,0)
tempmin=rcsi(*,rmin,0)
for n=0,nwv-1 do begin
xx=tempmax(n,*)
q=where(xx gt 0,cnt)
rcsiav(n,0)=total(xx(q))/cnt
xx=tempmin(n,*)
q=where(xx gt 0,cnt)
rcsiav(n,1)=total(xx(q))/cnt
endfor
if(simver eq 20) then rcsiav20=rcsiav
if(simver eq 21) then rcsiav21=rcsiav
;
tempmax=0
tempmin=0
nrl2av=0
; NRL2 model - derived from SORCE ...wavelength array is
nrl2av=fltarr(ngridq,2)
; cycle max
r1=dy/365.25+2003 ge yrmax1
r2=dy/365.25+2003 lt yrmax2
rmax=where(r1*r2)
r1=dy/365.25+2003 ge yrmin1
r2=dy/365.25+2003 lt yrmin2
rmin=where(r1*r2)
tempmax=nrl2(*,rmax)
tempmin=nrl2(*,rmin)
for n=0,ngridq-1 do begin
xx=tempmax(n,*)
q=where(xx gt 0,cnt)
nrl2av(n,0)=total(xx(q))/cnt
xx=tempmin(n,*)
q=where(xx gt 0,cnt)
nrl2av(n,1)=total(xx(q))/cnt
endfor
if(simver eq 20) then nrl2av20=nrl2av
if(simver eq 21) then nrl2av21=nrl2av
;
tempmax=0
tempmin=0
siav=0
; SORCE ssi1 datase (Sept 2014 workshop)   ...wavelength array is
siav=fltarr(nwv,2)
; cycle max
r1=dy/365.25+2003 ge yrmax1
r2=dy/365.25+2003 lt yrmax2
rmax=where(r1*r2)
r1=dy/365.25+2003 ge yrmin1
r2=dy/365.25+2003 lt yrmin2
rmin=where(r1*r2)
tempmax=si(*,rmax)
tempmin=si(*,rmin)
for n=0,nwv-1 do begin
xx=tempmax(n,*)
q=where(xx gt 0.01,cnt)
siav(n,0)=total(xx(q))/cnt
xx=tempmin(n,*)
q=where(xx gt 0.01,cnt)
siav(n,1)=total(xx(q))/cnt
endfor
if(simver eq 20) then siav20=siav
if(simver eq 21) then siav21=siav
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pgit:
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
writeit:
; write files of various results
;
; 540-640 nm band for Hillary Dennision
close,1
fn='~/models/NRLSSI2/SSI_540_640nm_'+modver+'.txt'
openw,1,fn
printf,1,systime(0)
printf,1,'SSI 540-640 nm from SIM obsevations and NRLSSI model'
printf,1,'Irradiance in W m-2 for the band, Day number after 1 Jan 2003'
printf,1,'  DAY NUMBER     SORCE SIM       NRLSSI'
for n=0,ndy-1 do begin
printf,1,dy(n),bnsi1(14,n),bnnrl2(14,n+9131)
endfor
close,1
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
saveparams:
; make a save file that has all the paremters needed to construct
;  the NRLSSI2 and NRLTSI2 models - use terminolgy as in the C-ATBD
if(adc eq 0) then $
   fn='~/models/NRLSSI2/trans_2015/NRL2_model_parameters_AIndC_'+$
         string(simver,'(I2)')+'_'+modver+'.sav'
if(adc eq 1) then $
   fn='~/models/NRLSSI2/trans_2015/NRL2_model_parameters_ADepC_'+$
         string(simver,'(I2)')+'_'+modver+'.sav'
;
tquiet=double(tiquiet)
iquiet=double(quiet)
lambda=double(wlgridq)
acoef=double(tiparam(0,0))
bfaccoef=double(tiparam(1,0))
bspotcoef=double(tiparam(2,0))
ccoef=double(siconst0)
dfaccoef=double(faccf)
efaccoef=double(faccfe)
dspotcoef=double(spotcf)
espotcoef=double(spotcfe)
ccoefunc=rcsisigma(*,0)
;
save,filename=fn,simver,tquiet,acoef,bfaccoef,bspotcoef,$
               lambda,iquiet,ccoef,dfaccoef,dspotcoef,efaccoef,espotcoef,$
               mgquiet,selmg,selfrac,seltim,ccoefunc,$
               mgu,sbu,tsisigma,faccfunc,spotcfunc,$
               coeff0spot,qsigmaspot,coeff0fac,qsigmafac
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
printuncert:
; set day
d1=30
m1=10
y1=2003
arr=julday(m1,d1,y1)-julday(1,1,2003)
fmt='(a12,2i3,i5,a12,i5)'
print,format=fmt,'Day is ',d1,m1,y1,' Array element is ',arr
fmt='(a20,2f8.3,f12.3)'
print,format=fmt,'Fac and Spot inputs are ',mg(arr),mg(arr)-mgquiet,sb(arr)
print,'TSI------------------------------'
fmt='(5f8.3)'
print,format=fmt,rcti(arr,0,0,0),rcti(arr,0,0)-tiquiet,tiparam(0,0),$
                 rcti(arr,1,0),rcti(arr,2,0)
fmt='(2f8.2,3f8.3)'
print,format=fmt,rctiunc(arr,0)+0.5,rctiunc(arr,0),rctiunc(arr,1),$
              rctiunc(arr,2),rctiunc(arr,3)
print,'SSI-----------------------------------'
for n=0,nprnt-1 do begin
r=where(wlgridq eq prntwl(n))
fmt='(f8.2,f14.8,f12.8)'
print,format=fmt,wlgridq(r),quiet(r),nrl2(r,arr)
fmt='(f22.2,f12.8)'
print,format=fmt,quietunc(n),nrl2unc(r,arr)
endfor
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
saveit:
; make a save file that of data arrays
if(adc eq 0) then $
     fn='~/models/NRLSSI2/trans_2015/calc_NRLSSI2_dataarrays_AIndC_'+$
        simver+'_'+modver+'.sav'
if(adc eq 1) then $
     fn='~/models/NRLSSI2/trans_2015/calc_NRLSSI2_dataarrays_ADepC_'+$
         simver+'_'+modver+'.sav'
save,filename=fn
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plotit:
plt=1
;
print,'Different Solar Reference Spectra Comparisons  ....0'
; print,'All SSI spectra  ...1'
print,'Time series of SORCE and models at 4 seleted wavelengths ....2'
print,'Correlation coeffs vs wavelength ...3'
print,'Spot and faculae scalings vs wavelength vs others...4'
print,'Spot and faculae scalings vs wavelength V20 vs V21...5'
print,'SORCE residual time series at selected wavelenths V20 & V21  ....6'
print,'NRLTSI2, NRLTSI, TIM ...100'
print,'NRLTSI2 or NRLTSI differences from TIM - residuals...101'
print,'CaK & Lyman alpha reconstructions   ....102'
print,'Spectrum    ...200'
print,'Spectrum changes in NRLSSI and NRLSSI2 - indiviudal days  ...201'
print,'Spectrum changes in NRLSSI and NRLSSI2 - cycle max-min averages...202'
print,'NRLTSI2 from TIM vs total NRLSSI2 from SSI   ...203'
print,'NRLTSI2 spot & fac from TIM vs spot & fac totals in NRLSSI2   ...204'
print,'    '
print,'Map of ratios - SORCE SSI spectra and new model ...11'
print,'Time series of ratios - SORCE spectra and new model ...12'
print,'Band-averaged time series solar cycle - SORCE, NRLSSI, NRLSSI2 ...20'
print,'Band-averaged time series solar rotation - SORCE, NRLSSI, NRLSSI2 ...21'
print,'Band-averaged time series detrended - SORCE, NRLSSI, NRLSSI2 ...22'
print,'Spectral energy change on different days ...23'
print,'    '
print,'Figures for NOAA C-ATBD '
print,'Sunspot darking and facular brightening time series (Fig 2, Fig 3)...400'
print,'Reference (quiet) spectrum (Fig 4)...401'
print,'Reference (quiet) spectrum - sub wavelenght bands...4011'
print,'Sunspot darkening and facular brightening spectral coefs (Fig 5)...402'
print,'NRLTSI2, NRLTSI, TIM time series (Fig 13)...100'
print,'NRLTSI2 or NRLTSI differences from TIM - residuals (Fig 15)...101'
print,'Solar cycle spectrum change - % and energy (Fig 17)....403'
print,'Histograms of TIM-quiet and TIM-smooth ( & SacPk CaK) ...404'
print,'NRLTSI2 time series with fac and sunspot components (Fig 6) ....405'
print,'NRLSSI2 time series in bands (Fig 16)....406'
print,'NRLTSI2 and NRLSSI2 total, facular and spsot residuals (Fig 8)...407'
print,'NRLTSI2 and uncertainties time series (Fig 11)..... 408'
print,'Regression (detrended) model coeff uncertaintities vs wavelength ...409'
print,'NRL model coeff uncertaintities vs wavelength (Fig 12)....410'
print,'NRLSSI2 and uncertainties time series (Fig 13)..... 411'
print,'NRLSSI2 reference spectra ....412'
;
print,'Binned 540-640 nm time series for Hillary ....300'
read,'Enter plot number',plt
;
if(plt eq 0) then goto,plot0
if(plt eq 1) then goto,plot1
if(plt eq 2) then goto,plot2
if(plt eq 3) then goto,plot3
if(plt eq 4) then goto,plot4
if(plt eq 5) then goto,plot5
if(plt eq 6) then goto,plot6
if(plt eq 100) then goto,plot100
if(plt eq 101) then goto,plot101
if(plt eq 102) then goto,plot102
if(plt eq 200) then goto,plot200
if(plt eq 201) then goto,plot201
if(plt eq 202) then goto,plot202
if(plt eq 203) then goto,plot203
if(plt eq 204) then goto,plot204
;
if(plt eq 11) then goto,plot11
if(plt eq 12) then goto,plot12
if(plt eq 20) then goto,plot20
if(plt eq 21) then goto,plot21
if(plt eq 22) then goto,plot22
if(plt eq 23) then goto,plot23
;
if(plt eq 300) then goto,plot300
if(plt eq 400) then goto,plot400
if(plt eq 401) then goto,plot401
if(plt eq 4011) then goto,plot401
if(plt eq 402) then goto,plot402
if(plt eq 403) then goto,plot403
if(plt eq 404) then goto,plot404
if(plt eq 405) then goto,plot405
if(plt eq 406) then goto,plot406
if(plt eq 407) then goto,plot407
if(plt eq 408) then goto,plot408
if(plt eq 409) then goto,plot409
if(plt eq 410) then goto,plot410
if(plt eq 411) then goto,plot411
if(plt eq 412) then goto,plot412
;
;-----------------------------------------------------------------------
plot0:
;
; compare three different reference spectra: SOLSPEC, SORCE & WRC
!x.range=[100,100000]
; !x.range=[120,320]
!y.range=[1.e-8,100]
!p.region=[0,.5,1,1]
plot_oo,wlgridq,quiet,/nodata,xticklen=0.05,$
   xtitle='Wavelength (nm)',ytitle='Irradiance (W M!u-2!n nm!u-1!n)'
; Kurucz
; oplot,1./sun2(0,*)*1.e7,sun2(1,*)*sun2(0,*)*sun2(0,*)/1000.,color=19
; NRLSSI
oplot,specdat(0,*),specdat(1,*)/1000.,color=1
; WRC
oplot,wrc(0,*),wrc(1,*)*10,color=14
; SORCE WHI
oplot,wspec(0,*),wspec(3,*),color=16
; SOLSPEC
oplot,sspec(0,*),sspec(1,*)/1000.,color=13
;
!p.region=[0,0,1,0.5]
!p.noerase=1
!y.range=[.85,1.15]
plot_oo,wlgridq,quiet/quiet0,/nodata,title='Ratio to Quiet'
oplot,wlgridq,quiet/quiet0,color=1
oplot,wlgridq,quiet/wspec1,color=16
;
goto,cont100
;-----------------------------------------------------------------------
plot1:
cs=1.2
!p.charsize=cs
;
!p.region=[0,.3,1,1]
!p.noerase=0
!x.range=[110,1580]
!y.range=[0,2200]
xt='Wavelength (nm)'
yt='Irradiance (mW m!u-2!n nm!u-1!n)'
xtn=replicate('  ',10)
plot,wv,si(*,1000),/nodata,ytitle=yt,$
         xticklen=0.05,xtitle=xt
;
;; plot SSI spectra from datafile
for n=0,nsor-1 do begin
oplot,(ssidat(2,*)+ssidat(3,*))/2.,ssidat(6,*)*1000,color=1
endfor
;
; plot gridded SSI spectra
for n=0,ndy-1 do begin
oplot,wv,si(*,n)*1000,color=2
endfor
;
goto,cont100
;-----------------------------------------------------------------------
plot2:
cs=1.2
!p.charsize=cs
;
dt=0		; for basic time series
; dt=1		; for detrended time series
; plot 4 obs and model time series at selected individual wavelengths 
;
pltwv=[150,250,450,750]		
pltwv=[120,200,500,1000]	
;
!x.range=[2003,endyear]
; !x.range=[2004.4,2005]
; !x.range=[2005.4,2006]
!x.style=9
!y.style=9
xtn=replicate('  ',10)
!p.noerase=0
; cycle through four plots
for k=0,3 do begin
bb=pltwv(K)
if(k eq 0) then !p.region=[0.03,.68,1,.98]
if(k eq 1) then !p.region=[0.03,.45,1,.75]
if(k eq 2) then !p.region=[0.03,.23,1,.53]
if(k eq 3) then !p.region=[0.03,0,1,.3]
if(k gt 0) then !p.noerase=1
if(k eq 2) then yt='                     W m!u-2!n nm!u-2!n!c' else yt='   '
;
; set different yranges
if(dt eq 0) then begin
flxav=siparam(bb-115,0)
!y.range=[flxav*0.9,flxav*1.1]
if(bb eq 120) then !y.range=[0.0001,0.00025]
if(bb eq 150) then !y.range=[0.00007,0.00004]
if(bb eq 200) then !y.range=[0.007,0.008]
if(bb eq 250) then !y.range=[0.055,0.059]
if(bb eq 450) then !y.range=[2.061,2.073]
if(bb eq 500) then !y.range=[1.944,1.958]
if(bb eq 750) then !y.range=[1.247,1.251]
if(bb eq 1000) then !y.range=[0.735,0.74]
endif
;
if(dt eq 1) then begin
flxav=siparam(bb-115,0)
!y.range=[flxav*0.9,flxav*1.1]
if(bb eq 120) then !y.range=[0.00012,0.00021]
if(bb eq 150) then !y.range=[0.000075,0.000087]
if(bb eq 200) then !y.range=[0.0073,0.0078]
if(bb eq 250) then !y.range=[0.055,0.058]
if(bb eq 450) then !y.range=[2.064,2.072]
if(bb eq 500) then !y.range=[1.945,1.953]
if(bb eq 750) then !y.range=[1.247,1.250]
if(bb eq 1000) then !y.range=[0.737,0.738]
endif
;
xx=si(bb-115,*)
smxx=smsi(bb-115,*)
rcxx=rcsi(bb-115,*,0)
smrcxx=smrcsi(bb-115,*,0)
xtn=replicate('  ',10)
r=where(xx gt 0)
if(k lt 3) then plot,dy(r)/365.25+2003,xx(r),/nodata,ytitle=yt,$
         xticklen=0.05,xtickname=xtn
if(k eq 3) then plot,dy(r)/365.25+2003,xx(r),/nodata,ytitle=yt,$
         xticklen=0.05
if(dt eq 0) then begin
oplot,dy(r)/365.25+2003,xx(r)
oplot,dy(r)/365.25+2003,smxx(r),color=14
oplot,dy(r)/365.25+2003,rcxx(r),color=19
endif
if(dt eq 1) then begin
oplot,dy(r)/365.25+2003,xx(r)-smxx(r)+flxav
oplot,dy(r)/365.25+2003,rcxx(r)-smrcxx(r)+flxav,color=19
endif
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.98
tt=string(wv(bb-115),'(F6.1)')
xyouts,x1,y1,tt,charsize=cs
; end of cycling through 4 plots
endfor
;
goto,cont100
;-----------------------------------------------------------------------
plot3:
cs=1.3
!p.charsize=cs
;
; plot spectrallly dependent correlation coefs
!p.region=[0,.4,1,.95]
!p.noerase=0
!x.range=[100,2400]
; !x.range=[100,350]
!y.range=[-1,1]
xt='Wavelength (nm)'
yt='Correlation coefficient'
xtn=replicate('  ',10)
tt='Correlation of detrended SORCE data and model'
tt='   '
plot,wv,siparam(*,11),/nodata,ytitle=yt,$
         xticklen=0.05,xtitle=xt,title=tt
oplot,wv,siparam21(*,11),color=14,thick=th*2	
oplot,wv,siparam21(*,8),color=19,thick=th*2		; fac
oplot,wv,-siparam21(*,9),color=16,thick=th*2		; spot
; for checking....
oplot,wv,siparam20(*,11),color=1,thick=th*0.5,linestyle=2
oplot,wv,siparam20(*,8),color=1,thick=th*0.5,linestyle=2	; fac
oplot,wv,-siparam20(*,9),color=1,thick=th*0.5, linestyle=2	; spot
;
tt='model (spots & faculae)'
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.3
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.88
xyouts,x1,y1,tt,charsize=cs*1.1,color=14
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.4
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.65
xyouts,x2,y2,'spots',color=16
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.37
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.4
xyouts,x3,y3,'faculae',color=19
;
goto,cont100
;-----------------------------------------------------------------------
plot4:
;
cs=1.3
!p.charsize=cs
; use fps=1
; plot spectrallly dependent spot and facular
;
!p.noerase=0
!p.region=[0,.55,1,.95]
!x.range=[100,4000]
; !x.range=[200,500]
!y.range=[.0001,1000]
; !y.range=[0,4]
; !x.range=[700,900]
; !y.range=[0.01,4]
xt='Wavelength (nm)'
tt='Facular Contrast and Model Coefficients'
yt='  '
xtn=replicate('  ',10)
plot_oo,wv,siparam(*,4),/nodata,ytitle=yt,$
         xticklen=0.05,title=tt
if(selfrac eq 0) then oplot,wv,siparam(*,4)*3.2*1.68150,color=2,thick=th
if(selfrac eq 1) then begin
oplot,wlgridq,faccf/quiet,color=19,thick=th
oplot,wv,siparam20(*,4)/quiet,color=13,thick=th,linestyle=2
oplot,wv,siparam21(*,4)/quiet,color=13,thick=th
endif
;
; add Yvonne's model
oplot,yv9(0,*),yv9(2,*)/yv9(1,*)-1,color=1
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.15
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.025
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.0008
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.005
xyouts,x1,y1,'Unruh Model 9',color=1
xyouts,x1,y2,'NRLSSI2',color=19
xyouts,x1,y3,'SORCE - MG GOME',color=13
xyouts,x1,y4,'NRLSSI UARS',color=16
;
; add (scaled) regression coeffs from UARS SOLSTICE analysis
oplot,uvwl,uvfregressd(1,*)*3.2*1.68150,color=16
;
!p.noerase=1
!p.region=[0,0.17,1,0.57]
!y.range=[-1.2,0.5]
; !y.range=[-0.5,-0.1]
xt='Wavelength (nm)'
tt='Sunspot Contrasts and Model Coefficients'
xtn=replicate('  ',10)
plot_oi,wv,siparam(*,4),/nodata,ytitle=yt,$
         xticklen=0.05,xtitle=xt,title=tt
if(selfrac eq 0) then oplot,wv,siparam(*,5)*2500,color=2
if(selfrac eq 1) then begin
oplot,wlgridq,spotcf/quiet*1000000.,color=19,thick=th
; use this scaling when using SSB Mar14 version
;  oplot,wlgridq,spotcf/quiet*300000.,color=19,thick=th
;  oplot,wv,siparam(*,5)/quiet*300000.,color=13,thick=th
; use this scaling when using SSB Nov14 version
oplot,wlgridq,spotcf/quiet*1000000.,color=19,thick=th
oplot,wv,siparam20(*,5)/quiet*1000000.,color=13,thick=th,linestyle=2
oplot,wv,siparam21(*,5)/quiet*1000000.,color=13,thick=th			
endif			
;
; add Yvonne's model
oplot,yv9(0,*),yv9(3,*)/yv9(1,*)-1,color=1,thick=th
;
; add (scaled) regression coeffs from UARS SOLSTICE analysis
oplot,uvwl,uvfregressd(2,*)*1550.,color=16

; add Allen's values
wssa=[300.0,400.0,500.0,600.0,800.0,1000.0,1500.0,2000.0,4000.0]
; wssa is wavelength (in nm)  - from 0.3 to 4 micron
cpen=[0.640,0.680,0.720,0.760,0.810,0.860,0.890,0.910,0.940]
; cpen is penumbra contrast = penumbra/photosphere
cumb=[0.010,0.030,0.060,0.100,0.210,0.320,0.50,0.590,0.670]
; cumb is umbral contrast = umbra/photosphere
;
; umbral area weighting factor is 0.177 
; penumbral area weighting factor is 0.823
cav=cumb*0.176+cpen*0.824
oplot,wssa,cav-1,color=20,thick=th
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.81
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.72
x4=!x.range(0)+(!x.range(1)-!x.range(0))*0.13
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.35
xyouts,x1,y1,'Unruh Model 9',color=1
xyouts,x1,y2,'NRLSSI2',color=19
xyouts,x4,y4,'SORCE - Mg GOME',color=13
xyouts,x1,y3,'NRLSSI UARS',color=16
;
y5=!y.range(0)+(!y.range(1)-!y.range(0))*0.52
xyouts,x1,y5,'Allen',color=20
goto,cont100
;-----------------------------------------------------------------------
plot5:
;
cs=1.3
!p.charsize=cs
; use fps=1
; plot spectrallly dependent spot and facular SIM V20 and V21
;
!p.noerase=0
!p.region=[0,.55,1,.95]
!x.range=[100,3000]
!x.range=[500,2500]

!y.range=[.0001,100]
xt='Wavelength (nm)'
tt='Facular Model Coefficient'
yt='  '
xtn=replicate('  ',10)
plot_oo,wv,siparam(*,4),/nodata,ytitle=yt,$
         xticklen=0.05,title=tt
oplot,wv,siparam20(*,4)/quiet,color=19,thick=th
oplot,wv,siparam21(*,4)/quiet,color=14,thick=th
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.2
xyouts,x1,y1,'NRLSSI2 S20',color=19
xyouts,x1,y2,'NRLSSI2 S21',color=14
;
;;;; spots
!p.noerase=1
!p.region=[0,0.17,1,0.57]
!y.range=[-1.2,0.5]
; !y.range=[-0.5,-0.1]
xt='Wavelength (nm)'
tt='Sunspot Model Coefficient'
xtn=replicate('  ',10)
plot_oi,wv,siparam(*,4),/nodata,ytitle=yt,$
         xticklen=0.05,xtitle=xt,title=tt
oplot,wv,siparam20(*,5)/quiet*1000000.,color=19,thick=th
oplot,wv,siparam21(*,5)/quiet*1000000.,color=14,thick=th			
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.7
xyouts,x1,y1,'NRLSSI2 S20',color=19
xyouts,x1,y2,'NRLSSI2 S21',color=14
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot6:
;
; plot SORCE residual irradiance time series at selected wavelengths
;
cs=1.2
!p.charsize=cs
; plot time series at selected wavelengths
pltwl=[850.5,950.5,1050.5,1250.5] 	
;
!x.range=[2013,2013.8]
!x.style=9
!y.style=1
xtn=replicate('  ',10)
!p.noerase=0
;;; make plots
!p.noerase=0
for k=0,3 do begin
if(k eq 0) then !p.region=[0.05,.7,.98,.96]
if(k eq 1) then !p.region=[0.05,.47,.98,.73]
if(k eq 2) then !p.region=[0.05,.24,.98,.50]
if(k eq 3) then !p.region=[0.05,0.01,.98,.27]
if(k gt 0) then !p.noerase=1
;
; set yrange
; 2003
if(pltwl(k) eq 850.5) then !y.range=[-0.0025,0.001]
if(pltwl(k) eq 950.5) then !y.range=[-0.002,0.001]
if(pltwl(k) eq 1050.5) then !y.range=[-0.002,0.001]
if(pltwl(k) eq 1250.5) then !y.range=[-0.001,0.0005]
; 2004 & 2005
if(pltwl(k) eq 850.5) then !y.range=[-0.001,0.001]
if(pltwl(k) eq 950.5) then !y.range=[-0.001,0.001]
if(pltwl(k) eq 1050.5) then !y.range=[-0.001,0.0005]
if(pltwl(k) eq 1250.5) then !y.range=[-0.0005,0.0005]
; 2006
if(pltwl(k) eq 850.5) then !y.range=[-0.001,0.0008]
if(pltwl(k) eq 950.5) then !y.range=[-0.001,0.001]
if(pltwl(k) eq 1050.5) then !y.range=[-0.0004,0.0004]
if(pltwl(k) eq 1250.5) then !y.range=[-0.0004,0.0003]
; 2009
if(pltwl(k) eq 850.5) then !y.range=[-0.001,0.0008]
if(pltwl(k) eq 950.5) then !y.range=[-0.001,0.001]
if(pltwl(k) eq 1050.5) then !y.range=[-0.0002,0.00015]
if(pltwl(k) eq 1250.5) then !y.range=[-0.0002,0.0002]
; 2010
if(pltwl(k) eq 850.5) then !y.range=[-0.001,0.0008]
if(pltwl(k) eq 950.5) then !y.range=[-0.001,0.001]
if(pltwl(k) eq 1050.5) then !y.range=[-0.00025,0.0002]
if(pltwl(k) eq 1250.5) then !y.range=[-0.00025,0.00025]
; 2011
if(pltwl(k) eq 850.5) then !y.range=[-0.001,0.0008]
if(pltwl(k) eq 950.5) then !y.range=[-0.001,0.001]
if(pltwl(k) eq 1050.5) then !y.range=[-0.0003,0.0002]
if(pltwl(k) eq 1250.5) then !y.range=[-0.0003,0.00025]
; 2012
if(pltwl(k) eq 850.5) then !y.range=[-0.001,0.00085]
if(pltwl(k) eq 950.5) then !y.range=[-0.0015,0.0015]
if(pltwl(k) eq 1050.5) then !y.range=[-0.0004,0.00025]
if(pltwl(k) eq 1250.5) then !y.range=[-0.0004,0.00025]
; 2013
if(pltwl(k) eq 850.5) then !y.range=[-0.001,0.00085]
if(pltwl(k) eq 950.5) then !y.range=[-0.0015,0.002]
if(pltwl(k) eq 1050.5) then !y.range=[-0.00045,0.00055]
if(pltwl(k) eq 1250.5) then !y.range=[-0.0004,0.0005]
;
; !y.range=0
r=where(wv eq pltwl(k))
xx20a=si20(r,*)
xx20b=smsi20(r,*)
xx21a=si21(r,*)
xx21b=smsi21(r,*)
xx20=xx20a-xx20b
xx21=xx21a-xx21b
r1=xx20a gt 0
r2=xx20b gt 0
r3=xx21a gt 0
r4=xx21b gt 0
r=where(r1*r2*r3*r4)
plot,dy(r)/365.25+2003,xx20(r),/nodata,ytitle=yt,$
         xticklen=0.05,tit='Wavelength: '+string(pltwl(k),'(f7.2)')
r=where(r1*r2)
oplot,dy(r)/365.25+2003,xx20(r),color=19,thick=th,psym=-2,symsiz=.6
r=where(r3*r4)
oplot,dy(r)/365.25+2003,xx21(r),color=16,thick=th,psym=-4,symsiz=.1
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.8
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.03
xyouts,x1,y1,'SIM V20',color=19
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
xyouts,x1,y1,'SIM V21',color=16
; end of cycling through plots at different wavelengths
endfor
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot20:
;
cs=1.2
!p.charsize=cs
; make an aray of scaling to use when comparing nrlssi with nrlssi and SORCE - cycle
; these scalings determined by hand from comparing time series -
; array must match wavelengths
ymax=fltarr(nbn)
ymin=fltarr(nbn)
nrlscl=fltarr(nbn)
sim0scl=fltarr(nbn)
sim1scl=fltarr(nbn)
rcsiscl=fltarr(nbn)
; cycle through bins and determine inital scaling and max and min of plots
for n=0,nbn-1 do begin
r1=bnnrl2(n,*) gt 0
r2=bnnrl(n,*) gt 0
r=where(r1*r2)
nrlscl(n)=total(bnnrl2(n,r))/total(bnnrl(n,r))
r2=bnsi0(n,*) gt 0
r=where(r1*r2)
sim0scl(n)=total(bnnrl2(n,r))/total(bnsi0(n,r))
r2=bnsi1(n,*) gt 0
r=where(r1*r2)
sim1scl(n)=total(bnnrl2(n,r))/total(bnsi1(n,r))
r2=bnrcsi(n,*) gt 0
r=where(r1*r2)
rcsiscl(n)=total(bnnrl2(n,r))/total(bnrcsi(n,r))
if(n eq 4) then sim1scl(n)=1.03
if(n eq 5) then sim1scl(n)=1.00
; if(n eq 6) then sim1scl(n)=0.9929
; if(n eq 7) then sim1scl(n)=0.9994
; if(n eq 8) then sim1scl(n)=0.9956
if(n eq 9) then sim1scl(n)=0.9886
;
amax=max(bnnrl2(n,r))
amin=min(bnnrl2(n,r))
ymax(n)=amax+(amax-amin)*0.4
;ymin(n)=amin-(amax-amin)*1.1
;ymax(n)=amax-(amax-amin)*0
ymin(n)=amin-(amax-amin)*0.4
endfor
;
cs=1.2
!p.charsize=cs
; plot time series in selected wavelength bands - solar cycle time scales
; for 120 to 400 nm use....
bnd=[0,2,4,5]		; array elements to plot
; for 400 to 1300 nm use....
; bnd=[6,7,8,9]		; array elements to plot
; for 1500 to 2300 nm use....
; bnd=[10,11,12,13]	
;
!x.range=[2003,2014]
; !x.range=[2003.7,2003.9]
; !x.range=[2004,2008]
!x.style=9
!y.style=9
xtn=replicate('  ',10)
!p.noerase=0
;;; make plots
for k=0,3 do begin
bb=bnd(k)
if(k eq 0) then begin
!p.region=[0,.68,.98,.98]
endif
if(k eq 1) then begin
!p.noerase=1
!p.region=[0,.45,.98,.75]
endif
if(k eq 2) then begin
!p.region=[0,.23,.98,.53]
endif
if(k eq 3) then begin
!p.region=[0,0,.98,.3]
endif
;
; set yrange
!y.range=[ymin(bb),ymax(bb)]
if(bnd(k) eq 0) then !y.range=[0.0055,0.009]
if(bnd(k) eq 2) then !y.range=[0.105,0.115]
if(bnd(k) eq 4) then !y.range=[12.15,12.55]
if(bnd(k) eq 5) then !y.range=[92.7,93.8]
if(bnd(k) eq 6) then !y.range=[371.5,375]
if(bnd(K) eq 7) then !y.range=[156.7,157.7]
if(bnd(k) eq 8) then !y.range=[304.6,306.3]
if(bnd(k) eq 59) then !y.range=[165.0,165.5]
;
xx0=bnsi0(bb,*)*sim0scl(bb)	; source - V19
xx1=bnsi1(bb,*)*sim1scl(bb)	; source - V20
xx2=bnrcsi(bb,*)*rcsiscl(bb)	; ssi sorce model
xx3=bnnrl(bb,*)*nrlscl(bb)	; nrlssi - original model
xx4=bnnrl2(bb,*)		; nrlssi2 - new model
r0=xx0 gt !y.range(0)
r1=xx1 gt !y.range(0)
r2=xx2 gt !y.range(0)
r3=xx3 gt !y.range(0)
r4=xx4 gt !y.range(0)
r=where(r1)
xtn=replicate('  ',10)
if(K eq 2) then yt='              W m!u-2!n'
if(k ne 2) then yt='   '
if(k le 2) then plot,dy(r)/365.25+2003,xx1(r),/nodata,ytitle=yt,$
         xticklen=0.05,xtickname=xtn
if(k eq 3) then plot,dy(r)/365.25+2003,xx1(r),/nodata,ytitle=yt,$
         xticklen=0.05
r=where(r1,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx1(r),color=14,thick=th
r=where(r3,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx3(r),color=1,thick=th
r=where(r0,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx0(r),color=8,thick=th
r=where(r4,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx4(r),color=19,thick=th
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1
if(bnwv1(bb) lt 1000) then begin
sw1=string(bnwv1(bb),'(i3)')
endif
if(bnwv1(bb) ge 1000) then sw1=string(bnwv1(bb),'(i4)')
if(bnwv2(bb) lt 1000) then begin
sw2=string(bnwv2(bb),'(i3)')
endif
if(bnwv2(bb) ge 1000) then sw2=string(bnwv2(bb),'(i4)')
xyouts,x1,y1,sw1+' - '+sw2+' nm'
print,bb,'     ',sw1,'     ',sw2
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.33
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.37
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.39
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.43
if(bnwv1(bb) lt 400) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.8
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.7
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.6
endif
if((bnwv1(bb) ge 400) and (bnwv1(bb) lt 1500)) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.35
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.25
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.15
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.05
endif
if(bnwv1(bb) gt 1500) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.87
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.77
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.67
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.57
endif
oplot,[x1,x2],[y1,y1],color=14
xyouts,x3,y1,'SORCE V13V20'+string(sim1scl(bb),'(f6.3)'),color=14
oplot,[x1,x2],[y2,y2],color=19
xyouts,x3,y2,'NRLSSI2',color=19
oplot,[x1,x2],[y3,y3],color=1
xyouts,x3,y3,'NRLSSI !5X!3'+string(nrlscl(bb),'(f6.3)'),color=1
; oplot,[x1,x2],[y4,y4],color=13
; xyouts,x3,y4,'SORCE model'+string(sim0scl(bb),'(f6.3)'),color=13

endfor
;
goto,cont100 
;-----------------------------------------------------------------------
plot21:
;
!x.range=[2003.7,2004.2]
;
; NOTE: si0 data only starts in 2004.4
;
ymax=fltarr(nbn)
ymin=fltarr(nbn)
nrlscl=fltarr(nbn)
sim0scl=fltarr(nbn)
sim1scl=fltarr(nbn)
rcsiscl=fltarr(nbn)
; cycle through bins and determine inital scaling and max and min of plots
for n=0,nbn-1 do begin
r1=bnnrl2(n,*) gt 0
r2=bnnrl(n,*) gt 0
r3=dy/365.25+2003 ge !x.range(0)
r4=dy/365.25+2003 le !x.range(1)
r=where(r1*r2*r3*r4)
nrlscl(n)=total(bnnrl2(n,r))/total(bnnrl(n,r))
r2=bnrcsi(n,*) gt 0
r=where(r1*r2*r3*r4)
rcsiscl(n)=total(bnnrl2(n,r))/total(bnrcsi(n,r))
r2=bnsi1(n,*) gt 0
r=where(r1*r2*r3*r4)
sim1scl(n)=total(bnnrl2(n,r))/total(bnsi1(n,r))
if(selssi eq 0) then begin
if(n eq 4) then sim1scl(n)=1.0235
if(n eq 5) then sim1scl(n)=1.0025
if(n eq 6) then sim1scl(n)=0.9929
if(n eq 7) then sim1scl(n)=0.9994
if(n eq 8) then sim1scl(n)=0.9956
if(n eq 9) then sim1scl(n)=0.988
endif
if(selssi eq 1) then begin
if(n eq 4) then sim1scl(n)=1.0235
if(n eq 5) then sim1scl(n)=0.992
if(n eq 6) then sim1scl(n)=0.9927
if(n eq 7) then sim1scl(n)=1.0012
if(n eq 8) then sim1scl(n)=0.99725
if(n eq 9) then sim1scl(n)=0.9895
endif
r2=bnsi0(n,*) gt 0
r=where(r1*r2*r3*r4)
sim0scl(n)=total(bnnrl2(n,r))/total(bnsi0(n,r))
r=where(r1*r3*r4)
amax=max(bnnrl2(n,r))
amin=min(bnnrl2(n,r))
ymax(n)=amax+(amax-amin)*0.2
ymin(n)=amin-(amax-amin)*0.5
endfor
;
cs=1.2
!p.charsize=cs
; plot time series in selected wavelength bands - solar rotation time scales
; for 120 to 400 nm use....
bnd=[0,2,4,5]		; array elements to plot
; for 400 to 1300 nm use....
; bnd=[6,7,8,9]		; array elements to plot
; for 1500 to 2400 nm use....
; bnd=[10,11,12,13]		; array elements to plot
;
!x.style=9
!y.style=9
xtn=replicate('  ',10)
!p.noerase=0
for k=0,3 do begin
bb=bnd(k)
if(k eq 0) then begin
!p.region=[0,.68,.98,.98]
endif
if(k eq 1) then begin
!p.noerase=1
!p.region=[0,.45,.98,.75]
endif
if(k eq 2) then begin
!p.region=[0,.23,.98,.53]
endif
if(k eq 3) then begin
!p.region=[0,0,.98,.3]
endif
;
!y.range=[ymin(bb),ymax(bb)]
xx0=bnsi0(bb,*)		; source sim data V19
xx1=bnsi1(bb,*)		; source sim data V20
xx2=bnrcsi(bb,*)	; ssi sorce model
xx3=bnnrl(bb,*)		; nrlssi - original model
xx4=bnnrl2(bb,*)	; nrlssi2 - new model
r0=xx0*sim0scl(bb) gt !y.range(0)
r1=xx1*sim1scl(bb) gt !y.range(0)
r2=xx2*rcsiscl(bb) gt !y.range(0)
r3=xx3*nrlscl(bb) gt !y.range(0)
r4=xx4 gt !y.range(0)
r=where(r1)
xtn=replicate('  ',10)
if(K eq 2) then yt='              W m!u-2!n'
if(k ne 2) then yt='   '
if(k le 2) then plot,dy(r)/365.25+2003,xx1(r),/nodata,ytitle=yt,$
         xticklen=0.05,xtickname=xtn
if(k eq 3) then plot,dy(r)/365.25+2003,xx1(r),/nodata,ytitle=yt,$
         xticklen=0.05
r=where(r0,cnt)
; if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx0(r)*sim0scl(bb),color=16,$
;             thick=th,psym=-5,symsiz=1
r=where(r1,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx1(r)*sim1scl(bb),color=14,$
           thick=th,psym=-4,symsiz=1
r=where(r3,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx3(r)*nrlscl(bb),color=1,thick=th
r=where(r2,cnt)
; if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx2(r)*rcsiscl(bb),color=16,thick=th
r=where(r4,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx4(r),color=19,thick=th
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.2
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.95
if(bnwv1(bb) lt 1000) then begin
sw1=string(bnwv1(bb),'(i3)')
endif
if(bnwv1(bb) ge 1000) then sw1=string(bnwv1(bb),'(i4)')
if(bnwv2(bb) lt 1000) then begin
sw2=string(bnwv2(bb),'(i3)')
endif
if(bnwv2(bb) ge 1000) then sw2=string(bnwv2(bb),'(i4)')
xyouts,x1,y1,sw1+' - '+sw2+' nm'
print,bb,'     ',sw1,'     ',sw2
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.3
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.35
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.38
if(bnwv1(bb) lt 400) then begin
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.15
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.2
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.25
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.28
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.18
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.08
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.01
endif
if(bnwv1(bb) ge 400) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.33
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.23
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.13
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.03
endif
; oplot,[x1,x2],[y1,y1],color=14
xyouts,x3,y1,'SORCE V13V20 !5X!3'+string(sim1scl(bb),'(f6.3)'),color=14
; oplot,[x1,x2],[y2,y2],color=1
xyouts,x3,y2,'NRLSSI !5X!3'+string(nrlscl(bb),'(f6.3)'),color=1
; oplot,[x1,x2],[y3,y3],color=19
if(selssi eq 0) then xyouts,x3,y3,'NRLSSI2 V12V19',color=19
if(selssi eq 1) then xyouts,x3,y3,'NRLSSI2 V13V20',color=19
; oplot,[x1,x2],[y4,y4],color=16
; xyouts,x3,y4,'SORCE V12V19'+string(sim0scl(bb),'(f6.3)'),color=16
endfor
;
goto,cont100
;-----------------------------------------------------------------------
plot22:
; compare SORCE and model detrended time series
cs=1.2
!p.charsize=cs
;
; plot detrended time series in selected wavelength bands - solar cycle time scales
; for 120 to 400 nm use....
bnd=[0,2,4,5]		; array elements to plot
; for 400 to 1300 nm use....
bnd=[6,7,8,9]		; array elements to plot
; for 1500 to 2300 nm use....
; bnd=[10,11,12,13]	
bnd=[2,4,6,9]		; use for NOAA C-ATBD
;
!x.range=[2003.5,2005.5]
; !x.range=[2004,2008]
!x.style=9
!y.style=9
xtn=replicate('  ',10)
!p.noerase=0
;;; make plots
for k=0,3 do begin
bb=bnd(k)
if(k eq 0) then begin
!p.region=[0,.68,.98,.98]
endif
if(k eq 1) then begin
!p.noerase=1
!p.region=[0,.45,.98,.75]
endif
if(k eq 2) then begin
!p.region=[0,.23,.98,.53]
endif
if(k eq 3) then begin
!p.region=[0,0,.98,.3]
endif
;
; set yrange
if(bnd(k) eq 0) then !y.range=[-.001,.001]
if(bnd(k) eq 2) then !y.range=[-.003,.003]
if(bnd(k) eq 4) then !y.range=[-.07,.05]
if(bnd(k) eq 5) then !y.range=[-1,.4]
if(bnd(k) eq 6) then !y.range=[-1.6,0.4]
if(bnd(K) eq 7) then !y.range=[-.7,0.2]
if(bnd(k) eq 8) then !y.range=[-.9,0.3]
if(bnd(k) eq 9) then !y.range=[-.4,0.2]
; !y.range=[-1,1]
;
xx1=bnsi1(bb,*)		; source - V20
xx4=bnnrl2(bb,*)	; nrlssi2 - new model
; reset missing and spurious values
r1=xx1 le 0
r=where(r1)
xx1(r)=-99
r1=xx4 le 0
r=where(r1)
xx4(r)=-99
; smooth
sm=40
box_smooth,xx1,sm,smxx1
box_smooth,xx4,sm,smxx4
;
xtn=replicate('  ',10)
if(K eq 2) then yt='              W m!u-2!n'
if(k ne 2) then yt='   '
r=where((xx1 gt 0) and (smxx1 gt 0),cnt)
if(k le 2) then plot,dy(r)/365.25+2003,xx1(r)-smxx1(r),/nodata,ytitle=yt,$
         xticklen=0.05,xtickname=xtn
if(k eq 3) then plot,dy(r)/365.25+2003,xx1(r)-smxx1(r),/nodata,ytitle=yt,$
         xticklen=0.05
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx1(r)-smxx1(r),color=14,thick=th,$
           psym=-5,symsiz=0.6
r=where((xx4 gt 0) and (smxx4 gt 0),cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx4(r)-smxx4(r),color=19,thick=th
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1
if(bnwv1(bb) lt 1000) then begin
sw1=string(bnwv1(bb),'(i3)')
endif
if(bnwv1(bb) ge 1000) then sw1=string(bnwv1(bb),'(i4)')
if(bnwv2(bb) lt 1000) then begin
sw2=string(bnwv2(bb),'(i3)')
endif
if(bnwv2(bb) ge 1000) then sw2=string(bnwv2(bb),'(i4)')
xyouts,x1,y1,sw1+' - '+sw2+' nm'
print,bb,'     ',sw1,'     ',sw2
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.33
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.37
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.39
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.43
if(bnwv1(bb) lt 400) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.8
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.7
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.6
endif
if((bnwv1(bb) ge 400) and (bnwv1(bb) lt 1500)) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.35
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.25
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.15
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.05
endif
if(bnwv1(bb) gt 1500) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.87
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.77
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.67
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.57
endif
oplot,[x1,x2],[y1,y1],color=14
xyouts,x3,y1,'SORCE V13V20',color=14
oplot,[x1,x2],[y2,y2],color=19
xyouts,x3,y2,'NRLSSI2',color=19
endfor
;
goto,cont100 
;-------------------------------------------------------------------
plot100:
; compare TIM, NRLTS2, NRLTSI 
cs=1.2
!p.charsize=cs
; plot modeled and observed TSI, including total of si
; daily at max and min and smoothed over cycle
;
yt='W m!u-2!n'
!p.noerase=0
!p.region=[0,0,1,0.35]
!x.range=[2003,2014.5]
; !x.range=[2003.5,2005.5]
; !x.range=[2008,2009]
; !x.range=[2003.7,2004]
!y.range=[1356,1363]
r=where(ti gt 0)
plot,dy(r)/365.25+2003,ti(r),/nodata,ytitle=yt,$
		xticklen=0.05
oplot,dy(r)/365.25+2003,ti(r),psym=-4,symsiz=.5,color=14
r=where(rcti(*,0,0) gt 0)
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=19
r=where(wls gt 0)
; oplot,dyall(r)/365.25+1978,wls(r)+nrloff,color=1
r=where(nrlti gt 0)
; oplot,dyall(r)/365.25+1978,nrlti(r)+nrloff,color=16
r=where(nrlsialltot gt 0)
; oplot,dyall(r)/365.25+1978,nrlsialltot(r)+nrloff,color=13
;
!p.noerase=1
smp=80
!p.region=[0,0.3,1,0.65]
!x.range=[2003,2014.5]
; !x.range=[2008,2009]
; !x.range=[2003.7,2004]
!y.range=[1360.3,1361.8]
r=where(ti gt 0)
smx=smooth(dy(r)/365.25+2003,smp)
smy=smooth(ti(r),smp)
nsm=n_elements(smx)
plot,dy(r)/365.25+2003,ti(r),/nodata,ytitle=yt,$
         xticklen=0.05
oplot,smx(smp/2:nsm-smp/2),smy(smp/2:nsm-smp/2),psym=-4,symsiz=.5,$
             color=14
r=where(rcti(*,0,0) gt 0)
smx=smooth(dy(r)/365.25+2003,smp)
smy=smooth(rcti(r,0,0),smp)
nsm=n_elements(smx)
oplot,smx(smp/2:nsm-smp/2),smy(smp/2:nsm-smp/2),color=19
r=where(wls gt 0)
smx=smooth(dyall(r)/365.25+1978,smp)
smy=smooth(wls(r),smp)
nsm=n_elements(smx)
oplot,smx(smp/2:nsm-smp/2),smy(smp/2:nsm-smp/2)+nrloff,color=1
r=where(nrlti gt 0)
smx=smooth(dyall(r)/365.25+1978,smp)
smy=smooth(nrlti(r),smp)
nsm=n_elements(smx)
; oplot,smx(smp/2:nsm-smp/2),smy(smp/2:nsm-smp/2)+nrloff,color=19
r=where(nrlsialltot gt 0)
smx=smooth(dyall(r)/365.25+1978,smp)
smy=smooth(nrlsialltot(r),smp)
nsm=n_elements(smx)
; oplot,smx(smp/2:nsm-smp/2),smy(smp/2:nsm-smp/2)+nrloff,color=13
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.3
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.34
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.38
x4=!x.range(0)+(!x.range(1)-!x.range(0))*0.42
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.85
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.75
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.65
oplot,[x1,x2,x3],[y1,y1,y1],psym=-4,symsiz=1,color=14
xyouts,x4,y1*1.000002,'TIM observations',color=14
oplot,[x1,x2,x3],[y2,y2,y2],color=19,thick=th*2
xyouts,x4,y2*1.000002,'NRLTSI2 model',color=19
oplot,[x1,x2,x3],[y3,y3,y3],color=1
xyouts,x4,y3*1.000002,'NRLTSI model '+string(nrloff,'(f5.2)'),color=1
;
!p.region=[0,0.6,0.53,0.93]
!x.range=[2003.7,2004]
!y.range=[1356.3,1362.5]
r=where(ti gt 0)
plot,dy(r)/365.25+2003,ti(r),/nodata,ytitle=yt,$
               xticks=3,xticklen=0.05,yticklen=0.05
oplot,dy(r)/365.25+2003,ti(r),psym=-4,symsiz=.5,color=14
r=where(rcti(*,0,0) gt 0)
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=19
r=where(wls gt 0)
oplot,dyall(r)/365.25+1978,wls(r)+nrloff,color=1
r=where(nrlti gt 0)
; oplot,dyall(r)/365.25+1978,nrlti(r)+nrloff,color=19
r=where(nrlsialltot gt 0)
; oplot,dyall(r)/365.25+1978,nrlsialltot(r)-4.85,color=13
;
!p.region=[0.47,0.6,1,0.93]
!x.range=[2008.7,2009]
!y.range=[1360.0,1361.09]
r=where(ti gt 0)
plot,dy(r)/365.25+2003,ti(r),/nodata,$
	xticks=3,xticklen=0.05,yticklen=0.05
oplot,dy(r)/365.25+2003,ti(r),psym=-4,symsiz=.5,color=14
r=where(rcti(*,0,0) gt 0)
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=19
r=where(wls gt 0)
oplot,dyall(r)/365.25+1978,wls(r)+nrloff,color=1
r=where(nrlti gt 0)
; oplot,dyall(r)/365.25+1978,nrlti(r)+nrloff,color=19
r=where(nrlsialltot gt 0)
; oplot,dyall(r)/365.25+1978,nrlsialltot(r)-4.85,color=13
;
goto,cont100
;-----------------------------------------------------------------------
plot101:
; plot TIM/NRLTSI2 and determine slope of ratios
cs=1.1
!p.charsize=cs
;
; plot NRLTSI and NRLTSI2 differences in two separate plots
for selnrl=1,2 do begin
yt='Difference (W m!u-2!n)'
if(selnrl eq 1) then begin
!p.noerase=0
!p.region=[0,0.08,1,0.4]
rc=wls(9131:*)+nrloff
tt='TIM-NRLTSI'
endif
if(selnrl eq 2) then begin
!p.noerase=1
!p.region=[0,0.38,1,0.7]
rc=rcti(*,0,0)
tt='TIM-NRLTSI2-2C'
tt='TIM-NRLTSI2'
endif
if(selnrl eq 3) then begin
!p.noerase=1
!p.region=[0,0.68,1,1]
rc=rcti3(*,0,0)
tt='TIM-NRLTSI2-3C'
endif
!x.range=[2003,endyear+0.5]
!x.style=9
!y.style=9
; !x.range=[2008,2009]
; !x.range=[2003.7,2004]
!y.range=[-1.0,1.0]
;
r1=ti gt 0
r2=rc gt 0
r3=abs(ti-rc) lt 1
r=where(r1*r2*r3)
plot,dy(r)/365.25+2003,ti(r)-rc(r),/nodata,ytitle=yt,$
		xticklen=0.05
oplot,dy(r)/365.25+2003,ti(r)-rc(r),psym=-4,symsiz=.5,color=13
sm=365
smx=smooth(dy(r),sm)/365.25+2003
smy=smooth(ti(r)-rc(r),sm)
nsm=n_elements(smx)
oplot,smx(sm/2:nsm-sm/2),smy(sm/2:nsm-sm/2-1),color=20
cf=poly_fit(dy(r),ti(r)-rc(r),1)
result=moment(ti(r)-rc(r),sdev=sdev)
print,cf
oplot,dy(r),poly(dy(r),cf),color=8,thick=th*2
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.2
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.05
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.2
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.09
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.95
xyouts,x1,y1,'slope = '+string(cf(1)/1360.8*1.e6*365.25,'(f5.2)')+' ppm per year'
xyouts,x1,y2,'sdev = '+string(sdev,'(f6.3)')+' W m!u-2!n'
xyouts,x2,y3,tt,charsize=cs*1.5
endfor
;
goto,cont100
;
;-------------------------------------------------------------------
plot102:
; CaK and Lyman alpha reconstructions
!x.range=[1978,2015]
!p.noerase=0
!p.region=[0,0.5,1,1]
r=where(caall gt 0)
plot,dyall(r)/365.25+1978,caall(r),/nodata,xticklen=0.05,title='SacPk CXaK'
oplot,dyall(r)/365.25+1978,caall(r)
r=where(rccaall(*,0,0) gt 0)
oplot,dyall(r)/365.25+1978,rccaall(r,0,0),color=14
oplot,dyall(r)/365.25+1978,rccaall(r,0,1),color=19
;
!p.noerase=1
!p.region=[0,0,1,0.5]
r=where(laall gt 0)
plot,dyall(r)/365.25+1978,laall(r),/nodata,xticklen=0.05,title='Lyman Alpha'
oplot,dyall(r)/365.25+1978,laall(r)
r=where(rclaall(*,0,0) gt 0)
oplot,dyall(r)/365.25+1978,rclaall(r,0,0),color=14
oplot,dyall(r)/365.25+1978,rclaall(r,0,1),color=19
;
r=where(nrlsiall(1,*) gt 0)
oplot,dyall(r)/365.25+1978,nrlsiall(1,r)*0.63,color=16
;
goto,cont100
;-------------------------------------------------------------------
plot200:
cs=1.2
!p.charsize=cs
; absolute spectrum of NRLSSI and NRLSSI2 
;
!p.noerase=0
tt='Average Spectrum'
!p.region=[0.05,.5,0.95,.9]
!y.range=[0.00001,5]
!x.range=[100,2500]
!y.range=[0,2]
!x.range=[300,400]
plot_oi,wv,(rcsiav(*,0)+rcsiav(*,1))/2.,xticklen=0.05,/nodata,$
  ytitle='W m!u-2!n nm!u-1!n',xtitle='Wavelength (nm)',title=tt
oplot,nrlwv,(nrlsiav(*,0)+nrlsiav(*,1))/2.,color=1
oplot,wv,(rcsiav(*,0)+rcsiav(*,1))/2.,color=13
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.3
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.013
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.26
xyouts,x1,y1,'NRLSSI',color=1
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.3
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.18
xyouts,x1,y1,'NRLSSI2 (SORCE)',color=13
;
; ratio of spectra
; need to match up the wavelength scales
;...nrlwv(0)=120.5,  wv(5)=120.5
; spline the rcsiav spectra onto the nrlssi wavelength grid
; for the wavelength range 120.5 to 2411.5
gwv=nrlwv(0:960)
grcsi=interpol((rcsiav(*,0)+rcsiav(*,1))/2.,wv,gwv)
tt='Ratio: NRLSSI2/NRLSSI'
!p.noerase=1
!p.region=[0.05,0.1,0.95,0.5]
!y.range=[0.8,1.2]
plot,gwv,grcsi/(nrlsiav(0:960,0)+nrlsiav(0:960,1))*2.,/nodata,xticklen=0.05,$
  ytitle='Ratio',xtitle='Wavelength (nm)',title=tt
oplot,gwv,grcsi/(nrlsiav(0:960,0)+nrlsiav(0:960,1))*2.
goto,cont100
;-------------------------------------------------------------------
plot201:
cs=1.2
!p.charsize=cs
; compare changes in NRLSSI and NRLSSI2 - individual days
; 
; for Oct 2003 rotation
d2=19
m2=10
y2=2003
d1=27
m1=10
y1=2003
;
; for Nov 2003 rotation
d2=11
m2=11
y2=2003
d1=27
m1=11
y1=2003
;
; d2=30
; m2=12
; y2=2003
; d1=4
; m1=1
; y1=2004
;
!x.range=[100,300]
!x.range=[300,600]
!x.range=[600,900]
!x.range=[900,1200]
!x.range=[1200,1500]
!x.range=[1500,1800]
!x.range=[100,2000]
a1=julday(m1,d1,y1)-julday(1,1,2003)
a2=julday(m2,d2,y2)-julday(1,1,2003)
dt1=string(y1,'(i4)')+string(m1,'(i2)')+string(d1,'(i2)')
dt2=string(y2,'(i4)')+string(m2,'(i2)')+string(d2,'(i2)')
;---------- percent change
!p.region=[0,0.5,1,1]
tit='Perecnt: '+dt1+' / '+dt2
if(!x.range(1) eq 300) then !y.range=[-1,30]
if(!x.range(1) eq 600) then !y.range=[-0.8,0.5]
if(!x.range(1) eq 900) then !y.range=[-0.5,0]
if(!x.range(1) eq 1200) then !y.range=[-0.3,0.]
if(!x.range(1) eq 1500) then !y.range=[-0.25,-0.05]
if(!x.range(1) eq 1800) then !y.range=[-0.3,0.3]
!y.range=[-2,20]
!y.range=[-2,30]
plot_oi,wv,rcsi(*,a1,0)/rcsi(*,a2,0)-1,/nodata,ytitle='Percent',title=tit
oplot,wv,(si20(*,a1)/si20(*,a2)-1)*100.,color=14,linestyle=2
oplot,wv,(si21(*,a1)/si21(*,a2)-1)*100.,color=14
oplot,wlgridq,(nrl220(*,a1)/nrl220(*,a2)-1.)*100.,color=19,linestyle=2
oplot,wlgridq,(nrl221(*,a1)/nrl221(*,a2)-1.)*100.,color=19
;
; add lables
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.2
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.82
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.74
xyouts,x1,y1,'SORCE',color=14,charsize=cs
xyouts,x1,y2,'NRLSSI2 ',color=1,charsize=cs
if(simver eq 0) then xyouts,x1,y3,'NRLSSI2 V12V19',color=19,charsize=cs
if(simver eq 1) then xyouts,x1,y3,'NRLSSI2 V13V20',color=19,charsize=cs
;
;---------- difference
!p.region=[0,0,1,.5]
tit='Energy: '+dt1+' !8minus!3 '+dt2
if(!x.range(1) eq 300) then !y.range=[-3,3]
if(!x.range(1) eq 600) then !y.range=[-10,3]
if(!x.range(1) eq 900) then !y.range=[-6,1]
if(!x.range(1) eq 1200) then !y.range=[-2.5,0]
if(!x.range(1) eq 1500) then !y.range=[-1.0,0]
if(!x.range(1) eq 1800) then !y.range=[-1,1]
!y.range=[-8,3]
!y.range=[-3,5]
!p.noerase=1
plot_oi,wv,rcsi(*,a1,0)-rcsi(*,a2,0),/nodata,ytitle='Difference',title=tit
oplot,wv,(si21(*,a1)-si21(*,a2))*1000.,color=14
oplot,nrlwv,nrlsi(*,a1)-nrlsi(*,a2),color=1
oplot,wlgridq,(nrl221(*,a1)-nrl221(*,a2))*1000.,color=19,thick=th*2
oplot,wlgridq,(nrl220(*,a1)-nrl220(*,a2))*1000.,color=1,linestyle=2,thick=th*0.5
oplot,[!x.range(0),!x.range(1)],[0,0],linestyle=2
;
; add lables
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.2
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.82
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.74
xyouts,x1,y1,'SORCE V13V21 ',color=14,charsize=cs
xyouts,x1,y2,'NRLSSI ',color=1,charsize=cs
if(simver eq 0) then xyouts,x1,y3,'NRLSSI2 V12V19',color=19,charsize=cs
if(simver eq 1) then xyouts,x1,y3,'NRLSSI2 V13V20',color=19,charsize=cs
;
goto,cont100
;-------------------------------------------------------------------
plot202:
cs=1.2
!p.charsize=cs
; cycle changes in NRLSSI, SORCE and NRLSSI2 model
;
!x.range=[100,300]
; !x.range=[300,600]
; !x.range=[600,900]
; !x.range=[900,1200]
; !x.range=[1200,1500]
; !x.range=[1500,1800]
!x.range=[100,5000]
;
!p.noerase=0
!p.region=[0.05,.5,0.95,.95]
; percentage change
if(!x.range(1) eq 300) then !y.range=[-1,30]
if(!x.range(1) eq 600) then !y.range=[-0.2,1]
if(!x.range(1) eq 900) then !y.range=[-0.2,0.1]
if(!x.range(1) eq 1200) then !y.range=[-0.25,0.1]
if(!x.range(1) eq 1500) then !y.range=[-0.2,0.1]
if(!x.range(1) eq 1800) then !y.range=[-0.5,0.1]
!y.range=[0.0001,100]
;
tit='Percent Change: Max to Min'
plot_oo,wlgridq,(nrl2av20(*,0)/nrl2av20(*,1)-1)*100.,xticklen=0.05,/nodata,$
  ytitle='Percent',xtitle='Wavelength (nm)',title=tit
oplot,nrlwv,(nrlav(*,0)/nrlav(*,1)-1)*100.,color=1
; oplot,wv,(siav(*,0)/siav(*,1)-1)*100.,color=13
oplot,wlgridq,(nrl2av20(*,0)/nrl2av20(*,1)-1)*100.,color=14
oplot,wlgridq,(nrl2av21(*,0)/nrl2av21(*,1)-1)*100.,color=19
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.0001
xyouts,x1,y1,'NRLSSI ',color=1
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.00005
; xyouts,x1,y1,'SORCE ',color=14
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.00003
xyouts,x1,y1,'NRLSSI2 V20',color=14
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.00001
xyouts,x1,y1,'NRLSSI2 V21',color=19
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.2
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.008
tit='max: '+string(yrmax1,'(f8.2)')+' to '+string(yrmax2,'(f8.2)')
xyouts,x1,y1,tit,color=1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.002
tit='min: '+string(yrmin1,'(f8.2)')+' to '+string(yrmin2,'(f8.2)')
xyouts,x1,y1,tit,color=1
;
; energy change
tt='Irradiance Energy Change: Max !8minus!3 Min'
!p.noerase=1
!p.region=[0.05,0.05,0.95,0.5]
if(!x.range(1) eq 300) then !y.range=[-0.5,5]
if(!x.range(1) eq 600) then !y.range=[-4,6]
if(!x.range(1) eq 900) then !y.range=[-2.5,1.5]
if(!x.range(1) eq 1200) then !y.range=[-1,1]
if(!x.range(1) eq 1500) then !y.range=[-0.6,0.4]
if(!x.range(1) eq 1800) then !y.range=[-2,0.1]
!y.range=[-1,5]
;
plot_oi,wlgridq,(nrl2av(*,0)-nrl2av(*,1))*1000,/nodata,xticklen=0.05,$
  ytitle='W m!u-2!n nm!u-1!n',xtitle='Wavelength (nm)',title=tt
oplot,nrlwv,(nrlav(*,0)-nrlav(*,1))*1000.,color=1
; oplot,wv,(avsrc2-avsrc1)*1000.,color=14
; oplot,wlgridq,(nrl2av(*,0)-nrl2av(*,1))*10000.,color=19
oplot,wlgridq,(nrl2av20(*,0)-nrl2av20(*,1))*1000.,color=14
oplot,wlgridq,(nrl2av21(*,0)-nrl2av21(*,1))*1000.,color=19
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.7
xyouts,x1,y1,'NRLSSI ',color=1
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.4
; xyouts,x1,y1,'SORCE ',color=14
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.6
xyouts,x1,y1,'NRLSSI2 V20',color=14
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.005
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.5
xyouts,x1,y1,'NRLSSI2 V21',color=19
;
goto,cont100
;-------------------------------------------------------------------
plot203:
; compare NRLTSI2 and total(NRLSSI2)
cs=1.2
!p.charsize=cs
; plot modeled and observed TSI, including total of si
; daily at max and min and smoothed over cycle
;
yt='W m!u-2!n'
!p.noerase=0
!p.region=[0,0,1,0.35]
!x.range=[2003,2014.5]
; !x.range=[2008,2009]
; !x.range=[2003.7,2004]
!y.range=[1356,1363]
r=where(rcti(*,0,0) gt 0)
plot,dy(r)/365.25+2003,rcti(r,0,0),/nodata,ytitle=yt,$
		xticklen=0.05
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=19,thick=th*2
r=where(nrl2tot gt 0)
oplot,dy(r)/365.25+2003,nrl2tot(r),color=16,thick=th*0.3
;
!p.noerase=1
smp=80
!p.region=[0,0.3,1,0.65]
!x.range=[2003,2014.5]
; !x.range=[2008,2009]
; !x.range=[2003.7,2004]
!y.range=[1360.3,1361.8]
r=where(rcti(*,0,0) gt 0)
smx=smooth(dy(r)/365.25+2003,smp)
smy=smooth(rcti(r,0,0),smp)
nsm=n_elements(smx)
plot,dy(r)/365.25+2003,rcti(r,0,0),/nodata,ytitle=yt,$
         xticklen=0.05
oplot,smx(smp/2:nsm-smp/2),smy(smp/2:nsm-smp/2),$
             color=19,thick=th*2
r=where(nrl2tot gt 0)
smx=smooth(dy(r)/365.25+2003,smp)
smy=smooth(nrl2tot(r),smp)
nsm=n_elements(smx)
oplot,smx(smp/2:nsm-smp/2),smy(smp/2:nsm-smp/2),color=16,$
        thick=th*0.3
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.3
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.34
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.38
x4=!x.range(0)+(!x.range(1)-!x.range(0))*0.42
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.85
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.75
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.65
xyouts,x4,y2*1.000002,'NRLTSI2 model',color=19
; oplot,[x1,x2,x3],[y3,y3,y3],color=1
xyouts,x4,y3*1.000002,'total(NRLSI2) model ',color=16
;
!p.region=[0,0.6,0.53,0.93]
!x.range=[2003.7,2004]
!y.range=[1356.3,1362.5]
r=where(rcti(*,0,0) gt 0)
plot,dy(r)/365.25+2003,rcti(r,0,0),/nodata,ytitle=yt,$
               xticks=3,xticklen=0.05,yticklen=0.05
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=19,thick=th*2
r=where(nrl2tot gt 0)
oplot,dy(r)/365.25+2003,nrl2tot(r),color=16,thick=th*0.3
;
!p.region=[0.47,0.6,1,0.93]
!x.range=[2008.7,2009]
!y.range=[1360.0,1361.09]
r=where(rcti(*,0,0) gt 0)
plot,dy(r)/365.25+2003,rcti(r,0,0),/nodata,$
	xticks=3,xticklen=0.05,yticklen=0.05
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=19,thick=th*2
r=where(nrl2tot gt 0)
oplot,dy(r)/365.25+2003,nrl2tot(r),color=16,thick=th*0.3
;
goto,cont100
;-------------------------------------------------------------------
plot204:
; compare spot & fc components in NRLTSI2 and total(NRLSSI2)
cs=1.2
!p.charsize=cs
; plot modeled and observed sspot & fac, including total of si
; daily at max and min and smoothed over cycle
;
yt='W m!u-2!n'
!p.noerase=0
!p.region=[0,0,1,0.35]
!x.range=[2003,2014.5]
; !x.range=[2008,2009]
; !x.range=[2003.7,2004]
!y.range=[-6,4]
r=where(rcti(*,0,0) gt 0)
plot,dy(r)/365.25+2003,rcti(r,0,1),/nodata,ytitle=yt,$
		xticklen=0.05
oplot,dy(r)/365.25+2003,rcti(r,1,0),color=19
oplot,dy(r)/365.25+2003,rcti(r,2,0),color=19
r=where(nrl2tot gt 0)
oplot,dy(r)/365.25+2003,dfactot(r),color=16
oplot,dy(r)/365.25+2003,dspottot(r),color=16
;
!p.noerase=1
smp=80
!p.region=[0,0.3,1,0.65]
!x.range=[2003,2014.5]
!y.range=[-2,2]
; !x.range=[2008,2009]
; !x.range=[2003.7,2004]
r=where(rcti(*,0,0) gt 0)
smx=smooth(dy(r)/365.25+2003,smp)
smyf=smooth(rcti(r,1,0),smp)
smys=smooth(rcti(r,2,0),smp)
nsm=n_elements(smx)
plot,dy(r)/365.25+2003,rcti(r,1,0),/nodata,ytitle=yt,$
         xticklen=0.05
oplot,smx(smp/2:nsm-smp/2),smyf(smp/2:nsm-smp/2),$
             color=19
oplot,smx(smp/2:nsm-smp/2),smys(smp/2:nsm-smp/2),$
             color=19
r=where(nrl2tot gt 0)
smx=smooth(dy(r)/365.25+2003,smp)
smyf=smooth(dfactot(r),smp)
smys=smooth(dspottot(r),smp)
nsm=n_elements(smx)
oplot,smx(smp/2:nsm-smp/2),smyf(smp/2:nsm-smp/2),color=16
oplot,smx(smp/2:nsm-smp/2),smys(smp/2:nsm-smp/2),color=16
oplot,[!x.range(0),!x.range(1)],[0,0]
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.3
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.34
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.38
x4=!x.range(0)+(!x.range(1)-!x.range(0))*0.42
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.85
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.75
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.65
xyouts,x4,y2*1.000002,'NRLTSI2 model',color=19
; oplot,[x1,x2,x3],[y3,y3,y3],color=1
xyouts,x4,y3*1.000002,'total(NRLSI2) model ',color=16
;
!p.region=[0,0.6,0.53,0.93]
!x.range=[2003.7,2004]
!y.range=[-6,4]
r=where(rcti(*,1,0) gt 0)
plot,dy(r)/365.25+2003,rcti(r,1,0),/nodata,ytitle=yt,$
               xticks=3,xticklen=0.05,yticklen=0.05
oplot,dy(r)/365.25+2003,rcti(r,1,0),color=19
oplot,dy(r)/365.25+2003,rcti(r,2,0),color=19
r=where(nrl2tot gt 0)
oplot,dy(r)/365.25+2003,dfactot(r),color=16
oplot,dy(r)/365.25+2003,dspottot(r),color=16
;
!p.region=[0.47,0.6,1,0.93]
!x.range=[2008.7,2009]
!y.range=[-0.5,0.5]
r=where(rcti(*,0,0) gt 0)
plot,dy(r)/365.25+2003,rcti(r,1,0),/nodata,$
	xticks=3,xticklen=0.05,yticklen=0.05
oplot,dy(r)/365.25+2003,rcti(r,1,0),color=19
oplot,dy(r)/365.25+2003,rcti(r,2,0),color=19
r=where(nrl2tot gt 0)
oplot,dy(r)/365.25+2003,dfactot(r),color=16
oplot,dy(r)/365.25+2003,dspottot(r),color=16
;
goto,cont100
;-------------------------------------------------------------------
;-------------------------------------------------------------------
; additonal plot concepts -not yet functional
;-------------------------------------------------------------------
plot11:
; maps of model data ratios
; pick selected wavelength band
a1=0		; 201.5 nm
a2=100		; 301.5 nm
print,wv(a1),wv(a2)
im=transpose(si(a1:a2,*)/rcsi(a1:a2,*,0))
minim=0.5
maxim=1.5
xsiz=12000
ysiz=10000
xstar=100
ystar=5000
tv,bytscl((im-minim)/(maxim-minim)*255.,min=0,max=255),xstar,ystar,$
          xsize=xsiz,ysize=ysiz
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.6
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.25
xyouts,x1,y1,'observations/NRLSSI',color=16
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.17
xyouts,x1,y2,'new model/NRLSSI!c(from SORCE data)',color=7
;
goto,cont100
;-----------------------------------------------------------------------
plot12:
; time series of model data ratios
;
jj0=0
jj1=13
; pick selected wavelength band
for jj=jj0,jj1 do begin
a1=100*jj		; 201.5 nm
a2=100*(jj+1)		; 301.5 nm
print,wv(a1),wv(a2),jj+1
r1=si(a2,*) gt 0
r2=rcsi(a2,*,0) gt 0
r=where(r1*r2)
if(jj0 lt 2) then !y.range=[0.9,1.1]
if(jj0 ge 2) then !y.range=[0.99,1.01]
if jj eq jj0 then plot,dy(r)/365.25+2003,si(a2,r),/nodata
for aa=a1,a2 do begin
r1=si(aa,*) gt 0
r2=rcsi(aa,*,0) gt 0
r3=si(aa,*)/rcsi(aa,*,0) lt 1.1
r4=si(aa,*)/rcsi(aa,*,0) gt 0.9
r=where(r1*r2*r3*r4)
oplot,dy(r)/365.25+2003,si(aa,r)/rcsi(aa,r,0),color=jj+1
endfor
endfor
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.6
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.25
xyouts,x1,y1,'observations/NRLSSI',color=16
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.17
xyouts,x1,y2,'SORCE model/NRLSSI',color=7
;
goto,cont100
;-----------------------------------------------------------------------
plot23:
;
; plot spectral energy changes for selected days
;
sel=2
; select two days for comparison
if(sel eq 1) then begin
; July 2004
d1=15
m1=7
y1=2004
d2=23
m2=7
y2=2004
!y.range=[-5,1]
endif
if(sel eq 2) then begin
; July 2005
d1=19
m1=7
y1=2005
d2=1
m2=8
y2=2005
!y.range=[-2,4]
endif
; 
ar1=julday(m1,d1,y1)-julday(1,1,2003)
ar2=julday(m2,d2,y2)-julday(1,1,2003)
!p.region=[0,0,1,1]
!p.noerase=0
!x.range=[110,1600]
xt='Wavelength (nm)'
yt='mW m!u-2!n nm!u-1!n'
plot,katwav,scgis(*,ar2)-scgis(*,ar1),/nodata,ytitle=yt,$
          xtitle=xt
oplot,katwav,katflx(*,ar2)-katflx(*,ar1),color=6,thick=th*0.5
oplot,katwav,rckat(*,ar2)-rckat(*,ar1),color=7,thick=th*1.5
oplot,katwav,sckat(*,ar2)-sckat(*,ar1),color=16,thick=th
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.6
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.25
xyouts,x1,y1,'observations',color=16
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.21
xyouts,x1,y1,'NRLSSI',color=6
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.17
xyouts,x1,y2,'new model!c(from SORCE data)',color=7
;
goto,cont100
;-----------------------------------------------------------------------
plot300:
;
; compare SIM and NRLSSI 540-640 nm for Hillary
cs=1.2
bb=14
!p.charsize=cs
!x.range=[2004,2011]
; !x.range=[2008,2008.5]
!x.style=1
!y.style=1
xtn=replicate('  ',10)
!p.noerase=0
!p.region=[0,.5,.98,0.98]
!y.range=[175,175.8]
;
xx1=bnsi(bb,*)		; source
xx2=bnrcsi(bb,*)	; ssi sorce model
xx3=bnnrl(bb,*)	; nrlssi - original model
r1=xx1 gt 0
r2=xx2 gt 0
r3=xx3 gt 0
r=where(r1)
; !y.range=[11,11.8]
xtn=replicate('  ',10)
yt='W m!u-2!n'
plot,dy(r)/365.25+2003,xx1(r),/nodata,ytitle=yt,$
         xticklen=0.05
r=where(r1,cnt)
oplot,dy(r)/365.25+2003,xx1(r)*0.988,color=14,thick=th
r=where(r3,cnt)
oplot,dyall(r)/365.25+1978,xx3(r),color=1,thick=th
; check offset of dyall and dy arrays
oplot,dy(0:*)/365.25+2003,xx3(9131:*),color=20,thick=th
r=where(r2,cnt)
oplot,dy(r)/365.25+2003,xx2(r),color=19,thick=th
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.35
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.02
sw1=string(bnwv1(bb),'(i3)')
sw2=string(bnwv2(bb),'(i3)')
xyouts,x1,y1,sw1+' - '+sw2+' nm'
print,bb,'     ',sw1,'     ',sw2
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.35
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.41
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.43
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.4
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.3
oplot,[x1,x2],[y1,y1],color=14
xyouts,x3,y1,'SORCE SIM!9X!30.988',color=14
oplot,[x1,x2],[y2,y2],color=1
xyouts,x3,y2,'NRLSSI',color=1
;
goto,cont100
;---------------------------------------------------------------
; plots for NOAA C-ATBD
;---------------------------------------------------------------
plot400:
; sunspot darkening and facular brightening time series
;
cs=1.2
!p.charsize=cs
!y.style=9
!x.style=9
;
yt='Index'
!p.noerase=0
!p.region=[0,0.3,1,0.65]
!x.range=[2003.7,2004.2]	; use for Fig 3
; !x.range=[1978,2015]		; use for Fig 2
!y.range=[0.15,0.185]
; !y.range=[0.15,0.17]
r=where(mgall gt 0)
plot,dyall(r)/365.25+1978,mgall(r),/nodata,ytitle=yt,$
		xticklen=0.05
oplot,dyall(r)/365.25+1978,mgall(r),color=19
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.05
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.95
xyouts,x1,y1,'Facular Brightening (GOME MgII Index)',charsize=cs*1.1,color=19
;
!p.noerase=1
!p.region=[0,0,1,0.35]
!y.range=[0,10000]
r=where(sball gt 0)
yt='10!u6!n Solar Hemisphere'
plot,dyall(r)/365.25+1978,sball(r),/nodata,ytitle=yt,$
		xticklen=0.05
oplot,dyall(r)/365.25+1978,sball(r),color=16
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.05
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.95
xyouts,x1,y1,'Sunspot Darkening (from USAF Sunspot Regions)',charsize=cs*1.1,color=16
;
goto,cont100
;---------------------------------------------------------------
plot401:
; baseline quoet sun solar irradiance spectrum - & compared with others
cs=1.2
!p.charsize=cs
; absolute spectrum of quiet sun
;
!p.noerase=0
tt='NRLSSI2 Reference (Quiet Sun) Spectrum'
!p.region=[0.05,.5,0.95,.9]
!y.range=[0.00000001,10]
!x.range=[100,100000]
if(plt eq 4011) then begin
!x.range=[200,450]
!y.range=[0,2]
endif
;
if(plt eq 401) then plot_oo,wlgridq,quiet,/nodata,xticklen=0.05,title=tt,$
   xtitle='Wavelength (nm)',ytitle='Irradiance (W m!u-2!n nm!u-1!n)'
if(plt eq 4011) then plot,wlgridq,quiet,/nodata,xticklen=0.05,title=tt,$
   xtitle='Wavelength (nm)',ytitle='Irradiance (W m!u-2!n nm!u-1!n)'
oplot,wlgridq,quiet0,color=13
oplot,wlgridq,quiet
oplot,wlgridq,wspec1,color=20
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.001
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.0000001
if(plt eq 4011) then x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
if(plt eq 4011) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.8
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.72
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.64
xyouts,x1,y1,'NRLSSI2',color=1
xyouts,x1,y2,'NRLSSI',color=13
xyouts,x1,y3,'WHI',color=20
endif
if(plt eq 401) then begin
tot=total(quiet)
xyouts,x1,y1,'Total Irradaonce ='+string(tot,'(F8.2)')+' Wm!u-2!n',color=1
endif
;
; ratio of other spectra reference
; need to match up the wavelength scales
;...nrlwv(0)=120.5,  wv(5)=120.5
; spline the rcsiav spectra onto the nrlssi wavelength grid
; for the wavelength range 120.5 to 2411.5
;
tt='Ratio to NRLSSI2 Reference Spectrum'
!p.noerase=1
;
!p.region=[0.05,0.09,0.95,0.49]
!p.noerase=1
!y.range=[.6,1.4]
if(plt eq 401) then plot_oi,wlgridq,quiet/quiet0,/nodata,title=tt,$
           ytitle='Ratio',xtitle='Wavelength (nm)'
if(plt eq 4011) then plot,wlgridq,quiet/quiet0,/nodata,title=tt,$
           ytitle='Ratio',xtitle='Wavelength (nm)'
;; WRC
; regrid onto (part of) wlgridq array
wrcg=fltarr(ngridq)
result=interpol(wrc(1,*),wrc(0,*),wlgridq(85:9894))
wrcg(85:9894)=result
if(plt eq 401) then oplot,wlgridq,wrcg*10./quiet,color=14
oplot,wlgridq,quiet/quiet0,color=13
oplot,wlgridq,quiet/wspec1,color=20
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.007
if(plt eq 4011) then x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
xyouts,x1,y1,'NRLSSI/NRLSSI2',charsize=cs*1.1,color=13
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.82
xyouts,x1,y1,'SORCE WHI/NRLSSI2',charsize=cs*1.1,color=20
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.74
if(plt eq 401) then xyouts,x1,y1,'WRC/NRLSSI2',charsize=cs*1.1,color=14

goto,cont100
;---------------------------------------------------------------
plot402:
; sunspot and facular scaling coefs
cs=1.2
!p.charsize=cs
;
!p.noerase=0
!x.range=[100,100000]
tt='Facular Scaling Coefficients'
!p.region=[0.05,.55,0.95,.9]
!y.range=[0.000000001,1]
plot_oo,wlgridq,faccf,/nodata,xticklen=0.05,$
   xtitle='Wavelength (nm)',ytitle='Coefficient
oplot,wlgridq,faccf21,color=19,thick=th*2
; oplot,wlgridq,faccf20,color=1,thick=th*0.5,linestyle=2
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.0002
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.9
xyouts,x1,y1,'Facular Index Scaling Coefficient',charsize=cs*1.1
;
!p.noerase=1
!p.region=[0.05,.2,0.95,.55]
!y.range=[-0.0000015,0.0]
tt='Sunspot Scaling Coefficients'
plot_oi,wlgridq,spotcf,/nodata,xticklen=0.05,$
   xtitle='Wavelength (nm)',ytitle='Coefficient
oplot,wlgridq,spotcf21,color=16,thick=th*2
; oplot,wlgridq,spotcf20,color=1,thick=th*0.5,linestyle=2
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.0002
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.05
xyouts,x1,y1,'Sunspot Index Scaling Coefficient',charsize=cs*1.1
;
goto,cont100
;-------------------------------------------------------------------
plot403:
cs=1.2
!p.charsize=cs
; cycle 24 max/min changes in NRLSSI and NRLSSI2 model - using refernece spectra
;
!p.noerase=0
tt='Max='+string(yrmax1,'(f8.2)')+' to '+string(yrmax2,'(f8.2)')
tt=tt+'!cMin='+string(yrmin1,'(f8.2)')+' to '+string(yrmin2,'(f8.2)')
!p.region=[0.05,.55,0.95,.95]
; percentage change
!y.range=[0.0001,100]
; !y.range=[0.005,10]
!x.range=[100,100000]
!x.range=[100,10000]
; !x.range=[500,1200]
; !x.range=[900,3000]
; !x.range=[300,400]
; !y.range=[-0.02,.1]
plot_oo,wlgridq,(nrl2av(0,*)/nrl2av(*,1)-1.)*100.,xticklen=0.05,/nodata,$
  ytitle='Percent',xtitle='Wavelength (nm)',title=tt
oplot,nrlwv,(nrlav(*,0)/nrlav(*,1)-1)*100.,color=1
oplot,wlgridq,(nrl2av21(*,0)/nrl2av21(*,1)-1)*100.,color=19,thick=th*2
; oplot,wlgridq,(nrl2av20(*,0)/nrl2av20(*,1)-1)*100.,color=1,linestyle=2,thick=th*0.5
; oplot,wv,(siav21(*,0)/siav21(*,1)-1)*100.,color=14
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.2
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.04
xyouts,x1,y1,'NRLSSI',color=1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.11

xyouts,x1,y1,'NRLSSI2 V13V21',charsize=cs*1.1,color=19
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.014
; xyouts,x1,y1,'SORCE V13V21',color=14
;
; energy change
tt='Difference'
!p.noerase=1
!p.region=[0.05,0.15,0.95,0.55]
!y.range=[-0.004,.008]
!y.range=[-0.001,.004]
plot_oi,wlgridq,nrl2av21(*,0)-nrl2av21(*,1),/nodata,xticklen=0.05,$
  ytitle='W m!u-2!n nm!u-1!n',xtitle='Wavelength (nm)',title=tt
oplot,nrlwv,(nrlav(*,0)-nrlav(*,1)),color=1
oplot,wlgridq,nrl2av21(*,0)-nrl2av21(*,1),color=19,thick=th*2
; oplot,wlgridq,nrl2av20(*,0)-nrl2av20(*,1),color=1,thick=th*0.5,linestyle=1
; oplot,wv,si1av(*,0)-si1av(*,1),color=14
;
; add lables
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.71
xyouts,x1,y1,'NRLSSI',charsize=cs*1.1,color=1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.8
xyouts,x1,y1,'NRLSSI2 V13V21',charsize=cs*1.1,color=19
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.62
; xyouts,x1,y1,'SORCE V13V21',charsize=cs*1.1,color=14
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot404:
; histograms of ti-Tquiet and ti-tismooth
;
!p.noerase=0
!p.region=[0,.5,.5,1]
r1=ti gt 0
r2=smti gt 0
r=where(r1*r2)
hmin=-3.5
hmax=2
bs=0.1
histcyc=histogram(ti(r)-tiquiet,binsize=bs,min=hmin,max=hmax)
bin=findgen(n_elements(histcyc))*bs+hmin
histrot=histogram(ti(r)-smti(r),binsize=bs,min=hmin,max=hmax)
;
!y.range=[0,1000]
plot,bin,histcyc,/nodata
oplot,bin,histcyc,color=13,psym=10
oplot,bin,histrot,color=20,psym=10
;
!p.noerase=1
!p.region=[.5,0.5,1,1]
r3=mg gt 0
r=where(r1*r2*r3)
!y.range=0
plot,mg(r),ti(r)-tiquiet,/nodata
oplot,mg(r),ti(r)-tiquiet,psym=-2,color=13
oplot,mg(r),ti(r)-smti(r),psym=-2,color=20
;
; now repeat for Sac Pk Ca
!p.region=[0,0,.5,0.5]
r1=caall gt 0
r2=smcaall gt 0
r=where(r1*r2)
hmin=-0.001
hmax=0.03
bs=0.001
histcyc=histogram(caall(r)-caquiet,binsize=bs,min=hmin,max=hmax)
bin=findgen(n_elements(histcyc))*bs+hmin
histrot=histogram(caall(r)-smcaall(r),binsize=bs,min=hmin,max=hmax)
;
!y.range=[0,1000]
plot,bin,histcyc,/nodata
oplot,bin,histcyc,color=13,psym=10
oplot,bin,histrot,color=20,psym=10
;
!p.noerase=1
!y.range=0
!p.region=[.5,0,1,0.5]
r3=mgall gt 0
r=where(r1*r2*r3)
plot,mgall(r),caall(r)-caquiet,/nodata
oplot,mgall(r),caall(r)-caquiet,psym=-2,color=13
oplot,mgall(r),caall(r)-smcaall(r),psym=-2,color=20
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot405:
; TSi &  spot & fc components for NRLTSI2 
cs=1.2
!p.charsize=cs

; plot model & spot & fac
yt='W m!u-2!n'
!p.noerase=0
!p.region=[0,0.6,1,1]
!x.range=[1978,2015.0]
!y.range=[1356,1363]
r1=rctiall(*,1,0) ge 0
r2=rctiall(*,2,0) le 0
r=where(r1*r2)
plot,dyall(r)/365.25+1978,rctiall(r,0,1),/nodata,ytitle=yt,$
		xticklen=0.05,title='NRLTSI2 Total Solar Irradiance'
oplot,dyall(r)/365.25+1978,rctiall(r,0,1),color=13
;
!p.noerase=1
!p.region=[0,0.22,1,0.62]
!y.range=[-7,5]
plot,dyall(r)/365.25+1978,rctiall(r,1,0),/nodata,ytitle=yt,$
         xticklen=0.05,title='Facular and Sunspot Components'
oplot,dyall(r)/365.25+1978,rctiall(r,1,0),color=19
oplot,dyall(r)/365.25+1978,rctiall(r,2,0),color=16
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.42
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.8
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.3
xyouts,x1,y1,'faculae',color=19
xyouts,x1,y2,'sunspots',color=16
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot406:
;
; plot spectral irradiance time series
; make an aray of scaling to use when comparing nrlssi and nrlssi2 (two versions)  
; - cycle
; 
; array must match wavelengths
ymax=fltarr(nbn)
ymin=fltarr(nbn)
nrlscl=fltarr(nbn)
si21scl=fltarr(nbn)
;
; cycle through bins and determine inital scaling and max and min of plots
; for the epoch of the plot
!x.range=[2003,2014]
!x.range=[2003.5,2005]
; !x.range=[2003.5,2004]
s1=dy/365.25+2003 gt !x.range(0)
s2=dy/365.25+2003 lt !x.range(1)
;
for n=0,nbn-1 do begin
r1=bnnrl221(n,*) gt 0
r2=bnnrl(n,*) gt 0
r=where(r1*r2*s1*s2)
nrlscl(n)=total(bnnrl221(n,r))/total(bnnrl(n,r))
r1=bnnrl221(n,*) gt 0
r2=bnsi21(n,*) gt 0
r=where(r1*r2*s1*s2)
si21scl(n)=total(bnnrl221(n,r))/total(bnsi21(n,r))
if(bnwv1(n) eq 300) then begin
r2=bnsi21(n,*) gt 0
r3=bnsi21(n,*) lt 94
r=where(r1*r2*s1*s2*r3)
si21scl(n)=total(bnnrl221(n,r))/total(bnsi21(n,r))
endif
amax=max(bnnrl221(n,r))
amin=min(bnnrl221(n,r))
if(bnwv1(n) eq 200) then begin
ymax(n)=amax+(amax-amin)*0.3
ymin(n)=amin-(amax-amin)*0.2
endif
if(bnwv1(n) eq 300) then begin
ymax(n)=amax+(amax-amin)*0.5
ymin(n)=amin-(amax-amin)*0.6
endif
if(bnwv1(n) eq 700) then begin
ymax(n)=amax+(amax-amin)*0.3
ymin(n)=amin-(amax-amin)*0.6
endif
if(bnwv1(n) eq 1000) then begin
ymax(n)=amax+(amax-amin)*0.3
ymin(n)=amin-(amax-amin)*0.6
endif
endfor
;
cs=1.2
!p.charsize=cs
; plot time series in selected wavelength bands - solar cycle time scales
; for 120 to 400 nm use....
bnd=[0,2,4,5]		; array elements to plot
; for 400 to 1300 nm use....
bnd=[2,5,8,9]		; array elements to plot
; for 1500 to 2300 nm use....
; bnd=[10,11,12,13]	
;
!x.style=9
!y.style=9
xtn=replicate('  ',10)
!p.noerase=0
;;; make plots
for k=0,3 do begin
bb=bnd(k)
if(k eq 0) then begin
!p.region=[0,.68,.98,.98]
endif
if(k eq 1) then begin
!p.noerase=1
!p.region=[0,.45,.98,.75]
endif
if(k eq 2) then begin
!p.region=[0,.23,.98,.53]
endif
if(k eq 3) then begin
!p.region=[0,0,.98,.3]
endif
;
; set yrange
!y.range=[ymin(bb),ymax(bb)]
;
; xx1=bnnrl220(bb,*)		; nrlssi2 - new model V20
xx2=bnnrl221(bb,*)		; nrlssi2 - new model V21
xx3=bnnrl(bb,*)*nrlscl(bb)	; nrlssi - original model
xx4=bnsi21(bb,*)*si21scl(bb)		; ssi version 21
;
r1=mg gt 0
r2=sb ge 0
; r3=xx1 gt 0
r4=xx4 gt 0
r5=xx4 lt !y.range(1)
r=where(r1*r2,cnt)
xtn=replicate('  ',10)
if(K eq 2) then yt='              W m!u-2!n'
if(k ne 2) then yt='   '
yt='W m!u-2!n'
if(k le 2) then plot,dy(r)/365.25+2003,xx2(r),/nodata,ytitle=yt,$
         xticklen=0.05,xtickname=xtn
if(k eq 3) then plot,dy(r)/365.25+2003,xx2(r),/nodata,ytitle=yt,$
         xticklen=0.05
; oplot,dy(r)/365.25+2003,xx1(r),color=1,thick=th*2
oplot,dy(r)/365.25+2003,xx2(r),color=19,thick=th*2
oplot,dy(r)/365.25+2003,xx3(r),color=1,thick=th*0.5
r=where(r4*r5,cnt)
if(cnt gt 0) then oplot,dy(r)/365.25+2003,xx4(r),color=14,psym=-4,symsiz=.3
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.1
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.95
if(bnwv1(bb) lt 1000) then begin
sw1=string(bnwv1(bb),'(i3)')
endif
if(bnwv1(bb) ge 1000) then sw1=string(bnwv1(bb),'(i4)')
if(bnwv2(bb) lt 1000) then begin
sw2=string(bnwv2(bb),'(i3)')
endif
if(bnwv2(bb) ge 1000) then sw2=string(bnwv2(bb),'(i4)')
xyouts,x1,y1,sw1+' - '+sw2+' nm'
print,bb,'     ',sw1,'     ',sw2
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.4
x2=!x.range(0)+(!x.range(1)-!x.range(0))*0.48
x3=!x.range(0)+(!x.range(1)-!x.range(0))*0.55
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.53
if(bnwv1(bb) lt 300) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.8
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.7
endif
if((bnwv1(bb) ge 300) and (bnwv1(bb) lt 1500)) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.4
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.3
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.2
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.1
endif
if(bnwv1(bb) gt 1500) then begin
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.87
y2=!y.range(0)+(!y.range(1)-!y.range(0))*0.77
y3=!y.range(0)+(!y.range(1)-!y.range(0))*0.67
y4=!y.range(0)+(!y.range(1)-!y.range(0))*0.57
endif
;
xyouts,x3,y2,'NRLSSI2',color=19
; oplot,[x1,x2],[y3,y3],color=13
xyouts,x3,y3,'NRLSSI !5X!3'+string(nrlscl(bb),'(f5.3)'),color=1
; oplot,[x1,x2],[y4,y4],color=14
xyouts,x3,y4,'SORCE V21 !5X!3'+string(si21scl(bb),'(f5.3)'),color=14
endfor
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot407:
; NRLTSI2 and total(NRLSSI2) time series and residuals
cs=1.1
!p.charsize=cs
!x.style=9
!y.style=9
;
;  plot time series
yt='W m!u-2!n'
!p.noerase=0
!p.region=[0,0.66,0.55,0.96]
!x.range=[2003,2014.5]
!y.range=[1356,1363]
r1=rcti(*,1,0) ge 0
r2=rcti(*,2,0) le 0
r=where(r1*r2)
plot,dy(r)/365.25+2003,rcti(r,0,0),/nodata,ytitle=yt,$
         xticklen=0.05,title='NRLTSI2 & !4R!3(NRLSSI2)!c!8total!3'
oplot,dy(r)/365.25+2003,nrl2tot(r),color=1
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=13
;
!p.noerase=1
!p.region=[0,0.36,0.55,0.66]
!y.range=[-0.5,2.5]
plot,dy(r)/365.25+2003,rcti(r,1,0),/nodata,ytitle=yt,$
         xticklen=0.05,title='NRLTSI2 & !4R!3(NRLSSI2)!c!8faculae!3'
oplot,dy(r)/365.25+2003,factot(r),color=1
oplot,dy(r)/365.25+2003,rcti(r,1,0),color=19
;
!p.region=[0,0.06,0.55,0.36]
!y.range=[-6,0.5]
plot,dy(r)/365.25+2003,rcti(r,2,0),/nodata,ytitle=yt,$
         xticklen=0.05,title='NRLTSI2 & !4R!3(NRLSSI2)!c!8sunspots!3'
oplot,dy(r)/365.25+2003,spottot(r),color=1
oplot,dy(r)/365.25+2003,rcti(r,2,0),color=16
;
;-----------------------------------------------------------
;--- plot residuals
!p.region=[0.45,0.66,1,0.96]
!x.range=[2003,2014.5]
!y.range=[1356,1363]
r1=rcti(*,1,0) ge 0
r2=rcti(*,2,0) le 0
r=where(r1*r2)
plot,dy(r)/365.25+2003,rcti(r,0,0)-nrl2tot(r)+tiquiet,/nodata,$
         xticklen=0.05,title='Difference NRLTSI2-!4R!3(NRLSSI2)!c!8total!3'
oplot,dy(r)/365.25+2003,rcti(r,0,0)-nrl2tot(r)+tiquiet,color=13
result=moment(rcti(r,0,0)-nrl2tot(r),sdev=sdev)
print,'Total mean and sdev: ',result(0),sdev
;
!p.noerase=1
!p.region=[0.45,0.36,1,0.66]
!y.range=[-0.5,2.5]
plot,dy(r)/365.25+2003,rcti(r,1,0)-factot(r),/nodata,$
         xticklen=0.05,title='Difference NRLTSI2-!5R!3(NRLSSI2)!c!8faculae!3'
oplot,dy(r)/365.25+2003,rcti(r,1,0)-factot(r),color=19
result=moment(rcti(r,1,0)-factot(r),sdev=sdev)
print,'Fac mean and sdev: ',result(0),sdev
;
!p.region=[0.45,0.06,1,0.36]
!y.range=[-6,0.5]
plot,dy(r)/365.25+2003,rcti(r,2,0)-spottot(r),/nodata,$
         xticklen=0.05,title='Difference NRLTSI2-!4R!3(NRLSSI2)!c!8sunspots!3'
oplot,dy(r)/365.25+2003,rcti(r,2,0)-spottot(r),color=16
result=moment(rcti(r,2,0)-spottot(r),sdev=sdev)
print,'Spot mean and sdev: ',result(0),sdev
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot408:
; plot NBRLTSI2 with uncertainties
cs=1.1
!p.charsize=cs
!p.region=[0,.65,0.53,0.95]
!p.noerase=0
!x.range=[2003.6,2004]
!y.range=[1355,1363]
r=where(rcti(*,0,0) gt 0)
tt='NRLTSI2 model of TSi variations with uncertainties'
plot,dy(r)/365.25+2003,rcti(r,0,0),/nodata,xticklen=0.05,$
     ytitle='W m!u2!n'
; oplot,dy(r)/365.25+2003,rcti(r,0,0)
r1=rcti(*,0,0) gt 0
r2=rctiunc(*,0) gt 0
r3=dy/365.25+2003 gt !x.range(0)
r4=dy/365.25+2003 lt !x.range(1)
r=where(r1*r2*r3*r4,cnt)
xxx=[dy(r(0))/365.25+2003,dy(r)/365.25+2003,reverse(dy(r)/365.25+2003)]
xxx=[xxx,dy(r(0))/365.25+2003]
yyy=[rcti(r(0),0,0)+rctiunc(r(0),0),rcti(r,0,0)+rctiunc(r,0)]
yyy=[yyy,reverse(rcti(r,0,0)-rctiunc(r,0))]
yyy=[yyy,rcti(r(0),0,0)-rctiunc(r(0),0)]
polyfill,xxx,yyy,color=8
r=where(rcti(*,0,0) gt 0)
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=14,thick=th
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.02
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.05
xyouts,x1,y1,tt,color=1,charsize=cs*1.2
;
!p.region=[0.47,0.65,1,0.95]
!p.noerase=1
!x.range=[2010,2010.4]
!y.range=[1360,1362]
r=where(rcti(*,0,0) gt 0)
tt='NRLTSI2 model with uncertainties'
tt='   '
plot,dy(r)/365.25+2003,rcti(r,0,0),/nodata,xticklen=0.05,$
     title=tt
; oplot,dy(r)/365.25+2003,rcti(r,0,0)
r1=rcti(*,0,0) gt 0
r2=rctiunc(*,0) gt 0
r3=dy/365.25+2003 gt !x.range(0)
r4=dy/365.25+2003 lt !x.range(1)
r=where(r1*r2*r3*r4,cnt)
xxx=[dy(r(0))/365.25+2003,dy(r)/365.25+2003,reverse(dy(r)/365.25+2003)]
xxx=[xxx,dy(r(0))/365.25+2003]
yyy=[rcti(r(0),0,0)+rctiunc(r(0),0),rcti(r,0,0)+rctiunc(r,0)]
yyy=[yyy,reverse(rcti(r,0,0)-rctiunc(r,0))]
yyy=[yyy,rcti(r(0),0,0)-rctiunc(r(0),0)]
polyfill,xxx,yyy,color=8
r=where(rcti(*,0,0) gt 0)
oplot,dy(r)/365.25+2003,rcti(r,0,0),color=14,thick=th
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot409:
; regression model coefficienrs vs wavelength
cs=1.2
!p.charsize=cs
;
!p.noerase=0
!x.range=[100,3000]
!p.region=[0.05,.45,0.95,.95]
!y.range=[0,200]
plot_oi,wv,sisigma(*,1)/sicoeff(*,1)*100.,/nodata,xticklen=0.05,$
   xtitle='Wavelength (nm)',ytitle='Percent'
oplot,wv,abs(sisigma(*,1)/sicoeff(*,1))*100.,color=19
oplot,wv,abs(sisigma(*,2)/sicoeff(*,2))*100,color=16
;
; add labels
tt='NRLSSI2 Model Coefficient Uncertainties'
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.0002
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.9
xyouts,x1,y1,tt,charsize=cs*1.1,color=1
tt='Facular Brightening'
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.001
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.9
xyouts,x1,y1,tt,charsize=cs,color=19
tt='Sunspot Darkening'
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.001
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.5
xyouts,x1,y1,tt,charsize=cs,color=16
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot410:
; NRLSSI2 model uncertainties
; select a day array value
marr=10
darr=30
yarr=2003
arr=julday(marr,darr,yarr)-julday(1,1,2003)
cs=1.2
!p.charsize=cs
;
!p.noerase=0
!p.region=[0.05,.55,0.95,.95]
!y.range=[-0.016,0.008]
!x.range=[100,10000]
tt='NRLSSI2 Model Energy Change!c from Quiet Sun: '
tt=tt+string(yarr,'(i4)')+string(marr,'(i2)')+string(darr,'(i2)')
plot_oi,wlgridq,nrl2(*,arr)-quiet,/nodata,xticklen=0.05,$
   xtitle='Wavelength (nm)',ytitle='W m!u-2!n',title=tt
oplot,wlgridq,nrl2(*,arr)-quiet,color=19
xx=[wlgridq(0),wlgridq(0:9984),reverse(wlgridq(0:9984)),wlgridq(0)]
yy=nrl2(0,arr)-quiet(0)+nrl2unc(0,arr)
yy=[yy,nrl2(0:9984,arr)-quiet(0:9984)+nrl2unc(0:9984,arr)]
yy=[yy,reverse(nrl2(0:9984,arr)-quiet(0:9984)-nrl2unc(0:9984,arr))]
yy=[yy,nrl2(0,arr)-quiet(0)-nrl2unc(0,arr)]
polyfill,xx,yy,color=8
; oplot,wlgridq,nrl2(*,arr)-quiet+nrl2unc(*,arr),color=1
; oplot,wlgridq,nrl2(*,arr)-quiet-nrl2unc(*,arr),color=1
oplot,wlgridq,nrl2(*,arr)-quiet,color=19
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.0002
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.05
; xyouts,x1,y1,tt,charsize=cs*1.1,color=1
;
!p.noerase=1
!p.region=[0.05,.1,0.95,.5]
!y.range=[0,200]
tt=' Uncertainty in NRLSSI2 Model Energy Change!c from Quiet Sun: '
tt=tt+string(yarr,'(i4)')+string(marr,'(i2)')+string(darr,'(i2)')
plot_oi,wlgridq,nrl2unc(*,arr)/(nrl2(*,arr)-quiet)*100.,/nodata,xticklen=0.05,$
   xtitle='Wavelength (nm)',ytitle='Percent',title=tt
oplot,wlgridq,nrl2unc(*,arr)/abs(nrl2(*,arr)-quiet)*100.,color=20
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.0002
y1=!y.range(0)+(!y.range(1)-!y.range(0))*1.05
; xyouts,x1,y1,tt,charsize=cs*1.1,color=1
;
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
plot411:
;
; plot spctral irradiance time series at the four wavelengths in Table 6 -
; with time-dependent uncertainties - at the prntwl arrays
;
cs=1.2
!p.charsize=cs
; plot time series in selected wavelength bands - solar cycle time scales
!x.range=[2003.6,2004]
!x.style=9
!y.style=9
xtn=replicate('  ',10)
!p.noerase=0
;;; make plots
for k=0,3 do begin
rr=where(wlgridq eq prntwl(k))
yy=nrl2(rr,*)
yyunc=nrl2unc(rr,*)
r1=yy gt 0
r2=dy/365.25+2003 ge !x.range(0)
r3=dy/365.25+2003 le !x.range(1)
r=where(r1*r2*r3)
if(k eq 0) then begin
!p.region=[0.05,.68,.98,.98]
!y.range=[min(yy(r))*0.92,max(yy(r))*1.08]
endif
if(k eq 1) then begin
!p.noerase=1
!p.region=[0.05,.45,.98,.75]
!y.range=[min(yy(r))*0.989,max(yy(r))*1.011]
endif
if(k eq 2) then begin
!p.region=[0.05,.23,.98,.53]
!y.range=[min(yy(r))*0.998,max(yy(r))*1.002]
endif
if(k eq 3) then begin
!p.region=[0.05,0,.98,.3]
!y.range=[min(yy(r))*0.999,max(yy(r))*1.001]
endif
;
xtn=replicate('  ',10)
if(K eq 2) then yt='              W m!u-2!n'
if(k ne 2) then yt='   '
yt='W m!u-2!n'
if(k le 2) then plot,dy(r)/365.25+2003,yy(r),/nodata,ytitle=yt,$
         xticklen=0.05,xtickname=xtn
if(k eq 3) then plot,dy(r)/365.25+2003,yy(r),/nodata,ytitle=yt,$
         xticklen=0.05
r=where(r1*r2*r3*r4,cnt)
xxx=[dy(r(0))/365.25+2003,dy(r)/365.25+2003,reverse(dy(r)/365.25+2003)]
xxx=[xxx,dy(r(0))/365.25+2003]
yyy=[yy(r(0))+yyunc(r(0)),yy(r)+yyunc(r)]
yyy=[yyy,reverse(yy(r)-yyunc(r))]
yyy=[yyy,yy(r(0))-yyunc(r(0))]
polyfill,xxx,yyy,color=8
oplot,dy(r)/365.25+2003,yy(r),color=19
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.05
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.95
sw1='NRLSSI2 at '+string(prntwl(k),'(f5.1)')
if(prntwl(k) ge 1000.) then sw1='NRLSSI2 at '+string(prntwl(k),'(f6.1)')
xyouts,x1,y1,sw1+' nm'
;
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.68
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.73
; xyouts,x1,y1,'NRLSSI2',color=14
;
endfor
goto,cont100
;-----------------------------------------------------------------------
plot412:
; compare different NRLSSI2 reference spectra - activity min, max, moderate and quiet
;
cs=1.3
!p.charsize=cs
;
; plot TSI for context
!p.noerase=0
!p.region=[0,.55,1,1]
!x.range=[1996,2015]
!y.range=[1356,1364]
yt='W m!u-2!n'
r=where(rctiall(*,0,0) gt 0)
plot,dyall(r)/365.25+1978,rctiall(r,0,0),/nodata,$
           xticklen=0.05,ytitle=yt,title='Total Solar Irradiance'
oplot,dyall(r)/365.25+1978,rctiall(r,0,0)
;
!p.noerase=1
!x.range=[100,100000]
!y.range=[1.e-11,0.05]
!p.region=[0,0.1,1,.55]
tt='Total Solar Irradiance'
tt='Spectral Irradiance Increase from Quiet Sun'
plot_oo,wlgridq,quiet,/nodata,title=tt,$
      xticklen=0.05,xtitle='Wavelength (nm)',ytitle='W m!u-2!n nm!u-1!n'
;
oplot,wlgridq,nrl2refspec(*,0,0)-quiet,color=19
oplot,wlgridq,nrl2refspec(*,1,0)-quiet,color=14
oplot,wlgridq,nrl2refspec(*,2,0)-quiet,color=16
;
; add labels
x1=!x.range(0)+(!x.range(1)-!x.range(0))*0.08
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.03
xyouts,x1,y1,reftit(0),color=19,charsize=cs*1.2
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.004
xyouts,x1,y1,reftit(1),color=14,charsize=cs*1.2
y1=!y.range(0)+(!y.range(1)-!y.range(0))*0.0009
xyouts,x1,y1,reftit(2),color=16,charsize=cs*1.2
;
goto,cont100
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
cont100:
if(dev eq 0) then device,/close_file
!x.range=0
!y.range=0
!p.region=0
!p.noerase=0
!x.style=1
!y.style=1
end
