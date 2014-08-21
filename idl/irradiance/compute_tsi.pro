function compute_tsi,sb, mg, model_params

; calculate nrltsi2 model for given sb and mg
;
  tquiet    = model_params.tquiet
  acoef     = model_params.acoef  
  bfaccoef  = model_params.bfaccoef
  bspotcoef =  model_params.bspotcoef
  mgquiet   =    model_params.mgquiet
  
  
  ;---------- total irradiance
  totirrad = tquiet+acoef+bfaccoef*(mg-mgquiet)+bspotcoef*sb
  totfac = acoef+bfaccoef*(mg-mgquiet)  ; facular compoment - for checking with SSI
  totspot = bspotcoef*sb    ; spot component - for checking with SSI


  tsi = {nrl2_tsi,   $
    totirrad: totirrad,   $
    totfac:       totfac, $
    totspot:      totspot $
  }
  
  return,tsi
end