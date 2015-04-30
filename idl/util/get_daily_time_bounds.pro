function current_day, mjd
  iso = mjd2iso_date(mjd) ;yyyy-mm-dd
  ;  ym  = strmid(iso, 0, 7) ;yyyy-mm
  ;  ymd = ym + '-01' ;first day of month
  mjd1 = iso_date2mjdn(iso)
  return, mjd1
end


function get_daily_time_bounds, mjd
  ;mjd is an array of Modified Julian Date values at the middle of the month (15th)
  ;The bounds should be the 1st of each month, exclusive on the upper bound
  
  ;lower bounds
  lower = current_day(mjd)
  ;upper bounds, add 1 day
  upper = current_day(mjd+1)
  
  n = n_elements(mjd)
  bounds = dblarr(2,n)
  
  ;TODO: there must be a better, idiomatic way
  for i = 0, n-1 do begin
    bounds[0,i] = lower[i]
    bounds[1,i] = upper[i]
  endfor
  
  return, bounds
  
end
