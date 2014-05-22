function write_spectrum, yr, mn, dy, spectrum


  specwl = spectrum.wavelength
  nband = n_elements(specwl[*,0])
  
  specirrad = spectrum.irradiance
  totspec = total(specirrad*specwl(*,1))/1000.
  
  
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
  
  ;TODO: return status
  return, 0
end
