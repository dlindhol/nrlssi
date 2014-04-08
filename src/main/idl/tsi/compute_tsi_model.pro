;@***h* TSI_FCDR/compute_tsi_model.pro
; 
; NAME
;   compute_tsi_model.pro
;
; PURPOSE
;   The compute_tsi_model.pro function computes the Model Total Solar Irradiance from the given 
;   TSI model coefficients (c) and TSI model regression data (d). This function is called from the main
;   routine, nrl_2_tsi.pro.
;
; DESCRIPTION
;   This routine is passed an array of TSI model multiple regression coefficients ('c') and an array of 
;   TSI model data ('d') and computes the Model Total Solar Irradiance using the 2-component regression formula
;   and coefficients [Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends 
;   and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998]. 
;   The output data are returned as a structure to the main routine, nrl_2_tsi.pro.
; 
; INPUTS
;   c  - an array of TSI model coefficients obtained from get_tsi_model_coeffs.pro (a0, a1, a2, and S0)
;   d  - an array of photometric sunspot blocking (ps) and facular brightening (px) functions 
;        obtained from get_tsi_model_regression                                                 
;
; OUTPUTS
;   data = structure of Modeled Total Solar Irradiance (TI) computed using the 
;          2-Component regression formula and coefficients: TI = a0 + a1*px + a2*S0*ps/1.e6

; AUTHOR
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
;   04/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   compute_tsi_model, c, d
;
;@***** 
function compute_tsi_model, c, d
  
  ; Evaluate the tsi model
  tsi = c.a0 + c.a1 * d.px + c.a2 * c.S0 * d.ps / 1.e6
  
  ; Create data structure with the results
  data = {tsi_model, year:d.year, doy:d.doy, day_number:d.day_number, tsi:tsi}

  return, data
  
end