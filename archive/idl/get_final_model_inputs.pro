;@***h* TSI_FCDR/get_final_model_inputs.pro
; 
; NAME
;   get_final_model_inputs.pro
;
; PURPOSE
;   The get_final_model_inputs.pro function extracts a structure of facular brightening and
;   sunspot blocking functions specific to the NRLTSI-2 model. 
;   This function is called from the main routine, nrl2_to_irradiance.pro. It is used to create final, static, data product. 
;   The daily, operational, products are obtained using inputs extracted from web resources.
;
; DESCRIPTION
;   This routine returns a data structure containing facular brightening and
;   sunspot blocking functions to the main routine, nrl2_to_irradiance.pro.
; 
; INPUTS
;   file - ascii file containing facular brightening and sunspot darkening functions.
;   
; OUTPUTS
;   final - a structure containing facular brightening ('FAC') and sunspot darkening ('SPOT') functions

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
;   11/25/2014 Initial Version prepared for NCDC
; 
; USAGE
;   get_final_model_inputs, file
;
;@***** 
function get_final_model_inputs, file

  ;template to read ascii file of facular brightening and sunspot darkening functions from file
  temp = {version:1.0, $
    datastart:5L, $
    delimiter:32b, $
    missingvalue:!VALUES.D_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[3l, 3l, 3l, 4l, 4l], $ ; float
    fieldnames:['year', 'month', 'day', $
    'spot','fac'], $
    fieldlocations:[2L, 11L, 17L, 26L, 40L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]}
    
  final = read_ascii(file, template = temp)
  
  ;Replace missing values with NaN
  final.fac = replace_missing_with_nan(final.fac, -99.0)
  final.spot = replace_missing_with_nan(final.spot, -999.0)
  
  return, final
  
end