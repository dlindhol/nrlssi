function get_sunspot_blocking_parameters

  ; more notes on contrast -
  ; for total radiation - Allen, 1979, p.184, umbra/photosphere=0.24
  ; and penumbra/photosphere=0.77
  ; also umra radius/penumbra radius=0.42
  ; thus umbral area = piiRumb^2 and penumbral area=pii(Rpen^2-Rumb^2)
  ; total spot area=piiRpen^2
  ; thus, area weighted contrast is ..
  ; 0.24piiRumb^2/piiRpen^2+0.77pii(Rpen^2-Rumb^2)/piiRpen^2=
  ; Cumb*0.1764+Cpen*0.8236
  ; 0.04234+0.634=0.6765
  ; and contrast-1=0.3235 ; use this value now for bolometric
  ; and add area dependence ... contrast=0.2231+0.0244log10(A) - where A is
  ; total sunspot area in millionths of solar hemisphere
  ;
  ;
  
  ;
  ; the coeffs for 320 nm center-to-limb variation
  ; from Allen, 1979, p.171 are cl320=[0.88,0.03]
  ; where I/I0=1.-cl320(0)-cl320(1)+cl320(0)*mu+cl320(1)*mu*mu
  
  params = {sunspot_blocking_parameters, $
    excess:    0.3235,      $
    excess320: 0.464,       $
    cl320:     [0.88,0.03]  $
  }
  
  return, params
  
end
