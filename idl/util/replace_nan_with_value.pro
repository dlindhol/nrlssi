;@***h* TSI_FCDR/replace_nan_with_value.pro
; 
; NAME
;   replace_nan_with_value.pro
;
; PURPOSE
;   The replace_nan_with_value.pro function returns a float array containing the given data with 
;   NaN replaced with user designated missing value.
;
; DESCRIPTION
;   The replace_nan_with_value.pro function returns a float array containing the given data with 
;   NaN replaced with user designated missing value. It is subroutine of write_tsi_model_to_netcdf2.pro and write_ssi_model_to_netcdf2.
;   A copy of the input data as floats is made so 'data' remains immutable.
; 
; INPUTS
;   data - input data a copy of the data as floats:
;   value - the value designated to replace NaN as "missing" values
;   
; OUTPUTS
;   result - a copy of the input data, with NaNs replaced by missing values

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
;   replace_nan_with_missing, data, value
;
;@***** 

function replace_nan_with_value, data, value
  ;TODO: should we use doubles?

  ;Make a copy of the data as floats so 'data' is not impacted.
  result = double(data)
  
  ;Get the indices of the NaNs. Note, we can't use equality tests for NaNs.
  index = where (FINITE(data, /nan), count)
  
  ;Replace.
  ;Note, do the 'count' test, otherwise no matches means index will be -1 
  ;  which will cause the last sample to be replaced.
  if (count gt 0) then result[index] = value

  return, result

end