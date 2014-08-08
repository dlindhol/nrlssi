function compute_sunspot_blocking_uv, area, lat, lon
  ;works with arrays

  params = get_sunspot_blocking_parameters()
  
  mu = cos(lat*!pi/180.0) * cos(lon*!pi/180.0)
  
  ;Deal with zero area: blocking = 0
  ssb = fltarr(n_elements(area)) ;all 0s
  index = where(area ne 0.0, n)
  if n gt 0 then begin
    area = area[index]
    mu = mu[index]
  endif else index = findgen(n_elements(area)) ;all indices
    
  ;center to limb
  c0 = params.cl320[0]
  c1 = params.cl320[1]
  ctl = 1.0 - c0 - c1 + c0*mu + c1*mu*mu
          
  ssb[index] = 5.0*mu*ctl/2.0 * area * (0.2231 + 0.0244 * alog10(area))
  ssb = ssb * params.excess320 / params.excess

  return, ssb

end
