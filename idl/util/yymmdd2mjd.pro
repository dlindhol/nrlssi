;@***h* SOLAR_IRRADIANCE_FCDR/yymmdd2mjd.pro
; 
; NAME
;   yymmdd2mjd
;
; PURPOSE
;   Converts time from ISO 8601 standard to a Modified Julian Day (integer).
;
; DESCRIPTION
;   Converts time from ISO 8601 standard to a Modified Julian Day (integer).
;   
; INPUTS
;   yymmdd - time value in ISO standard
;   
; OUTPUTS
;   mjd - Modified Julian Date (integer)
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
;   yymmdd2mjd,yymmdd
;
;@***** 
function yymmdd2mjd, yymmdd

  yy = fix(strmid(yymmdd,0,2))
  mm = fix(strmid(yymmdd,2,2))
  dd = fix(strmid(yymmdd,4,2))

  ;Assume 2-digit year is in the set [1950 - 2050)
  if (yy lt 50) then year = 2000 + yy  $
  else year = 1900 + yy
  
  mjd = julday(mm, dd, year) - 2400000.5
  
  return, mjd
  
end

