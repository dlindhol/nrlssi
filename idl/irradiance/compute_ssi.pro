function compute_ssi, sb, mg, model_params
;-------------spectral irradiance - 

  lambda    = model_params.lambda
  mgquiet   = model_params.mgquiet
  efaccoef  = model_params.efaccoef
  bfaccoef  = model_params.bfaccoef
  dfaccoef  = model_params.dfaccoef
  espotcoef = model_params.espotcoef
  bspotcoef = model_params.bspotcoef
  dspotcoef = model_params.dspotcoef
  iquiet    = model_params.iquiet
  ccoef     = model_params.ccoef
  
  
  ; calculate spectrum on 1 nm grid then sum into bins
  nlambda=n_elements(lambda)      ; this is the 1 nm grid
  nrl2=dblarr(nlambda)
;nrl2bin=dblarr(nband)     ; this is the binned wavelength grid ; move
;
  ; facular component
  deltati=poly(mg-mgquiet,efaccoef) ; this make spectrum match total
  deltamg=deltati/bfaccoef
  dfac=(mg-mgquiet+deltamg)*dfaccoef

  ; spot component
  deltati=poly(sb,espotcoef)    ; this make spectrum match total
  deltasb=deltati/bspotcoef
  dspot=(sb+deltasb)*dspotcoef
  nrl2=iquiet+dfac+dspot+ccoef

  dfactot=total(dfac)
  dspottot=total(dspot)
  nrl2tot=total(nrl2)

  ssi = {nrl2_ssi,    $
  nrl2:  nrl2,        $
  dfactot:  dfactot,  $
  dspottot: dspottot, $
  nrl2tot: nrl2tot    $
  }
  
  return,ssi

stop
end