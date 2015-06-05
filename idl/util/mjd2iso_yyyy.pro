;@***h* SOLAR_IRRADIANCE_FCDR/mjd2iso_yyyy.pro
; 
; NAME
;   mjd2iso_yyyy
;
; PURPOSE
;   Converts time from Modified Julian Date (integer) to a 4 digit year in ISO 8601 standard, 'yyyy' 
;
; DESCRIPTION
;   Converts time from Modified Julian Date (integer) to 4 digit year ISO 8601 standard, 'yyyy' 
;   
; INPUTS
;   mjd - Modified Julian Date
;   
; OUTPUTS
;   a value for year in ISO format ('yyyy')
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
;   06/04/2015 Initial Version prepared for NCDC
; 
; USAGE
;   result=mjd2iso_yyyy(mjd)
;
;@***** 
function mjd2iso_yyyy, mjd

  jd = mjd + 2400000.5
  caldat, jd, mon, day, year
  
  format = '(I4)'
  
  ;support array of dates
  n = n_elements(mjd)
  result = strarr(n)
  for i = 0, n-1 do result[i] = string(format=format, year[i])
  
  return, result
  
end

