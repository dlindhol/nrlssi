function process_irradiance, ymd1, ymd2, output_dir=output_dir, final=final, dev=dev,  $
  time_bin=time_bin
;  daily=daily, monthly=monthly, annual=annual

  ;Restore model parameters
  model_params = get_model_params(fn)

  ;Set up wavelength bands for summing 1 nm spectrum
  spectral_bins = get_spectral_bins()

  ;Get input data
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, final=final, dev=dev) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, final=final) ;MgII index data - facular brightening
  
  ;Default to daily averages.
  if (not keyword_set(time_bin)) then time_bin = 'day'
  
  ;Bin and average by the desired time bin.
  ;The result will be a hash mapping the iso time to the average value for that time bin.
  ssb = bin_average(sunspot_blocking, time_bin)
  mgi = bin_average(mg_index, time_bin)
  
  ;Iterate over each time bin
  
  
end
