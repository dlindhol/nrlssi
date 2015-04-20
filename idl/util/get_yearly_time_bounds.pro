function first_day_of_year, mjd
  iso = mjd2iso_date(mjd) ;yyyy-mm-dd
  yr  = strmid(iso, 0, 4) ;yyyy
  ymd = yr + '-01-01' ;first day of year
  mjd1 = iso_date2mjdn(ymd)
  return, mjd1
end


function get_yearly_time_bounds, mjd
  ;mjd is an array of Modified Julian Date values at the middle of the year (July 1)
  ;The bounds should be the 1st of each year, exclusive on the upper bound

  ;lower bounds
  lower = first_day_of_year(mjd)
  ;upper bounds, add 365 days to safely put us in the next year
  upper = first_day_of_year(mjd+365)

  n = n_elements(mjd)
  bounds = dblarr(n,2)
 
  ;TODO: there must be a better, idiomatic way
  for i = 0, n-1 do begin
    bounds[i,0] = lower[i]
    bounds[i,1] = upper[i]
  endfor

  return, bounds
  
end
