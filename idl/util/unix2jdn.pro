;@***h* SOLAR_IRRADIANCE_FCDR/unix2jdn.pro
; 
; NAME
;   unix2jdn
;
; PURPOSE
;   Converts given unix time (seconds since 1970-01-01) to a Julian Day Number.
;
; DESCRIPTION
;   Converts given unix time (seconds since 1970-01-01) to a Julian Day Number.
;   
; INPUTS
;   unix_time - value in seconds since 1970-01-01
;   
; OUTPUTS
;   jdn - Julian Date 
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
;   unix2jdn,unix_time
;
;@***** 

;Return the given unix time (seconds since 1970-01-01) as a Julian Day Number.
function unix2jdn, unix_time
  jd_at_1970 = 2440587.5d ;1970-01-01T00:00:00Z
  unix_days = unix_time / 86400.0d
  jdn = floor(unix_days + jd_at_1970) ;floor to reduce Julian Date to Julian day Number
  return, jdn
end

;TODO: write tests
;The Julian date for CE  2000 January  1 00:00:00.0 UT is
;JD 2451544.500000
;Epoch timestamp: 946684800
;
;The Julian date for CE  2000 January  1 01:00:00.0 UT is
;JD 2451544.541667
;Epoch timestamp: 946688400
;
;The Julian date for CE  2000 January  1 12:00:00.0 UT is
;JD 2451545.000000
;Epoch timestamp: 946728000
;
;The Julian date for CE  2000 January  1 23:00:00.0 UT is
;JD 2451545.458333
;Epoch timestamp: 946767600
;
;JDN represents the night time period