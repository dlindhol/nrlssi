; nrl2.pro
;
; pro to calculate nrltsi2 and nrlssi2 using saved parameters
;
; test day is 1 Jan 2003
day=1
month=1
year=2003
sb=79.76			; from NOAA WDC sunspot regions
mg=0.1612		; on GOME scale
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; restore model parameters
;
modver='18Aug14'
;fn='~/models/NRLSSI2/NRL2_model_parameters_'+modver+'.sav'
fn='~/git/nrlssi/data/judith_2014_08_21/NRL2_model_parameters_'+modver+'.sav'
; in this save file are the following...
; tquiet
; iquiet
; lambda
; acoef
; bfaccoef
; bspotcoef
; ccoef
; dfaccoef
; efaccoef
; dspotcoef
; espotcoef
; mgquiet
;
restore,filename=fn
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; set up wavelength bands for summing 1 nm spectrum
; the wavelength grid is as follows:
; 1 nm from 115 to 750
; 5 nm from 750 to 5000
; 10 nm from 5000 to 10000
; 50 nm from 10000 to 100000

nband1=750-115
nband2=(5000-750)/5
nband3=(10000-5000)/10
nband4=(100000-10000)/50
nband=nband1+nband2+nband3+nband4
bandcenter=fltarr(nband)			; midpint wavelength of band 
bandwidth=fltarr(nband)				; delta wavelength band
;
; set up the wavelength bins
for m=0,nband1-1 do begin
wav1=115.+m
wav2=wav1+1.
bandcenter(m)=(wav1+wav2)/2.
bandwidth(m)=wav2-wav1
endfor
for m=0,nband2-1 do begin
wav1=750.+m*5.
wav2=wav1+5.
bandcenter(nband1+m)=(wav1+wav2)/2.
bandwidth(nband1+m)=wav2-wav1
endfor
for m=0,nband3-1 do begin
wav1=5000.+m*10.
wav2=wav1+10.
bandcenter(nband1+nband2+m)=(wav1+wav2)/2.
bandwidth(nband1+nband2+m)=wav2-wav1
endfor
for m=0,nband4-1 do begin
wav1=10000.+m*50.
wav2=wav1+50.
bandcenter(nband1+nband2+nband3+m)=(wav1+wav2)/2.
bandwidth(nband1+nband2+nband3+m)=wav2-wav1
endfor
;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
calcnrl2:
;
; calculate nrltsi2 and nrlssi2 models for given sb and mg
;
;---------- total irradiance
totirrad=tquiet+acoef+bfaccoef*(mg-mgquiet)+bspotcoef*sb
totfac=acoef+bfaccoef*(mg-mgquiet)	; facular compoment - for checking with SSI
totspot=bspotcoef*sb		; spot component - for checking with SSI
;
;-------------spectral irradiance - 
; calculate spectrum on 1 nm grid then sum into bins
nlambda=n_elements(lambda)			; this is the 1 nm grid
nrl2=dblarr(nlambda)
nrl2bin=dblarr(nband)			; this is the binned wavelength grid
;
; facular component
deltati=poly(mg-mgquiet,efaccoef)	; this make spectrum match total
deltamg=deltati/bfaccoef
dfac=(mg-mgquiet+deltamg)*dfaccoef
; spot component
deltati=poly(sb,espotcoef)		; this make spectrum match total
deltasb=deltati/bspotcoef
dspot=(sb+deltasb)*dspotcoef
nrl2=iquiet+dfac+dspot+ccoef
dfactot=total(dfac)
dspottot=total(dspot)
nrl2tot=total(nrl2)
;
; now sum spectrum into wavelength bands
for m=0,nband-1 do begin
wav1=bandcenter(m)-bandwidth(m)/2.
wav2=bandcenter(m)+bandwidth(m)/2.
rwav=where((lambda ge wav1) and (lambda lt wav2),cntwav)
nrl2bin(m)=total(nrl2(rwav))/(wav2-wav1)
; end of cycling thru wavelength bands
endfor
nrl2binsum=total(nrl2bin*bandwidth)
;
print,systime(0),mg,sb,totirrad,nrl2tot,nrl2binsum
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
