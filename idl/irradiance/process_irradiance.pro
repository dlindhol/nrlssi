;@***h* SOLAR_IRRADIANCE_FCDR/process_irradiance.pro
;
; NAME
;   process_irradiance
;
; PURPOSE
;   The process_irradiance.pro procedure calls a series of functions to compute the Total Solar Irradiance (TSI) and 
;   Solar Spectral Irradiance (SSI) using the NRLTSI2 and NRLSSI2 models.
;   
; DESCRIPTION
;   The process_irradiance.pro procedure calls a series of functions to compute the Total Solar Irradiance (TSI) and 
;   Solar Spectral Irradiance (SSI) using the NRLTSI2 and NRLSSI2 models.
;   
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, of the form 'yyyy-mm-dd'
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), of the form 'yyyy-mm-dd'.
;   final      - Data processing is delegated to the LaTiS server for accessing final released values of model inputs.
;   dev        - Data processing is delegated to processing routines for computing preliminary model input data. 
;   time_bin   - A value of 'year', 'month', or 'day' that defines the time-averaging performed for the given data records.
;               'day' is the default.
;   
; OUTPUTS
;   data       - A structure containing the irradiance data and the spectral bins:
;     mjd        - Modified Julian Date
;     iso        - iso 8601 formatted time
;     tsi        - Modeled Total Solar Irradiance
;     ssi        - Modeled Solar Spectral Irradiance (in wavelength bins)
;     ssitot     - Integral of the Modeled Solar Spectral Irradiance
;     nband      - number of spectral bands, for a variable wavelength grid, that the NRLSSI2 model bins 1 nm solar spectral irradiance onto.
;     bandcenter - the bandcenters (nm) of the variable wavelength grid.
;     bandwidth  - the bandwidths (delta wavelength, nm)  of the variable wavelength grid, centered on bandcenter.
;   
; AUTHOR
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;
; COPYRIGHT
;   THIS SOFTWARE AND ITS DOCUMENTATION ARE CONSIDERED TO BE IN THE PUBLIC
;   DOMAIN AND THUS ARE AVAILABLE FOR UNRESTRICTED PUBLIC USE. THEY ARE
;   FURNISHED "AS IS." THE AUTHORS, THE UNITED STATES GOVERNMENT, ITS
;   INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO WARRANTY,
;   EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE AND
;   DOCUMENTATION FOR ANY PURPOSE. THEY ASSUME NO RESPONSIBILITY (1) FOR
;   THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL
;   SUPPORT TO USERS.
;
; REVISION HISTORY
;   06/04/2015 Initial Version prepared for NCDC
;
; USAGE
;   result=process_irradiance(ymd1, ymd2, final=final, dev=dev, time_bin=time_bin)
;
;@*****

function process_irradiance, ymd1, ymd2, final=final, dev=dev, time_bin=time_bin, cycle=cycle

  ;Get the NRL2 model parameters
  model_params = get_model_params()

  ;Set up wavelength bands for summing 1 nm spectrum
  spectral_bins = get_spectral_bins()

  ;Get input data
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, final=final, dev=dev, cycle=cycle) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, final=final, cycle=cycle) ;MgII index data - facular brightening
  
  ;Look for missing days in Sunpot_blocking record (NEW OC)
;  missing = where(sunspot_blocking.quality_flag eq 1,nmissing) ;NEW OC
;  if nmissing gt 0 then test = interpolate_sunspot_blocking(sunspot_blocking,missing,dev=dev) ;NEW OC
    
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
  
  ;Convert to an array.
  irradiance_data = data_list.toArray()
  
  ;Construct resulting data structure, including the spectral bins.
  data = {wavelength: spectral_bins, data: irradiance_data}
  
  return, data
end
