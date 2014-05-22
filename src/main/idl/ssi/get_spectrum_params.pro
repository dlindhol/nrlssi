function get_spectrum_params

  ; read in the NRLSSI spectral parameter arrays needed to calculate irradiance
  ; these parameters are only used for wavelengths longer than 400 nm
  close,1
  openr,1,'data/NRLSSI_spectrum_parameters.txt'
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
  
  params = {spectrum_params, $
    excess0: excess0, $
    adjspot: adjspot, $
    pxqs:    pxqs,    $
    pxmin:   pxmin,   $
    pxmax:   pxmax,   $
    psmin:   psmin,   $
    psmax:   psmax,   $
    wl:      transpose(specdat(0,*)), $
    irrqs:   double(transpose(specdat(1,*))), $
    ssy:     double(transpose(specdat(2,*))), $
    fac:     double(transpose(specdat(3,*)))  $
  }
  
  return, params
end
