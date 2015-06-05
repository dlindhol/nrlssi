;@***h* SOLAR_IRRADIANCE_FCDR/jd2iso_date.pro
; 
; NAME
;   jd2iso_date
;
; PURPOSE
;   Converts time from Julian Date (integer) to ISO 8601 standard, 'yyyy-mm-dd' 
;
; DESCRIPTION
;   Converts time from Julian Date (integer) to ISO 8601 standard, 'yyyy-mm-dd'. 
;   Uses ITT IDL library routine caldat.pro, which return the calendar date given julian date.  
;   
; INPUTS
;   jd - Julian Date
;   
; OUTPUTS
;   a value for time in ISO format ('yyyy-mm-dd')
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
;   06/04/2015 Initial Version prepared for NCDC
; 
; USAGE
;   result=jd2iso_date(jd)
;
;@***** 
function jd2iso_date, jd

  caldat, jd, mon, day, year
  
  format = '(I4,"-",I02,"-",I02)'
  
  return, string(format=format, year, mon, day)
  
end

