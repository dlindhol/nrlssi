;@***h* TSI_FCDR/write_ssi_model_to_ascii.pro
; 
; NAME
;   write_ssi_model_to_ascii.pro
;
; PURPOSE
;   The write_ssi_model_to_ascii.pro function writes the Model Solar Spectral Irradiance, wavelength (midpoint and delta wavelength grid)
;   to an ascii output file. This function is called from the main routine, nrl_2_ssi.pro.
;
;
; DESCRIPTION
;   Missing values are defined as -99.0, by default.
;   This function is called from the main routine, nrl_2_ssi.pro.
;   
; INPUTS
;   yr = year
;   mn = month
;   dy = day
;   Note: yr, mn, and dy are used here to create output file name 
;   (ToDO: define by time range instead. This will require indexing spectrum by time as well).
;   spectrum = a structure containing solar spectral irradiance and wavelength (midpoint and delta wavelength grid)
;
; OUTPUTS
;    
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
;
; COPYRIGHT 
;   THIS SOFTWARE AND ITS DOCUMENTATION ARE CONSIDERED TO BE IN THE PUBLIC
;   DOMAIN AND THUS ARE AVAILABLE FOR UNRESTRICTED PUBLIC USE. THEY ARE
;   FURNISHED "AS IS." THE AUTHORS, THE UNITED STATES GOVERNMENT, ITS
;   INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO WARRANTY,
;   EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE AND
;   DOCUMENTATION FOR ANY PURPOSE. THEY ASSUME NO RESPONSIBILITY (1) FOR
;   THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL
;   SUPPORT TO USERS.
;
; REVISION HISTORY
;   06/02/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_ssi_model_to_ascii, yr, mn, dy, spectrum
;
;@***** 
function write_ssi_model_to_ascii, yr, mn, dy, spectrum


  specwl = spectrum.wavelength
  nband = n_elements(specwl[*,0])
  
  specirrad = spectrum.irradiance
  totspec = total(specirrad*specwl(*,1))/1000. ;'Watts per m2'
  
  
  close,1
  flnout='NRLSSI_spectrum_'+string(yr,'(i4)')
  if(mn lt 10) then flnout=flnout+'0'+string(mn,'(i1)')
  if(mn ge 10) then flnout=flnout+string(mn,'(i2)')
  if(dy lt 10) then flnout=flnout+'0'+string(dy,'(i1)')+'.txt'
  if(dy ge 10) then flnout=flnout+string(dy,'(i2)')+'.txt'
  openw,1,flnout
  printf,1,systime(0)
  txt='Absolute irradiance scale is PMOD (multiply by 0.9965 for TIM scale)' 
  ;**this will go away. Initially began with established tsi, but when you add you it doesn't match, so Judith originally scaled to PMOD to 
  ;1365 and TIM is 1361. We will use WHI reference spectrum, do calcs, then integrate to match TIM quiet sun value.
  ;ToDo:Add Absolute irradiance scale is TIM with quiet Sun of 1361.
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
  ;help,specwl
  ;stop
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
