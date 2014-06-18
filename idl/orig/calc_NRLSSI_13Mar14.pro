; calc_NRLSSI_13Mar14.pro
;
;------------------------------------------------------------------
; input data needed: dy, mn, yr, px and ps 
; dy, mn, yr are day, month, year for the spectrum
; px and ps are the corresponding input facular brightening and sunspot darking 
; proxies
;
; example 1 Jan 2003
dy=1
mn=1
yr=2003
px=0.2747
ps=79.76
;
; for checking calculations quickly ...spectrum calculated using actual model 
; (on 3 Feb 2013) with these px and ps inputs is in the file 
; NRLSSI_1Jan2003_13Feb13.txt
;
; the TSI, detemined independently, and the ps and px inputs, from 2000
; to 2012 are in the file NRLTSI_2000_2012d_13Feb13.txt
;
; using the px and ps values input to this current program 
; shold produce the spectral irradiance in the file 
; NRLSSI_spectra_2000_2012d_13Feb13.txt, from which the 
; spectrum on 1 Jan 2003 (NRLSSI_1Jan2003_13Feb13.txt) was extracted
;
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; read in the NRLSSI spectral parameter arrays needed to calculate irradiance
; these parameters are only used for wavelengths longer than 400 nm
close,1
openr,1,'NRLSSI_spectrum_parameters.txt'
dumi='   '
for k=1,9 do begin
readf,1,dumi
if(k eq 7) then excess0=float(strmid(dumi,10,12))
if(k eq 7) then adjspot=float(strmid(dumi,36,12))
if(k eq 8) then pxqs=float(strmid(dumi,8,12))
endfor
;
;------------------------------------------------------------------
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
;-------------------------------------------------------------------------
;  retrieve the UARS UV model parameters
;
psuvfactor=1.31284
; this converts from bolometric to UV sunspot blocking
csecft=double([-1912.,7508.])             
; this converts from MgSEC scale to FT scale
;
; restore model coefficients for calcuating UV spectrum from save files
fn='MOD4_SOL_V0009_w1.sav'
restore,filename=fn
;
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
;NOTE: psuv=ps*psuvfactor
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calcit:
;
;;;;;; 
; for a given value of px and ps, at some given time (dy, mn, yr), determine
; the spectral changes at a particular wavelength (wl) as follows
; deltaps(wl)=irrqs(wl)*ps/1.e6/excess0*(1-ssy(wl))*adjspot
; deltapx(wl)=(px-px0)*fac(wl)
; Flux(wl)=irrqs(wl)-deltaps(wl)+deltapx(wl)
;
; the wavelength grid is as follows:
; 1 nm from 120 to 750
; 5 nm from 750 to 5000
; 10 nm from 5000 to 10000
; 50 nm from 10000 to 100000

nband1=750-120
nband2=(5000-750)/5
nband3=(10000-5000)/10
nband4=(100000-10000)/50
nband=nband1+nband2+nband3+nband4
specqs=dblarr(nband)                   ;solar cycle minimum -quiet sun- spectrum 
specwl=fltarr(nband,2)                  ;midpint wavelength of band 
;                                        and delta wavelength band
; set up the wavelength bins
for m=0,nband1-1 do begin
wav1=120.+m
wav2=wav1+1.
specwl(m,0)=(wav1+wav2)/2.
specwl(m,1)=wav2-wav1
endfor
for m=0,nband2-1 do begin
wav1=750.+m*5.
wav2=wav1+5.
specwl(nband1+m,0)=(wav1+wav2)/2.
specwl(nband1+m,1)=wav2-wav1
endfor
for m=0,nband3-1 do begin
wav1=5000.+m*10.
wav2=wav1+10.
specwl(nband1+nband2+m,0)=(wav1+wav2)/2.
specwl(nband1+nband2+m,1)=wav2-wav1
endfor
for m=0,nband4-1 do begin
wav1=10000.+m*50.
wav2=wav1+50.
specwl(nband1+nband2+nband3+m,0)=(wav1+wav2)/2.
specwl(nband1+nband2+nband3+m,1)=wav2-wav1
endfor
;
; set the wl for the vis/ir spectrum
wl=transpose(specdat(0,*))
irrqs=double(transpose(specdat(1,*)))
ssy=double(transpose(specdat(2,*)))
fac=double(transpose(specdat(3,*)))
;
;------------------------------------------------------------------
; first establish the solar cycle minimum spectrum in the bands
; calculate the UV minimum spectrum- with sunspot blocking zero
; NOTE: this should match irrqs in the region 200-400 nm since both
; are based on UARS detrended SOLSTICE data
;
rcuvmin=dblarr(311)
rcuvqs=dblarr(311)
;
for k=0,310 do begin
ee0=1+uvfregressd(0,k)+uvfregressd(1,k)*(pxmin-refpx)/refpx+$
                 uvfregressd(2,k)*(psmin*psuvfactor-refps)/refps
rcuvmin(k)=refuvf(k)*ee0*10.
ee0=1+uvfregressd(0,k)+uvfregressd(1,k)*(pxqs-refpx)/refpx+$
                 uvfregressd(2,k)*(0.-refps)/refps
rcuvqs(k)=refuvf(k)*ee0*10.
endfor
;
; NOTE: this value of rcuvmin & rcuvqs determined directly from the UARS data
; has been scaled down in calc_px_ps_spec_var.pro to that the total of
; the entire spectrum matches TSI - the irrqs values reflect the scaled
; down values so need to normalize rcuvqs to the corresponding values in
; irrqs - SO... need to adjust refuv by the ratio of rcuvqs and
; irrqs 
; make an array of scale factors for this purpose
uvscl=fltarr(311)+1
uvscl(84:285)=irrqs(0:201)/rcuvqs(84:285)
r=where(uvscl ne 1)
av=total(uvscl(r))/n_elements(r)
r=where(uvscl eq 1)
uvscl(r)=av
;
; now calculate qs on the wavelength bins
for m=0,nband-1 do begin
wav1=specwl(m,0)-specwl(m,1)/2.
wav2=specwl(m,0)+specwl(m,1)/2.
;
; only use rcuvqs for wl < 200 nm 
; but scaling has small effect at these wl
if(wav2 le 200.) then begin
ruvwl=where((uvwl ge wav1) and (uvwl le wav2))
specqs(m)=total(rcuvqs(ruvwl))/(wav2-wav1)
endif
;
; use irrqs for wl > 200 nm - since this has been scaled to match TSI
if(wav1 ge 200.) then begin
rwav=where((wl ge wav1) and (wl le wav2))
specqs(m)=total(irrqs(rwav))/(wav2-wav1)
endif
;
endfor
;
;--------------------------------------------------------------------
calcspec:
;
; for a given value of px and ps determine
; the spectral changes on the wl grid as follows
; deltaps(wl)=irrqs(wl)*ps/1.e6/excess0*(1-ssy(wl))*adjspot
; deltapx(wl)=(px-pxqs)*fac(wl)
; Flux(wl)=irrqs(wl)-deltaps(wl)+deltapx(wl)
;
specirrad=dblarr(nband)-99	
; use specqs=dblarr(nband) calculated above for monthly spectra	
; use specwl=fltarr(nband,2) calculated above for monthly spectra	
;
; calculate the UV spectrum for (valid) input px and ps values
; use px on MgSEC scale
;
rcuv=dblarr(311)
for k=0,310 do begin

ee=1+uvfregressd(0,k)+uvfregressd(1,k)*(px-refpx)/refpx+$
                 uvfregressd(2,k)*(ps*psuvfactor-refps)/refps
rcuv(k)=refuvf(k)*ee*10.*uvscl(k)
endfor
;
; cycle thru the wavelength bins
for m=0,nband-1 do begin
wav1=specwl(m,0)-specwl(m,1)/2.	
wav2=specwl(m,0)+specwl(m,1)/2.
;
; the following uses the UARS UV modelling parameters
if(wav2 le 400.) then begin
ruvwl=where((uvwl ge wav1) and (uvwl le wav2))
specirrad(m)=total(rcuv(ruvwl))/(wav2-wav1)
; note - converted to same units as VIS/IR spectrum
endif
;
; the following uses Yvonne Unruh's modelling parameters ...
; the px values are on the ft scale - so convert using csecft
;
if(wav1 ge 400.) then begin
rwav=where((wl ge wav1) and (wl le wav2))
; determine the associated px and ps irradiance components on
; the selected wavelength subsets
dps=irrqs(rwav)*ps/1.e6/excess0*(1-ssy(rwav))*adjspot
dpx=(poly(px,csecft)-poly(pxqs,csecft))*fac(rwav)
specirrad(m)=total(irrqs(rwav)-dps+dpx)/(wav2-wav1)
endif
;
; end of cycling thru wl channels 
endfor
;
;---------------------------------------------------
; now add up spectrum to determine the total irradaince - for checking 

totspec=total(specirrad*specwl(*,1))/1000.
print,yr,mn,dy,'Total Irradiance from Sigma(SSI) is ',totspec
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
writeit:
;
close,1
flnout='NRLSSI_spectrum_'+string(yr,'(i4)')
if(mn lt 10) then flnout=flnout+'0'+string(mn,'(i1)')
if(mn ge 10) then flnout=flnout+string(mn,'(i2)')
if(dy lt 10) then flnout=flnout+'0'+string(dy,'(i1)')+'.txt'
if(dy ge 10) then flnout=flnout+string(dy,'(i2)')+'.txt'
openw,1,flnout
printf,1,systime(0)
txt='Absolute irradiance scale is PMOD (multiply by 0.9965 for TIM scale)'
printf,1,txt
printf,1,$
  'Spectral irradiance on following wavelength (nm) grid centers'
for m=0,(nband-1)/5. do begin
a1=m*5
a2=a1+4
fmt='(5F14.2)'
; print,m,a1,a2
print,specwl(a1:a2,0)
printf,1,format=fmt,specwl(a1:a2,0)
endfor
printf,1,'with the following wavelength bands (nm) centered on above wls'
for m=0,(nband-1)/5. do begin
a1=m*5
a2=a1+4
fmt='(5E14.3)'
printf,1,format=fmt,specwl(a1:a2,1)
endfor
;
printf,1,'Spectral irradiance (mW/m2/nm) for ',yr,mn,dy,' TSI=',$
       totspec,' (w/m2)'
for m=0,(nband-1)/5. do begin
a1=m*5
a2=a1+4
fmt='(5E14.6)'
printf,1,format=fmt,specirrad(a1:a2)
endfor
close,1
;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
cont100:
end
