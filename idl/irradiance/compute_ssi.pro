;@***h* SOLAR_IRRADIANCE_FCDR/compute_ssi.pro
;
; NAME
;   compute_ssi.pro
;
; PURPOSE
;   The compute_ssi.pro procedure is a function called by the driver routine,nrl2_to_irradiance,pro,
;   to compute daily Model Solar Spectral Irradiance using
;   multiple regression coefficients specific to the NRL2 model, given values for the sunspot darkening function
;   and the facular brightening function.
;
; DESCRIPTION
;   The compute_ssi.pro function calculates the Model Solar Spectral Irradiance (SSI) for a specific day, given
;   values for the sunspot darkening and the facular brightening function using a 2-component multiple regression formula.
; 
;   Variable Definitions:
;   I(k,t) it the spectral (k) and time-dependency (t) of SSI.
;   delta_I_F(k,t) is similarly described, but for SSI, and is also spectrally dependent 
;   delta_I_S(t) is similarly described, but for SSI, and is also spectrally dependent
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
;   Note, the c coefficient is nominally zero so that when F=F_Q and S=S_Q, then I=I_Q.
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
;      Lean, J. L., J. T. Emmert, J. M. Picone, and R. R. Meier, Global and regional trends in ionospheric total electron content, 
;      J. Geophys. Res., 116, A00H04, doi:10.1029/2010JA016378.
;      
; INPUTS
;   sb           - sunspot darkening indice
;   mg           - facular brightening indice
;   model_params - a structure containing NRL2 coefficients necessary to construct modeled TSI:
;     lambda     - wavelength (nm; in 1-nm bins)
;     iquiet     - the adopted solar spectral irradiance of the Quiet Sun
;     ccoef      - the 'c' multiple regression coefficient for spectral facular brightening (equal to c_F(k), in above description)
;     dfaccoef   - the 'd' multiple regression coefficient for spectral facular brightening (equal to d_F(k), in above description)
;     dspotcoef  - the 'd' multiple regression coefficient for spectral sunspot darkening (equal to d_S(k), in above description)  
;     bfaccoef   - the 'b' multiple regression coefficient for bolometric facular brightening (equal to b_F, in above description)
;     bspotcoef  - the 'b' multiple regression coefficient for bolometric sunspot darkening (equal to b_S, in above description)
;     mgquiet    - the value of the facular brightening corresponding to quiet Sun (equal to F_Q, in above description)
;     efaccoef   - the small, but nonzero, correction factor needed so the numerical integral over wavelength of the time-dependent 
;                  SSI irradiance variations from faculae is equal to the time-dependent TSI irradiance variations from the faculae.
;                  
; OUTPUTS
;   ssi   - a structure containing the following variables:
;     nrl2 - modeled solar spectral irradiance
;     dfactot - spectrally integrated value of the facular brightening
;     dspottot - spectrally integrated value of the sunspot darkening 
;     nrl2tot - spectrally integrated value of the irradiance, nrl2
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
;   08/25/2014 Initial Version prepared for NCDC
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
  
  
  ; calculate spectrum on 1 nm grid then sum into bins
  nlambda=n_elements(lambda)      ; this is the 1 nm grid
  nrl2=dblarr(nlambda)
;nrl2bin=dblarr(nband)     ; this is the binned wavelength grid ; move
;
  ; facular component
  deltati=poly(mg-mgquiet,efaccoef) ; this make spectrum match total
  deltamg=deltati/bfaccoef
  dfac=(mg-mgquiet+deltamg)*dfaccoef

  ; spot component
  deltati=poly(sb,espotcoef)    ; this make spectrum match total
  deltasb=deltati/bspotcoef
  dspot=(sb+deltasb)*dspotcoef
  nrl2=iquiet+dfac+dspot+ccoef

  dfactot=total(dfac)
  dspottot=total(dspot)
  nrl2tot=total(nrl2)

  ssi = {nrl2_ssi,    $
  nrl2:  nrl2,        $
  dfactot:  dfactot,  $
  dspottot: dspottot, $
  nrl2tot: nrl2tot    $
  }
  
  return,ssi

stop
end