function compute_sunspot_blocking, area, lat, lon
  ;works with arrays
  
  mu = cos(lat*!pi/180.0) * cos(lon*!pi/180.0)
  
  ;Deal with zero area: blocking = 0
  ssb = fltarr(n_elements(area)) ;all 0s
  index = where(area ne 0.0, n)
  if n gt 0 then begin
    area = area[index]
    mu = mu[index]
  endif else index = findgen(n_elements(area)) ;all indices
  
  ssb[index] =  mu * (3*mu + 2)/2.0 * area * (0.2231 + 0.0244 * alog10(area))
  
  return, ssb
  
end
