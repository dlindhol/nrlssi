;@***h* TSI_FCDR/get_tsi_model_functions.pro
; 
; NAME
;   get_tsi_model_functions.pro
;
; PURPOSE
;   The get_tsi_model_functions.pro function extracts a structure of facular brightening and
;   sunspot blocking functions specific to the NRLTSI-2 model. 
;   This function is called from the main routine, nrl_2_tsi.pro.
;
; DESCRIPTION
;   This routine returns a data structure containing facular brightening and
;   sunspot blocking functions to the main routine, nrl_2_tsi.pro.
; 
; INPUTS
;   file - ascii file containing facular brightening and sunspot darkening functions.
;   
; OUTPUTS
;   data - a structure containing facular brightening ('px') and sunspot darkening ('ps') functions

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
;   04/23/2014 Initial Version prepared for NCDC
; 
; USAGE
;   get_tsi_model_functions, file
;
;@***** 
function get_tsi_model_functions, file

  ;template to read ascii file of facular brightening and sunspot darkening functions from file
  temp = {version:1.0, $
    datastart:15L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:7l, $
    fieldtypes:[4l, 4l, 4l, 4l, 4l,4l, 4l], $ ; float
    fieldnames:['Year', 'DOY', 'Day_Number', $
    'TSI_data','TSI_model','PX','PS'], $
    fieldlocations:[1L, 12L, 20L, 28L, 42L,52L,69L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L, 6L]}
    
  data = read_ascii(file, template = temp)
  
  ;Replace missing values with NaN
  data.PX = replace_missing_with_nan(data.PX, -99.0)
  data.PS = replace_missing_with_nan(data.PS, -999.0)
  
  return, data
  
end
