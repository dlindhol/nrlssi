;@***h* TSI_FCDR/get_uv_spectrum_params.pro
; 
; NAME
;   get_uv_spectrum_params.pro
;
; PURPOSE
;   The get_uv_spectrum_params.pro function extracts a structure of SSI model parameters 
;   specific to the NRLSSI-2 model.
;
; DESCRIPTION
;   This routine returns a structure containing SSI model spectral parameters to the main routine, calc_nrlssi.pro.
;   The spectral parameters, for wavelengths spanning 115 nm to  425 nm are contained in the file 'MOD4_SOL_V0009_w1.sav'.
;   The spectral parameters are used to compute the spectral residual intensity contrast of sunspot blocking (reduction in irradiance) 
;   and facular brightening (increase in irradiance) relative to the assumed quiet Sun irradiance, as a function of wavelength for
;   wavelengths below 400 nm.
;   
; INPUTS
;   None
;
; OUTPUTS
;   structure ('params') containing SSI model spectral parameters:
;   psuvfactor =
;   uvwl =
;   uvfregressd = 
;   refuvf = 
;   refps =  
;   refpx = 
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
;   get_uv_spectrum_params
;
;@***** 
function get_uv_spectrum_params
  ;  retrieve the UARS UV model parameters
  ;
  psuvfactor=1.31284
  ; this converts from bolometric to UV sunspot blocking
  csecft=double([-1912.,7508.])
  ; this converts from MgSEC scale to FT scale
  ;
  ; restore model coefficients for calcuating UV spectrum from save files
  fn='data/MOD4_SOL_V0009_w1.sav'
  restore,filename=fn
  ;
  uvwl=wl   ; rename the UV wavelength grid to avoid confusion
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
;
; the reconstructed irradiances are determined from the
; detrended multiple regression analysis ...
;
; the UV spectrum reconsructed for given px and ps inpouts is..
; rcuv=dblarr(311)
; ee=1+uvfregressd(0,wl)+uvfregressd(1,wl)*(px-refpx)/refpx+$
;                 uvfregressd(2,wl)*(psuv-refps)/refps
; rcuv(wl)=refuvf(wl)*ee/100. (units = mw m-2 nm-1?)
;
;NOTE: psuv=ps*psuvfactor
;
; Note that two different arrays are calculated for the uv quiet sun 
; - rcuvmin - nominally the spectrum during solar minim (which is typically slightly larger than the true quiet sun spectrum) and 
; rcuvqs - which would be the ”quietest”spectrum.

  params = {uv_model_params, $
    psuvfactor:  psuvfactor,  $
    csecft:      csecft,      $
    uvwl:        wl,          $
    uvfregressd: uvfregressd, $
    refuvf:      refuvf,      $
    refps:       refps,       $
    refpx:       refpx        $
  }
  
  return, params
  
end
