;@***h* SOLAR_IRRADIANCE_FCDR/compute_tsi.pro
;
; NAME
;   compute_tsi.pro
;
; PURPOSE
;   The compute_tsi.pro procedure is a function called by the driver routine,nrl2_to_irradiance,pro,
;   to compute daily Model Total Solar Irradiance using multiple regression coefficients specific to the 
;   NRLTSI2 model and given values for the sunspot darkening function and the facular brightening function.
;
; DESCRIPTION
;   The compute_tsi.pro function calculates the Model Total Solar Irradiance (TSI) for a specific day, given
;   values for the sunspot darkening and the facular brightening function using a 2-component multiple regression formula.
; 
;   Variable Definitions:
;   T(t) is the time-dependency (t) of TSI,
;   delta_T_F(t) is the time dependency of the delta change to TSI from the facular brightening index, F(t)
;   delta_T_S(t) is the time dependency of the delta change to TSI from the sunspot darkening index, S(t)
;   T_Q is the TSI of the adopted Quiet Sun reference value.
;   
;   2-Component Regression formulas: 
;   T(t) = T_Q + delta_T_F(t) + delta_T_S(t)

;   Quantifying time-dependent TSI (T) Irradiance Variations from Faculae (F) and Sunspots (S):
;   delta_T_F(t) = a_F + b_F * [F(t) - F_Q]
;   delta_T_S(t) = a_S + b_S * [S(t) - S_Q] and a_S = 0
;   F_Q and S_Q (=0) are the values of the facular brightening and sunspot darkening indices corresponding to T_Q 
;   (i.e. for the quiet Sun, T_Q). 
;   
;   Quantifying time-dependent Uncertainties in TSI Irradiance Variation from faculae and sunspots:
;   T_unc(t) = T_Q_unc + delta_T_F_unc(t) + delta_T_S_unc(t) where,
;   delta_T_F_unc(t) = a_F_unc + (the uncertainty in b_F * [F(t) - F_Q]) 
;   delta_T_S_unc(t) = (the uncertainty in b_S * [S(t) - S_Q]) 
;   
;   The uncertainty in b_F*[F(t) - F_Q]:
;   [(uncertainty in b_F * [F(t) - F_Q]) / (b_F * [F(t) - F_Q])^2 = (b_F_unc / b_F)^2 + ((uncertainty in [F(t) - F_Q])/[F(t) - F_Q])^2,
;   therefore, delta_T_F_unc(t) = a_F_unc + the square root of the above result multiplied by [b_F * [F(t) - F_Q]
;   
;   The uncertainty in b_S*[S(t) - S_Q]:
;   [(uncertainty in b_S * [S(t) - S_Q]) / (b_S * [S(t) - S_Q])^2 = (b_S_unc / b_S)^2 + ((uncertainty in [S(t) - S_Q])/[S(t) - S_Q])^2,
;   therefore, delta_T_S_unc(t) = the square root of the above result multiplied by [b_S * [S(t) - S_Q]
;   
;   Coefficients for faculae and sunspots:
;   The a and b coefficients for faculae and sunspots are specified and supplied with the algorithm, as are their 
;   1-sigma estimates (determined from the multiple linear regression analysis) . These coefficients best reproduce 
;   the TSI irradiance variability  measured directly by SORCE TIM from 2003 to 2014. 
;   Note, the a coefficient is nominally zero so that when F=F_Q and S=S_Q, then T=T_Q.
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
;   model_params - a structure containing model coefficients necessary to construct modeled TSI:
;     tquiet     - the adopted total solar irradiance of the Quiet Sun
;     acoef      - the 'a' multiple regression coefficient for facular brightening (equal to a_F, in above description)
;     bfaccoef   - the 'b' multiple regression coefficient for facular brightening (equal to b_F, in above description)
;     bspotcoef  - the 'b' multiple regression coefficient for sunspot darkening (equal to b_S, in above description)
;     mgquiet    - the value of the facular brightening corresponding to quiet Sun (equal to F_Q, in above description)
;     tsisigma   - the 1-sigma uncertainty estimates for the coefficients returned in the multiple linear 
;                  regression. A 3-element array where first element contains the uncertainty in acoef (equal 
;                  to a_F_unc in above description), the second element contains the uncertainty in bfaccoef (equal to 
;                  b_F_unc in above description), and the third element contains the uncertainty in bspotcoef (equal to
;                  b_S_unc in above description).
;     mgu        - the uncertainty in change in facular brightening from its minimum value, mgquiet. Specified as 0.2 (20 %)
;     sbu        - the uncertainty in change in sunspot darkening from its minimum value, '0'. Specified as 0.2 (20%)
;
; OUTPUTS
;   tsi   - a structure containing the following variables:
;     totirrad    - modeled total solar irradiance
;     totfac      - bolometric (spectrally integrated) contribution from facular brightening
;     totspot     - bolometric (spectrally integrated) contribution from sunspot darkening
;     totirradunc - uncertainty in the modeled total solar irradiance. Does not include the contribution 
;                   from uncertainty in the absolute scale of the measured irradiance (+/- 0.5 Wm-2) 
;     totfacunc   - uncertainty in the modeled total solar irradiance attributed to facular brightening contribution
;     totspotunc  - uncertainty in the modeled total solar irradiance attributed to the sunspot darkening contribution     
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
;   compute_tsi, sb, mg, model_params
;@*****

function compute_tsi,sb, mg, model_params

  tquiet    = model_params.tquiet
  acoef     = model_params.acoef  
  bfaccoef  = model_params.bfaccoef
  bspotcoef = model_params.bspotcoef
  mgquiet   = model_params.mgquiet  
  tsisigma  = model_params.tsisigma
  mgu       = model_params.mgu
  sbu       = model_params.sbu
    
  ;---------- total irradiance
  totirrad = tquiet+acoef+bfaccoef*(mg-mgquiet)+bspotcoef*sb
  totfac = acoef+bfaccoef*(mg-mgquiet)  ; facular compoment - for checking with SSI
  totspot = bspotcoef*sb    ; spot component - for checking with SSI

  ;---------- uncertainty in total irradiance
  totfacunc = sqrt((tsisigma[1]/bfaccoef)^2.+mgu^2.)
  totspotunc = sqrt((tsisigma[2]/bspotcoef)^2.+sbu^2.)
  totirradunc = tsisigma[0]+abs(totfac)*totfacunc+abs(totspot)*totspotunc
                  
  tsi = {nrl2_tsi,   $
    totirrad: totirrad,   $
    totfac:       totfac, $
    totspot:      totspot, $
    totirradunc:  totirradunc, $
    totfacunc:    totfacunc, $
    totspotunc:   totspotunc $
  }
  
  return,tsi
end