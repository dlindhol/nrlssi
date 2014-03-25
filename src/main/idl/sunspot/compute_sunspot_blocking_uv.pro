function compute_sunspot_blocking_uv, area, lat, lon

  ;Shortcut if area is 0
  if (area eq 0) then return, 0

  params = get_sunspot_blocking_parameters()
  
  mu = cos(lat*!pi/180.0) * cos(lon*!pi/180.0)
  
  ;center to limb
  c0 = params.cl320[0]
  c1 = params.cl320[1]
  ctl = 1.0 - c0 - c1 + c0*mu + c1*mu*mu
          
  ssb = 5.0*mu*ctl/2.0 * area * (0.2231 + 0.0244 * alog10(area))
  ssb = ssb * params.excess320 / params.excess

  return, ssb

end
