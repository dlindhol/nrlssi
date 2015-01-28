; nrl2_27Jan15.pro
;
; pro to calculate nrltsi2 and nrlssi2 using saved parameters
;
; test day is 1 Jan 2003
day=1
month=1
year=2003
sb=79.76			; from NOAA WDC sunspot regions
mg=0.1612		; on GOME scale
;
;;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; obtain datasets and model parameters
modver='26Jan15'
simver='21'
fn='~/models/NRLSSI2/trans_2015/NRL2_model_parameters_AIndC_'+simver+'_'+modver+'.sav'
; in this save file are the following...
; simver
; tquiet
; iquiet
; lambda
; mgquiet
; mgu
; modver
; selmg
; selfrac
; simver
; sbu
; tsisigma
;
; acoef
; bfaccoef
; bspotcoef
; ccoef
; ccoefunc
; coeff0fac
; coeff0spot
; dfaccoef
; dspotcoef
; efaccoef
; espotcoef
; faccfunc
;
; spotcfunc
; qsigmafac
; qsigmaspot
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
; calculate nrl2 model, total irradiance from model
;
;---------- total irradiance
totirrad=tquiet+acoef+bfaccoef*(mg-mgquiet)+bspotcoef*sb
totfac=acoef+bfaccoef*(mg-mgquiet)  	; facular component - for checking with SSI
totspot=bspotcoef*sb		; spot component - for checking with SSI
;
;------- TSI time-dependent uncertainties
totfacunc=sqrt((tsisigma(1)/bfaccoef)^2+mgu^2.)
totspotunc=sqrt((tsisigma(2)/bspotcoef)^2+sbu^2.)
; total uncertainty
totirradunc=tsisigma(0)+abs(totfac)*totfacunc+$
                  abs(totspot)*totspotunc  
;
;-------------spectral irradiance -
; calculate spectrum on 1 nm grid then sum into bins
nlambda=n_elements(lambda)			; this is the 1 nm grid
nrl2=dblarr(nlambda)
nrl2bin=dblarr(nband)	; this is irradiance on the binned wavelength grid
nrl2binunc=dblarr(nband)
;
; facular component
deltati=poly(mg-mgquiet,efaccoef)
deltamg=deltati/bfaccoef
dfac=(mg-mgquiet+deltamg)*dfaccoef
; spot component
deltati=poly(sb,espotcoef)
deltasb=deltati/bspotcoef
dspot=(sb+deltasb)*dspotcoef
nrl2=iquiet+dfac+dspot+ccoef
dfactot=total(dfac)
dspottot=total(dspot)
nrl2tot=total(nrl2)
;
; calculate uncertainties
facunc1=abs(dfaccoef*(mg-mgquiet))*sqrt(faccfunc^2.+mgu^2.)
spotunc1=abs(dspotcoef*sb)*sqrt(spotcfunc^2.+sbu^2.)
uu2=faccfunc^2.+(qsigmafac(1)/coeff0fac(1))^2.+$
       (tsisigma(1)/bfaccoef)^2.+mgu^2.
facunc2=abs(dfaccoef*deltamg)*sqrt(uu2)  
uu2=spotcfunc^2.+(qsigmaspot(1)/coeff0spot(1))^2.+$
       (tsisigma(2)/bspotcoef)^2.+sbu^2.
spotunc2=abs(dspotcoef*deltasb)*sqrt(uu2)   
nrl2unc=ccoefunc+facunc1+facunc2+spotunc1+spotunc2
;
; now sum spectrum into wavelength bands and determine uncertainties
for m=0,nband-1 do begin
wav1=bandcenter(m)-bandwidth(m)/2.
wav2=bandcenter(m)+bandwidth(m)/2.
rwav=where((lambda ge wav1) and (lambda lt wav2),cntwav)
nrl2bin(m)=total(nrl2(rwav))/(wav2-wav1)
; also determine the weighted uncertainty
nrl2binunc(m)=total(nrl2(rwav)*nrl2unc(rwav))/total(nrl2(rwav))
; end of cycling thru wavelength bands
endfor
;
nrl2binsum=total(nrl2bin*bandwidth2)
; end of cycling through days
print,systime,mg,sb,totirrad,nrl2tot,nrl2binsum
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

