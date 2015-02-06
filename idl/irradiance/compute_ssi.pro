;@***h* SOLAR_IRRADIANCE_FCDR/compute_ssi.pro
;
; NAME
;   compute_ssi.pro
;
; PURPOSE
;   The compute_ssi.pro procedure is a function called by the driver routine,nrl2_to_irradiance,pro,
;   to compute daily Model Solar Spectral Irradiance using multiple regression coefficients specific to 
;   the NRLSSI2 model andgiven values for the sunspot darkening function and the facular brightening function.
;
; DESCRIPTION
;   The compute_ssi.pro function calculates the Model Solar Spectral Irradiance (SSI) for a specific day, given
;   values for the sunspot darkening and the facular brightening function using a 2-component multiple regression formula.
; 
;   Variable Definitions:
;   I(k,t) it the spectral (k) and time-dependency (t) of SSI.
;   delta_I_F(k,t) is similarly described, but for SSI, and is also spectrally dependent 
;   delta_I_S(t) is similarly described, but for SSI, and is also spectrally dependent
;   I_Q is the SSI of the adopted Quiet Sun reference spectrum.
;   
;   2-Component Regression formulas: 
;   I(k,t) = I_Q + delta_I_F(t) + delta_I_S(t)
;   
;   Quantifying time and spectrally-dependent SSI (I) Irradiance variation from Faculae (F) and Sunspot (S):
;   delta_I_F(k,t) = c_F(k) + d_F(k) * [F(t) - F_Q] + e_F * [F(t) - F_Q]
;   delta_I_S(k,t) = c_S(k) + d_S(k) * [S(t) - S_Q] + e_S * [S(t) - S_Q]
;   
;   Coefficients for faculae and sunspots:
;   The c(k), and d(k) coefficients for faculae and sunspots are specified (determined using multiple linear regression) 
;   and supplied with the algorithm. These coefficients best reproduce the detrended SSI irradiance variability (removal of 81-day running mean) 
;   measured by SORCE SIM. 
;   Note, the c_F and c_S coefficient is nominally zero so that when F=F_Q and S=S_Q, then I=I_Q.
;   The additional wavelength-dependent terms in the spectral irradiance facular and sunspot components evaluated with the 
;   e coefficients provide small adjustments to ensure that 1) the numerical integral over wavelength of the solar spectral irradiance is 
;   equal to the total solar irradiance, 2) the numerical integral over wavelength of the time-dependent SSI irradiance variations from
;   faculae and sunspots is equal to the time-dependent TSI irradiance variations from the faculae and sunspots. 
;   
;   Additional explanation of coefficients used to model solar spectral irradiance: 
;   A relationship of solar spectral irradiance variability to sunspot darkening and facular brightening determined using observations of 
;   solar rotational modulation: instrumental trends are smaller over the (much) shorter rotational times scales than during the solar cycle. 
;   For each 1 nm bin, the observed spectral irradiance and the facular brightening and sunspot darkening indices are detrended by 
;   subtracting 81-day running means. Multiple linear regression is then used to determine the relationships of the detrended time series:
;   
;   I_detrend_mod(k,t) = I_mod(k,t) - I_smooth(k,t)
;                      = c(k) + d_F_detrend(k) * [F(t) - F_smooth(t)] + d_S_detrend(k) * [S(t) - S_smooth(t)]
;                      
;   Variable Definitions:
;   I_mod(k,t) = the spectral (k) and time (t) dependecies of the modeled spectral irradiance, I_mod.
;   I_smooth(k,t) = the spectral and time dependences of the smoothed (i.e. after subtracting 81-day running mean) from observed spectral irradiance.
;   F_smooth(t) = the time dependency of the smoothed (i.e. after subtracting 81-day running mean) from observed facular brightening index, F(t).
;   S_smooth(t) = as above, but for the observed sunspot darkening index, S(t).
;   
;   The range of facular variability in the detrended time series is smaller than during the solar cycle which causes the coefficients
;   of models developed from detrended time series to differ from those developed from non-detrended observations. To address this, total
;   solar irradiance observations are used to numerically determine ratios of coefficients obtained from multiple regression using direct observations,
;   with those obtained from multiple regression of detrended observations. Using a second model of TIM observations (using detrended observations) 
;   was determined and the ratios of the coefficients for the two approaches were used to adjust the coefficients for spectral irradiance variations.
;   
;   For wavelengths > 295 nm, where both sunspots and faculae modulate spectral and total irradiance, 
;   the d coefficients, d_F and d_S are estimated as:
;   d_F(k) = d_F_detrend(k) * [b_F / b_F_detrend]
;   d_S(k) = d_S_detrend(k) * [b_S / b_S_detrend]
;   
;   For wavelengths < 295 nm, where faculae dominate irradiance variability (d_S(k) ~ 0), the adjustments for 
;   the coefficients are estimated using the Ca K time series, a facular index independent of Mg II index, and a proxy for UV
;   spectral irradiance variability.
;   
;   Reference(s):
;   Reference describing the solar irradiance variability due to linear combinations of sunspot darkening
;   and facular brightening: 
;      Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends
;      and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998.
;   References describing the original NRLTSI and NRLSSI models are:
;      Lean, J., Evolution of the Sun's Spectral Irradiance Since the Maunder Minimum, Geophys. Res. Lett., 27, 2425-2428, 2000.
;      Lean, J., G. Rottman, J. Harder, and G. Kopp, SORCE Contributions to New Understanding of Global Change and Solar Variability,
;      Solar. Phys., 230, 27-53, 2005.
;      Lean, J. L., and T.N. Woods, Solar Total and Spectral Irradiance Measurements and Models: A Users Guide,
;      in Evolving Solar Physics and the Climates of Earth and Space, Karel Schrijver and George Siscoe (Eds), Cambridge Univ. Press, 2010.
;   Reference describing the extension of the model to include the extreme ultraviolet spectrum and the empirical capability to specify 
;   entire solar spectral irradiance and its variability from 1 to 100,000 nm:
;      Lean, J. L., T. N. Woods, F. G. Eparvier, R. R. Meier, D. J. Strickland, J. T. Correira, and J. S. Evans,
;      Solar Extreme Ultraviolet Irradiance: Present, Past, and Future, J. Geophys. Res., 116, A001102, 
;      doi:10.1029/2010JA015901, 2011.
;      
; INPUTS
;   sb           - sunspot darkening indice
;   mg           - facular brightening indice
;   model_params - a structure containing NRL2 coefficients necessary to construct modeled TSI:
;     lambda     - wavelength (nm; in 1-nm bins)
;     iquiet     - the adopted solar spectral irradiance of the Quiet Sun
;     ccoef      - the sum of the 'c' multiple regression coefficient for spectral facular brightening (equal to c_F(k), in above description)
;                  and the 'c' multiple regression coefficient for spectral sunspot darkening (equal to c_S(k), in above description)
;     dfaccoef   - the 'd' multiple regression coefficient for spectral facular brightening (equal to d_F(k), in above description);
;                  obtained from regression against detrended spectral irradiance observations multiplied with the ratio of the 'b' coefficients
;                  obtained from regression against total solar irradiance observations to that obtained from regression against detrended total 
;                  solar irradiance observations.
;     dspotcoef  - the 'd' multiple regression coefficient for spectral sunspot darkening (equal to d_S(k), in above description);
;                  obtained from regression against detrended spectral irradiance observations multiplied with the ratio of the 'b' coefficients
;                  obtained from regression against total solar irradiance observations to that obtained from regression against detrended total 
;                  solar irradiance observations.  
;     bfaccoef   - the 'b' multiple regression coefficient for bolometric facular brightening (equal to b_F, in above description)
;     bspotcoef  - the 'b' multiple regression coefficient for bolometric sunspot darkening (equal to b_S, in above description)
;     mgquiet    - the value of the facular brightening corresponding to quiet Sun (equal to F_Q, in above description)
;     efaccoef   - the small, but nonzero, correction factor needed so the numerical integral over wavelength of the time-dependent 
;                  SSI irradiance variations from faculae is equal to the time-dependent TSI irradiance variations from the faculae.
;     espotcoef  - the small, but nonzero, correction factor needed so the numerical integral over wavelength of the time-dependent 
;                  SSI irradiance variations from sunspots is equal to the time-dependent TSI irradiance variations from sunspots.             
;     tsisigma   - the 1-sigma uncertainty estimates for the coefficients returned in the multiple linear 
;                  regression of TSI. A 3-element array where first element contains the uncertainty in acoef (equal 
;                  to a_F_unc in above description), the second element contains the uncertainty in bfaccoef (equal to 
;                  b_F_unc in above description), and the third element contains the uncertainty in bspotcoef (equal to
;                  b_S_unc in above description).
;     mgu        - the relative uncertainty in change in facular brightening from its minimum value, mgquiet. Specified as 0.2 (20 %)
;     sbu        - the relative uncertainty in change in sunspot darkening from its minimum value, '0'. Specified as 0.2 (20%)
;     faccfunc   - the relative uncertainty estimate for the coefficients of spectral facular brightening obtained from multiple linear
;                  regression of the detrended spectral observations, and detrended indices. Corrected by a scaling factor
;                  derived from the ratio of linear regression coefficients from TSI observations and detrended TSI observations. 
;                  Also accounts for autocorrelation.
;     spotcfunc  - the relative uncertainty estimate for the coefficients of spectral sunspot darkening obtained from multiple linear
;                  regression of the detrended spectral observations, and detrended indices. Corrected by a scaling factor
;                  derived from the ratio of linear regression coefficients from TSI observations and detrended TSI observations. 
;                  Also accounts for autocorrelation.
;     qsigmafac  - the absolute uncertainty in the 'coeff0fac' factor 
;     coeff0fac  - the regression coefficient that linearly relates the facular brightening index to the residual energy in the facular 
;                  brightening index; only the 2nd element in the array (i.e. the "slope" coefficient) is used in the uncertainty propagation
;     qsigmaspot - the absolute uncertainty in the small, but nonzero 'coeff0spot' factor 
;     coeff0spot - the regression coefficient that linearly relates the sunspot darkening index to the residual energy in the sunspot darkening
;                  index; only the 2nd element in the array (i.e. the "slope" coefficient) is used in the uncertainty propagation
;     ccoefunc   - the absolute uncertainty in 'ccoef'
;     
;                  
; OUTPUTS
;   ssi   - a structure containing the following variables:
;     nrl2 - modeled solar spectral irradiance
;     dfactot - spectrally integrated value of the facular brightening
;     dspottot - spectrally integrated value of the sunspot darkening 
;     nrl2tot - spectrally integrated value of the SSI, nrl2
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
;   01/14/2015 Initial Version prepared for NCDC
;
; USAGE
;   compute_ssi, sb, mg, model_params
;
;@*****
function compute_ssi, sb, mg, model_params
;-------------spectral irradiance - 

  lambda    = model_params.lambda
  mgquiet   = model_params.mgquiet
  efaccoef  = model_params.efaccoef
  bfaccoef  = model_params.bfaccoef
  dfaccoef  = model_params.dfaccoef
  espotcoef = model_params.espotcoef
  bspotcoef = model_params.bspotcoef
  dspotcoef = model_params.dspotcoef
  iquiet    = model_params.iquiet
  ccoef     = model_params.ccoef 
  tsisigma  = model_params.tsisigma
  mgu       = model_params.mgu
  sbu       = model_params.sbu
  faccfunc  = model_params.faccfunc
  spotcfunc = model_params.spotcfunc
  qsigmafac = model_params.qsigmafac
  coeff0fac = model_params.coeff0fac
  qsigmaspot= model_params.qsigmaspot
  coeff0spot =model_params.coeff0spot
  ccoefunc  = model_params.ccoefunc
  
  ; calculate spectrum on 1 nm grid then sum into bins
  nlambda=n_elements(lambda)      ; this is the 1 nm grid
  nrl2=dblarr(nlambda)
;nrl2bin=dblarr(nband)     ; this is the binned wavelength grid ; move
;
  ; facular component
  deltati=poly(mg-mgquiet,efaccoef) ; this make facular contributions from spectrum match total
  deltamg=deltati/bfaccoef
  dfac=(mg-mgquiet+deltamg)*dfaccoef

  ; spot component
  deltati=poly(sb,espotcoef)    ; this make sunspot contributions from spectrum match total
  deltasb=deltati/bspotcoef
  dspot=(sb+deltasb)*dspotcoef
  
  ; spectral irradiance
  nrl2=iquiet+dfac+dspot+ccoef

  ; integral quantities
  dfactot=total(dfac, /double)
  dspottot=total(dspot, /double)
  nrl2tot=total(nrl2, /double)
  
  ;---------- uncertainty in solar spectral irradiance

  facunc1=abs(dfaccoef*(mg-mgquiet))*sqrt(faccfunc^2.+mgu^2.) 
  spotunc1=abs(dspotcoef*sb)*sqrt(spotcfunc^2.+sbu^2.)
  uu2=faccfunc^2.+(qsigmafac[1]/coeff0fac[1])^2.+(tsisigma[1]/bfaccoef)^2.+mgu^2.
  facunc2=abs(dfaccoef*deltamg)*sqrt(uu2)  
  uu2=spotcfunc^2.+(qsigmaspot[1]/coeff0spot[1])^2.+(tsisigma[2]/bspotcoef)^2.+sbu^2.
  spotunc2=abs(dspotcoef*deltasb)*sqrt(uu2)   
  nrl2unc=ccoefunc+facunc1+facunc2+spotunc1+spotunc2

  
  ssi = {nrl2_ssi,    $
  nrl2:  nrl2,        $
  dfactot:  dfactot,  $
  dspottot: dspottot, $
  nrl2tot:  nrl2tot,  $
  nrl2unc:  nrl2unc   $
  }
  
  return,ssi

stop
end