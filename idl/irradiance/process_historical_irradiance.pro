function process_historical_irradiance,ymd1,ymd2,final=final,time_bin=time_bin,cycle=cycle

  ;Get the NRL2 model parameters
  model_params = get_model_params() 
  
  restore,'data/NRL2_historical_model_parameters_v02r00.sav' ;To Do, these should be added to the get_model_params routine/structure
  cfit = struct.cycle_fit
  background_unc = struct.backgroundunc
  
  ;Set up wavelength bands for summing 1 nm spectrum
  spectral_bins = get_spectral_bins()

  ;Default to yearly averages.
  if (not keyword_set(time_bin)) then time_bin = 'year'
    
  ;Get input data
  tsi = get_historical_tsi(ymd1, ymd2, cycle=cycle) ;todo update this routine to serve data with the uncertainty column
  tsi = tsi.toArray() ;convert from list to structure
  
  
;  ssi = get_historical_ssi(ymd1, ymd2) ;To Do - develop this routine; no cycle-only SSI data (yet) from Judith
;  ssiuncertainty = ssi.irradiance & ssiuncertainty(*) = 0. ;fill with 0 values
;  ssiuncertainty = replace_missing_with_nan(ssiuncertainty, 0.) ; replace 0 values with NaN's
  
  
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
;    totirradunc = tsi[i].uncertainty ; todo: what will this be called in data structure output from get_historical_tsi.pro?
;    ssibin     = ssi[i].irradiance ; todo: write this latis routine to serve the final historical ssi data.
;    ssibinunc  = ssiuncertainty[i]; todo: what will this be called in data structure output 
;    ssibinsum  = total(ssi[i].irradiance*spectral_bins.bandwidth)
    
    ;Create the resulting data structure.
    struct = {hist_irradiance,      $
      mjd:    mjdn,                  $
      iso:    iso_time,             $
      tsi:    totirrad    $
      ;tsiunc: totirradunc, $
      ;ssi:    ssibin,     $
      ;ssiunc: ssibinunc,  $
      ;ssitot: ssibinsum   $
    }
    data_list.add, struct
  endfor
    
  ;Convert to an array.
  irradiance_data = data_list.toArray()

  ;Construct resulting data structure, including the spectral bins.
  data = {wavelength: spectral_bins, data: irradiance_data}

  return, data
  
end