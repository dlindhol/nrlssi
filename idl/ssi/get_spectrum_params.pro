;@***h* TSI_FCDR/get_spectrum_params.pro
; 
; NAME
;   get_spectrum_params.pro
;
; PURPOSE
;   The get_spectrum_params.pro function extracts a structure of SSI model parameters 
;   specific to the NRLSSI-2 model.
;
; DESCRIPTION
;   This routine returns a structure containing SSI model spectral parameters to the main routine, calc_nrlssi.pro.
;   The spectral parameters, for wavelengths spanning 200 nm to  100000 nm are contained in the file 'NRLSSI_spectrum_parameters.txt'.
;   The spectral parameters are used to compute the spectral residual intensity contrast of sunspot blocking (reduction in irradiance, 'deltaps') 
;   and facular brightening (increase in irradiance, 'deltapx') relative to the assumed quiet Sun irradiance ('irrqs'), as a 
;   function of wavelength ('k') according to the following formulae, valid for wavelengths above 400 nm. 
;   
;   deltaps=irrqs(k)*ps/1.e6/excess0*(1-ssy(k))*adjspot 
;   deltapx(k)=(px-px0)*fac(k)
;   irrad(k)=irrqs(k)-deltaaps(k)+deltapx(k)
;
;   Variable Definitions
;   irrqs   = Adopted value of the Quiet Sun spectral irradiance (units = W m-2 nm-1)
;   k       = Wavelength (units = nm)
;   ps      = Bolometric sunspot blocking function, including the dependence of the residual sunspot intensity on sunspot area 
;             [Brandt, P. N., Stix, M., & Weinhardt, H.1994., Solar Phys., 152, 119]. Reported in millionths of a solar hemisphere (1e6 factor).
;   excess0 = The negative of the spectrum-weighted integral of the wavelength-dependent bolometric intensity sunspot contrast and equal to 0.3235 
;             (i.e. sunspot contrast is defined as a positive change in irradiance) 
;             [Allen, C. W., 1981, Astrophysical Quantities (3d ed.; London, Athlone].
;   ssy     = The sunspot contrast at a given wavelength [direct from Y. Unruh solar spectral irradiance model].  
;   adjspot = Correction factor used to make the integrated sunspot energy change match that determined separately for total solar irradiance.
;             Equal to 0.99011639.
;   deltaps = The change (in energy units) due to sunspot blocking determined directly from directly measured sunspot characteristics       
;   
;   px      = Bolometric facular brightening function, derived from the Mg II index.
;   px0     = 
;   pxqs    = Value of bolometric facular brightening function for the adopted quiet Sun, and equal to 0.26311135. It is needed
;             because there is a non-zero minimum of the Mg index during solar minimum. It is slightly less than that of pxmin. 
;             Interchangeable with px0.
;   pxmin   = Value of bolometric facular brightening function during solar minimum and equal to 0.2636038.
;   pxmax   = Value of bolometric facular brightening function during solar maximum and equal to 0.28338173.
;   psmin   = Value of bolometric sunspot blocking function during solar minimum and equal to 12.6918.
;   psmax   = Value of bolometric sunspot blocking function during solar maximum and equal to 739.522.
;   fac     = The facular intensity contrast at wavelength, 'k'. 
;   deltapx = The change in irradiance due to facular brightening. Determined from a scaling of the Mg II index (i.e. There are no direct measurements 
;             of facular areas, unlike the sunspot areas).
;   
;   irrad   = Modeled Spectral irradiance (units = W m-2 nm-1)
;   
; INPUTS
;   None
;
; OUTPUTS
;   structure ('params') containing SSI model spectral parameters:
;   excess0 = 
;   adjspot = 
;   pxqs = the value of PX, the facular index (i.e. the Mg II index), for the quiet Sun.  It is essentially, but not exactly, the minimum
;          value of PX given the Mg II index on the NOAA scale, and can be used interchangeably with PX0, the value of PX for quiet Sun conditions.
;          It is needed because there is a non-zero minimum of the Mg II index during solar minimum.
;   pxmin = 
;   pxmax = 
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
;   get_spectrum_params
;
;@***** 
function get_spectrum_params

  ; read in the NRLSSI parameter arrays needed to calculate spectral irradiance
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
;  print,'Number of VIS/IR spectral wavelengths is ',nwl
  readf,1,dumi
  specdat=dblarr(4,nwl)
  readf,1,specdat
  close,1

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
