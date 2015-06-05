;@***h* SOLAR_IRRADIANCE_FCDR/get_monthly_time_bounds.pro
;
; NAME
;   get_monthly_time_bounds
;
; PURPOSE
;   Defines the bounds for each time bin in the monthly-averaged irradiance data
;
; DESCRIPTION
;   Defines the bounds for each time bin in the monthly-averaged irradiance data
;
; INPUTS
;   mjd - array of Modified Julian Date for the data time bins at the middle of the month (15th)
;   
; OUTPUTS
;   bounds - The bounds (in modified Julian data) for the 1st of each month (inclusive),
;            and end of each month (exclusive).
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
;   result=get_monthly_time_bounds(mjd)
;
;@*****
function first_day_of_month, mjd
  iso = mjd2iso_date(mjd) ;yyyy-mm-dd
  ym  = strmid(iso, 0, 7) ;yyyy-mm
  ymd = ym + '-01' ;first day of month
  mjd1 = iso_date2mjdn(ymd)
  return, mjd1
end


function get_monthly_time_bounds, mjd
  ;mjd is an array of Modified Julian Date values at the middle of the month (15th)
  ;The bounds should be the 1st of each month, exclusive on the upper bound

  ;lower bounds
  lower = first_day_of_month(mjd)
  ;upper bounds, add 30 days to safely put us in the next month
  upper = first_day_of_month(mjd+30)

  n = n_elements(mjd)
  bounds = dblarr(2,n)
 
  ;TODO: there must be a better, idiomatic way
  for i = 0, n-1 do begin
    bounds[0,i] = lower[i] ;try reverse dimension
    bounds[1,i] = upper[i] ;try reverse dimension
  endfor

  return, bounds
  
end
