function process_irradiance, ymd1, ymd2, final=final, dev=dev,  $
  time_bin=time_bin

  ;Get the NRL2 model parameters
  model_params = get_model_params()

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
  
  ;Get the sorted list of times
  ;ssb_times = (ssb.keys()).sort()
  ;mgi_times = (mgi.keys()).sort()
  ssb_times = (ssb.keys()).toArray()
  ssb_times = ssb_times[sort(ssb_times)]
  mgi_times = (mgi.keys()).toArray()
  mgi_times = mgi_times[sort(mgi_times)]
  
  ;Make sure that we have the same time samples for each
  bad = where(ssb_times ne mgi_times, nbad)
  if (nbad gt 0) then begin
    print, 'ERROR: sunspot blocking and mg index have different time samples.'
    return, -1
  endif
  
  ;Make list to accumulate results
  data_list = List()
  
  ;Iterate over each time sample.
  n = n_elements(ssb_times) ;.count()
  for i = 0, n-1 do begin
    mjd = ssb_times[i] ;time of the current sample
    iso_time = mjd2iso_date(mjd)

    sb = ssb[mjd]
    mg = mgi[mjd]
    
    nrl2_tsi = compute_tsi(sb ,mg ,model_params) ;calculate TSI for given sb and mg
    ssi = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
    nrl2_ssi = bin_ssi(model_params, spectral_bins, ssi) ; SSI on the binned wavelength grid
    
    ;Create the resulting data structure.
    ; TODO Add bandcenters and bandwidths and nband to data structure
    struct = {nrl2_irradiance,      $
      mjd:    mjd,                  $
      iso:    iso_time,             $
      tsi:    nrl2_tsi.totirrad,    $
      tsiunc: nrl2_tsi.totirradunc, $
      ssi:    nrl2_ssi.nrl2bin,     $
      ssiunc: nrl2_ssi.nrl2binunc,  $
      ssitot: nrl2_ssi.nrl2binsum   $
    }

    data_list.add, struct
  endfor
  
  return, data_list
end
