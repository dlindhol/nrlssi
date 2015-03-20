function process_irradiance, ymd1, ymd2, output_dir=output_dir, final=final, dev=dev,  &
  daily=daily, monthly=monthly, annual=annual

  ;Restore model parameters
  model_params = get_model_params(fn)

  ;Set up wavelength bands for summing 1 nm spectrum
  spectral_bins = get_spectral_bins()

  ;Get input data
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, final=final, dev=dev) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, final=final) ;MgII index data - facular brightening

  ;Create a Hash for each input dataset mapping MJD (assumed to be integer, i.e. midnight) to the appropriate record.
  ;Note, Hash values will be arrays but should have only one element: the data record for that day.
  ;TODO: generalize for multiple samples per day - daily average
;  sunspot_blocking_by_day = group_by_tag(sunspot_blocking, 'MJDN')
;  mg_index_by_day = group_by_tag(mg_index, 'MJD')
  
  if keyword_set(annual) then begin
    
  endif
  
  
end
