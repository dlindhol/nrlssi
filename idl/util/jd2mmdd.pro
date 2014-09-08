;@***h* SOLAR_IRRADIANCE_FCDR/jd2mmdd.pro
; 
; NAME
;   jd2mmdd
;
; PURPOSE
;   Converts time from Julian Date to a month and day string (mmdd). 
;
; DESCRIPTION
;   Converts time from Julian Date to a month and day string (mmdd). 
;   
; INPUTS
;   jd - time value in Julian Date
;   
; OUTPUTS
;   mmdd - a month and day string
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
;   jd2mmdd,jd
;
;@***** 
function jd2mmdd, jd

  caldat, jd, mon, day
  
  format = '(I02,I02)'
  
  return, string(format=format, mon, day)
  
end

