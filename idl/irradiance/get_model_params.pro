function get_model_params,infile

  ; read in the NRLSSI parameter arrays needed to calculate spectral irradiance
  ;restore model parameters needed to calculate total and spectral irradiance
  restore,infile
  
  ; in this save file are the following...
  ; tquiet
  ; iquiet
  ; lambda
  ; acoef
  ; bfaccoef
  ; bspotcoef
  ; ccoef
  ; dfaccoef
  ; efaccoef
  ; dspotcoef
  ; espotcoef
  ; mgquiet


  params = {model_params, $
    tquiet:       tquiet, $
    iquiet:       iquiet, $
    lambda:       lambda, $
    acoef:         acoef, $
    bfaccoef:   bfaccoef, $
    bspotcoef: bspotcoef, $
    ccoef:         ccoef, $
    dfaccoef:   dfaccoef, $
    efaccoef:   efaccoef, $
    dspotcoef: dspotcoef, $
    espotcoef: espotcoef, $
    mgquiet:     mgquiet  $
  }
  
  return, params
end
