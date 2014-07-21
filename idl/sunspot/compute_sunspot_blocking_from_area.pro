function compute_sunspot_blocking_from_area, area, lat, lon

  ;Shortcut if area is 0
  if (area eq 0) then return, 0
  
  mu = cos(lat*!pi/180.0) * cos(lon*!pi/180.0)
  
  ssb = mu * (3*mu + 2)/2.0 * area * (0.2231 + 0.0244 * alog10(area))
  
  return, ssb
  
end
