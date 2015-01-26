;@***h* SOLAR_IRRADIANCE_FCDR/iso_date2mjdn.pro
; 
; NAME
;   iso_date2mjdn
;
; PURPOSE
;   Converts time from ISO 8601 standard to Modified Julian Date 
;
; DESCRIPTION
;   Converts time from ISO 8601 standard to Modified Julian Date. 
;   Uses the ITT/IDL library routine julday.pro, which calculates the julian day 
;   number for a given month, day, and year. 
;   
; INPUTS
;   ymd - a value for time in ISO format ('yyyy-mm-dd')
;   
; OUTPUTS
;   mjd - Modified Julian Date 
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
;   01/15/2015 Initial Version prepared for NCDC
; 
; USAGE
;   iso_date2mjdn,ymd
;
;@***** 
function iso_date2mjdn, ymd
;Convert a date of the form 'yyyy-mm-dd' to a modified julian day number.
;Note an integral Julian Date represents noon GMT, while the ymd input is 
;interpreted as midnight at the start of the day. IDL's julday will round up
;such that converting the julian back to UTC will be at noon (GMT) of the 
;original date. So, effectively, the input date is treated as noon (GMT) of that day.
;Assumes ymd of the form yyyy-mm-dd
;TODO: should be able to use TIMESTAMPTOVALUES but not found in my 8.2 install!?

  year = fix(strmid(ymd,0,4))
  mon  = fix(strmid(ymd,5,2))
  day  = fix(strmid(ymd,8,2))

  mjd = julday(mon, day, year) - 2400000.5
  
  return, floor(mjd)
  
end

