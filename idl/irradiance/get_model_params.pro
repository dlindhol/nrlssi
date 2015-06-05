;@***h* SOLAR_IRRADIANCE_FCDR/get_model_params.pro
;
; NAME
;   get_model_params
;
; PURPOSE
;   The get_model_params.pro function is called from process_irradiance.pro.  It extracts coefficients for 
;   faculae and sunspots that are pre-specified (determined using multiple linear regression) for the algorithm. The
;   coefficients for reproducing TSI are spectrally integrated, while those for reproducing SSI are wavelength
;   dependent. The purpose of the coefficients is to convert the facular brightening and sunspot darkening indices to their 
;   equivalenet irradiance change, in energy units, depending on the wavelength-dependent strengths of the facular and sunspot influences
;   at that time.

; DESCRIPTION
;   The get_model_params.pro function restores pre-specified coefficients from an IDL save file and passes them in a structure, 'params',
;   to the main routine.
;       
; INPUTS
;   file - an IDL save file containing the NRLTSI2 and NRLSSI2 model coefficients used to adjust the baseline, quiet Sun irradiance,
;   either increasing or decreasing it depending on the wavelength-dependent strengths of the facular, F, and sunspot, S, 
;   influences at that time.
;
; OUTPUTS
;   params - a structure containing the following variables:
;     simver    = The data version of SORCE SIM used to derive model coefficients
;     tquiet    = specified, invariant, quiet Sun reference value for total solar irradiance
;     iquiet    = specified, invariant, quiet Sun reference value for solar spectral irradiance. Function of wavelength, k.
;     lambda    = wavelength (k); consists of 1 nm bins centered at the bin midpoint from 115.5 nm to 99999.5 nm
;     acoef     = the 'a' multiple regression coefficient for facular brightening 
;     bfaccoef  = coefficient used to determine spectrally integrated facular brigthening adjustment to baseline, quiet Sun, tquiet. 
;     bspotcoef = coefficient used to determine spectrally integrated sunspot darkening adjustment to baseline, quiet Sun, tquiet.
;     ccoef     = coefficient for wavelength-dependent facular brightening 
;     dfaccoef  = coefficient used to determine wavelength-dependent (k) facular brightening adjustment to baseline, quiet Sun, iquiet. 
;     efaccoef  = small, but nonzero, adjustment factor that accounts for the imperfect nature of the facular brightening index. Used to ensure
;                 the integral of the time and spectrally-dependent spectral irradiance variations from faculae equal the time-dependent total
;                 irradiance variations from faculae.
;     dspotcoef = coefficient used to determine wavelength-dependent (k) sunspot darkening adjustment to baseline, quiet Sun, iquiet.
;     espotcoef = small, but nonzero, adjustment factor that accounts for the imperfect nature of the sunspot darkening index. Used to ensure
;                 the integral of the time and spectrally-dependent spectral irradiance variations from sunspots equal the time-dependent total
;                 irradiance variations from sunspots.
;     mgquiet   = specified, invariant, reference value for the Mg II index for the quiet sun. Nonzero value. By contrast, the reference value 
;                 for sunspot darkening at quiet sun conditions is zero.
;     ccoefunc  = the absolute uncertainty in 'ccoef'
;     mgu       = the relative uncertainty in change in facular brightening from its minimum value, mgquiet.
;     sbu       = the relative uncertainty in change in sunspot darkening from its minimum value, '0'. 
;     tsisigma  = the 1-sigma absolute uncertainty estimates for the coefficients returned in the multiple linear
;                  regression, so also accounts for autocorrelation in the time series.

;     faccfunc  = the relative uncertainty estimate for the coefficients of spectral facular brightening obtained from multiple linear
;                  regression of the detrended spectral observations, and detrended indices.
;     spotcfunc = the relative uncertainty estimate for the coefficients of spectral sunspot darkening obtained from multiple linear
;                  regression of the detrended spectral observations, and detrended indices.
;     coeff0spot = the regression coefficient that linearly relates the sunspot darkening index to the residual energy in the sunspot darkening
;                  index
;     qsigmaspot = the absolute uncertainty in the small, but nonzero 'coeff0spot' factor  
;     coeff0fac = the regression coefficient that linearly relates the facular brightening index to the residual energy in the facular 
;                  brightening index
;     qsigmafac = the absolute uncertainty in the 'coeff0fac' factor
;     selmg     = internal QA flag (not used to compute model irradiances)
;     selfrac   = internal QA flag (not used to compute model irradiances)
;     seltim    = internal QA flag (not used to compute model irradiances)
;
; AUTHOR
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
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
;   06/04/2015 Initial Version prepared for NCDC
;
; USAGE
;   result=get_model_params(file=file)
;
;@*****
function get_model_params, file=file

  if n_elements(file) eq 0 then file = 'data/NRL2_model_parameters_v02r00.sav'
  restore,file

  params = {model_params,  $
    simver:        simver, $
    tquiet:        tquiet, $
    iquiet:        iquiet, $
    lambda:        lambda, $
    acoef:          acoef, $
    bfaccoef:    bfaccoef, $
    bspotcoef:  bspotcoef, $
    ccoef:          ccoef, $
    dfaccoef:    dfaccoef, $
    efaccoef:    efaccoef, $
    dspotcoef:  dspotcoef, $
    espotcoef:  espotcoef, $
    mgquiet:      mgquiet, $
    selmg:          selmg, $
    selfrac:      selfrac, $
    seltim:        seltim, $
    ccoefunc:    ccoefunc, $
    mgu:              mgu, $
    sbu:              sbu, $
    tsisigma:    tsisigma, $
    faccfunc:    faccfunc, $
    spotcfunc:  spotcfunc, $
    coeff0spot: coeff0spot,$
    qsigmaspot: qsigmaspot,$
    coeff0fac:  coeff0fac, $
    qsigmafac:   qsigmafac $
  }
  
  return, params
end
