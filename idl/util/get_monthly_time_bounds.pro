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
