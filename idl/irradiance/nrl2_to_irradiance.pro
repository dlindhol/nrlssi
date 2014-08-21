pro nrl2_to_irradiance

; pro to calculate nrltsi2 and nrlssi2 using saved parameters

  ; test day is 1 Jan 2003
  day=1
  month=1
  year=2003
  sb=79.76      ; from NOAA WDC sunspot regions
  mg=0.1612   ; on GOME scale
  ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

  modver='18Aug14'
  fn='~/git/nrlssi/data/judith_2014_08_21/NRL2_model_parameters_'+modver+'.sav'

  model_params = get_model_params(fn) ; restore model parameters
  
  spectral_bins = get_spectral_bins() ; set up wavelength bands for summing 1 nm spectrum
   
  nrl2_tsi = compute_tsi(sb ,mg ,model_params) ;calculate TSI for given sb and mg
  
  ssi = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
  
  nrl2_ssi = bin_ssi(model_params, spectral_bins, ssi) ; SSI on the binned wavelength grid

  print,systime(0),mg,sb,nrl2_tsi.totirrad,ssi.nrl2tot,nrl2_ssi.nrl2binsum
  stop
  
end

