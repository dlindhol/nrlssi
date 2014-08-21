function bin_ssi, model_params, spectral_bins, ssi

lambda     = model_params.lambda
nband      = spectral_bins.nband
bandcenter = spectral_bins.bandcenter
bandwidth  = spectral_bins.bandwidth
nrl2       = ssi.nrl2


nrl2bin = dblarr(nband) ; this is the binned wavelength grid   

; now sum spectrum into wavelength bands
for m=0,nband-1 do begin
wav1=bandcenter(m)-bandwidth(m)/2.
wav2=bandcenter(m)+bandwidth(m)/2.
rwav=where((lambda ge wav1) and (lambda lt wav2),cntwav)
nrl2bin(m)=total(nrl2(rwav))/(wav2-wav1)
; end of cycling thru wavelength bands
endfor
nrl2binsum=total(nrl2bin*bandwidth)

  ssi_bin = {nrl2_ssi_bin,    $
  nrl2bin:     nrl2bin,    $
  nrl2binsum:  nrl2binsum  $
  }
  
  return,ssi_bin
end