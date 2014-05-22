function compute_spectrum, px, ps, spectrum_params, uv_params
  ; px and ps are the corresponding input facular brightening and sunspot darking proxies

  wl      = spectrum_params.wl
  irrqs   = spectrum_params.irrqs
  ssy     = spectrum_params.ssy
  fac     = spectrum_params.fac
  pxmin   = spectrum_params.pxmin
  psmin   = spectrum_params.psmin
  pxqs    = spectrum_params.pxqs
  excess0 = spectrum_params.excess0
  adjspot = spectrum_params.adjspot
  
  psuvfactor  = uv_params.psuvfactor
  csecft      = uv_params.csecft
  uvwl        = uv_params.uvwl
  uvfregressd = uv_params.uvfregressd
  refuvf      = uv_params.refuvf
  refps       = uv_params.refps
  refpx       = uv_params.refpx
  
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

  
  spectrum = {spectrum,   $
    wavelength: specwl,   $
    irradiance: specirrad $
  }
  
  return, spectrum
end
