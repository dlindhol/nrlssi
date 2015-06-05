;@***h* SOLAR_IRRADIANCE_FCDR/unix2mjd.pro
;
; NAME
;   unix2mjd
;
; PURPOSE
;   Converts time from UNIX standard (with epoch 1970-01-01T00:00:00Z) to Modified Julian Date
;
; DESCRIPTION
;   Converts time from UNIX standard (with epoch 1970-01-01T00:00:00Z) to Modified Julian Date
;
; INPUTS
;   unix_time - a value for time in UNIX format (with epoch 1970-01-01T00:00:00Z)
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
;   06/04/2015 Initial Version prepared for NCDC
;
; USAGE
;   result=unix2mjd(unix_time)
;
;@*****
function unix2mjd, unix_time
  mjd_at_1970 = 40587.0d  ;Modified Julian Date at UNIX epoch: 1970-01-01T00:00:00Z
  unix_days = double(unix_time) / 86400.0d  ;days since UNIX epoch
  mjd = mjd_at_1970 + unix_days
  return, mjd
end
