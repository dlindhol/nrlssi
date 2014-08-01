function compute_sunspot_blocking, area, lat, lon
  ;works with arrays
  
  mu = cos(lat*!pi/180.0) * cos(lon*!pi/180.0)
  
  ssb = mu * (3*mu + 2)/2.0 * area * (0.2231 + 0.0244 * alog10(area))
  
  return, ssb
  
end
