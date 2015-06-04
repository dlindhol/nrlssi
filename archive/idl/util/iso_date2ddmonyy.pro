;@***h* SOLAR_IRRADIANCE_FCDR/iso_date2ddmonyy.pro
; 
; NAME
;   iso_date2ddmonyy
;
; PURPOSE
;   Converts time from ISO 8601 standard to ddMonyy format (ex. '14Aug13') 
;
; DESCRIPTION
;   Converts time from ISO 8601 standard to ddMonyy format (ex. '14Aug13')  
;   
; INPUTS
;   ymd - a value for time in ISO format ('yyyy-mm-dd')
;   
; OUTPUTS
;   dmy - time in ddMonyy format 
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
;   01/14/2015 Initial Version prepared for NCDC
; 
; USAGE
;   iso_date2ddMonyy,ymd
;
;@***** 
function iso_date2ddMonyy, ymd

  yy = strmid(ymd,2,2)
  mm = fix(strmid(ymd,5,2))
  dd = strmid(ymd,8,2)

  months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  mon = months[mm-1]

  dmy = dd + mon + yy

  return, dmy
end
