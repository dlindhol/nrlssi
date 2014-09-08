;@***h* SOLAR_IRRADIANCE_FCDR/group_and_sum.pro
; 
; NAME
;   group_and_sum.pro
;
; PURPOSE
;   The group_and_sum.pro function sums the sunspot darkening index from contributing sunspot groups, for each measuring station. 
;   If a station is missing data for a particular sunspot grouping, a quality flag to indicate missing data is set.  
;   
;
; DESCRIPTION
;   The group_and_sum.pro function sums the sunspot darkening index from contributing sunspot groups, for each measuring station.
;   If a station is missing data for a particular sunspot grouping, a quality flag to indicate missing data is set.
;   By default, the missina area for a particular sunspot grouping is set to zero. With an optional keyword input, the zero value
;   can be replaced by NaN  (for QA purposes). 
;                                     
; INPUTS
;   keys - A hash key linking "ssdata.station" to sunsport darkening index value, 'values'
;   values - The value of sunspot darkening for a station (identified by the hash key, "keys").
;   nan_as_zero=nan_as_zero - (Optional). Set missing area for a particular sunspot gropu to NaN, instead of zero (default).
;   
; OUTPUTS
;   result - The sum of sunspot darkening from a sunspot grouping of a monitoring station.
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
;   09/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   group_and_sum,keys,values,nan_as_zero=nan_as_zero
;
;@***** 
;Group the data into a hash by the keys with each value being 
;the sum of the values with the matching key
function group_and_sum, keys, values, nan_as_zero=nan_as_zero
  ;TODO: assert both have same length

  ;Define Hash to contain the results.
  result = Hash()
  
  for i = 0, n_elements(keys)-1 do begin
    key = keys[i]
    value = values[i]
    if keyword_set(nan_as_zero) and finite(value, /nan) then value = 0
    if result.hasKey(key) then result[key] += value  $
    else result[key] = value
  endfor

  return, result
  
end
