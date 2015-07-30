function process_historical_irradiance,ymd1,ymd2,final=final,time_bin=time_bin,cycle=cycle

  ;Get the NRL2 model parameters
  model_params = get_model_params() 
  
  missing_value = -99.0
  
  restore,'data/NRL2_historical_model_parameters_v02r00.sav' ;To Do, these should be added to the get_model_params routine/structure and improve time series extraction of backgroundunc.
  cfit = struct.cycle_fit
  background_unc = struct.backgroundunc
  
  ;Set up wavelength bands for summing 1 nm spectrum
  spectral_bins = get_spectral_bins()

  ;Default to yearly averages for historical processing.
  if (not keyword_set(time_bin)) then time_bin = 'year'
  
  ;Get input data
  tsi = get_historical_tsi(ymd1, ymd2, cycle=cycle) 
  tsi = tsi.toArray() ;convert from list to structure
  
  ssi = get_historical_ssi(ymd1, ymd2) 
  
  ;Assign missing values to SSI uncertainty (for now)
  ssiuncertainty = ssi.ssi & ssiuncertainty(*) = missing_value
  
  ;Make sure that we have the same time samples for each
  bad = where(tsi.time ne ssi.time, nbad)
  if (nbad gt 0) then begin
    print, 'ERROR: Historical TSI and SSI records have different time samples.'
    return, -1
  endif
  
  ;Number of time samples 
  n = n_elements(tsi.time)
  
  ;Make list to accumulate results
  data_list = List()

  ;Iterate over each time sample.

  for i = 0, n-1 do begin
    
    stringtime = strtrim(string(tsi[i].time),2)
    
    ;Convert string to iso string
    iso_time = get_year_as_iso_from_record(stringtime)
    
    ;Convert to MJD
    mjdn = iso_date2mjdn(iso_time)

    totirrad = tsi[i].irradiance
    totirradunc = tsi[i].uncertainty 
    ssibin     = ssi.ssi[*,i] ; 
    ssibinunc  = ssiuncertainty[*,i]
    ssibinsum  = total(ssibin * spectral_bins.bandwidth)
    
    ;Create the resulting data structure.
    struct = {hist_irradiance, $
      mjd:    mjdn,            $
      iso:    iso_time,        $
      tsi:    totirrad,        $
      tsiunc: totirradunc,     $
      ssi:    ssibin,          $
      ssiunc: ssibinunc,       $
      ssitot: ssibinsum        $
    }
    data_list.add, struct
  endfor
    
  ;Convert to an array.
  irradiance_data = data_list.toArray()

  ;Construct resulting data structure, including the spectral bins.
  data = {wavelength: spectral_bins, data: irradiance_data}

  return, data
  
end