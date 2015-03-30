;@***h* SOLAR_IRRADIANCE_FCDR/get_model_params.pro
;
; NAME
;   get_model_params.pro
;
; PURPOSE
;   The get_model_params.pro function is called from the driver routine, nrl2_to_irradiance.pro.  It extracts coefficients for 
;   faculae and sunspots that are pre-specified (determined using multiple linear regression) and supplied with the algorithm. The
;   coefficients for reproducing TSI are bolometric (i.e. spectrally integrated), while those for reproducing SSI are wavelength
;   dependent. The purpose of the coefficients is to convert the facular brightening and sunspot darkening indices to their 
;   equivalenet irradiance change, in energy units, depending on the wavelength-dependent strengths of the facular and sunspot influences
;   at that time.

; DESCRIPTION
;   The get_model_params.pro function restores pre-specified coefficients from an IDL save file and passes them in a structure, 'params',
;   to the main driver routine.
;       
; INPUTS
;   infile - an IDL save file containing the NRLTSI2 and NRLSSI2 model coefficients used to adjust the baseline, quiet Sun irradiance,
;   either increasing or decreasing it depending on the wavelength-dependent strengths of the facular, F, and sunspot, S, 
;   influences at that time.
;
; OUTPUTS
;   params - a structure containing the following variables:
;     tquiet    = specified, invariant, quiet Sun reference value for total solar irradiance
;     iquiet    = specified, invariant, quiet Sun reference value for solar spectral irradiance. Function of wavelength, k.
;     lambda    = wavelength (k); consists of 1 nm bins centered at the bin midpoint from 115.5 nm to 99999.5 nm
;     ACOEF     = COEFFICIENT FOR BOLOMETRIC FACULAR BRIGHTENING; check with Judith (it's nonzero.)
;     bfaccoef  = coefficient used to determine bolometric facular brigthening adjustment to baseline, quiet Sun, tquiet. 
;     bspotcoef = coefficient used to determine bolometric sunspot darkening adjustment to baseline, quiet Sun, tquiet.
;     ccoef     = COEFFICIENT FOR WAVELENGTH-DEPENDENT FACULAR BRIGHTENING; check with Judith (it's nonzero.)
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
;    selmg
;    selfrac:      selfrac, $
;    seltim:        seltim, $
;    ccoefunc:    ccoefunc, $
;    mgu:              mgu, $
;    sbu:              sbu, $
;    tsisigma:    tsisigma, $
;    faccfunc:    faccfunc, $
;    spotcfunc:  spotcfunc, $
;    coeff0spot: coeff0spot,$
;    qsigmaspot: qsigmaspot,$
;    coeff0fac:  coeff0fac, $
;    qsigmafac:   qsigmafac $
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
;   01/15/2015 Initial Version prepared for NCDC
;
; USAGE
;   get_model_params,infile
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
