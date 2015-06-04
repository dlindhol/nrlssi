;@***h* TSI_FCDR/replace_missing_with_nan.pro
; 
; NAME
;   replace_missing_with_nan.pro
;
; PURPOSE
;   The replace_missing_with_nan.pro function returns a float array containing the given data with 
;   missing values replaced with NaN (not a number).
;
; DESCRIPTION
;   The replace_missing_with_nan.pro function returns a float array containing the given data with 
;   missing values replaced with NaN (not a number). It is subroutine of get_tsi_model_functions.pro.
;   A copy of the input data as floats is made, 1) so 'data' remains immutable and, 2) the result will be 
;   consistent with having float NaNs.
; 
; INPUTS
;   data - input data a copy of the data as floats:
;   missing_value - the value designated as "missing"
;   
; OUTPUTS
;   result - a copy of the input data, with missing values replaced by NaNs

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
;   replace_missing_with_nan, data, missing_value
;
;@***** 
function replace_missing_with_nan, data, missing_value
  ;TODO: should we use doubles?

  ;Make a copy of the data as floats:
  ;1) so 'data' remains immutable
  ;2) the result will be consistent with having float NaNs.
  result = double(data)
  
  ;Get the indices of the elements with missing values.
  index_of_missing = where (data eq missing_value, count)
  
  ;Replace missing values with NaN.
  ;Note, do the 'count' test, otherwise no matches means index will be -1 
  ;  which will cause the last sample to be replaced.
  if (count gt 0) then result[index_of_missing] = !VALUES.D_NAN

  return, result

end