;@***h* SOLAR_IRRADIANCE_FCDR/process_sunspot_blocking.pro
; 
; NAME
;   process_sunspot_blocking.pro
;
; PURPOSE
;   The process_sunspot_blocking.pro procedure computes the sunspot blocking function from U.S. Air Force
;   White Light sunspot region data (obtained from a NOAA/NGDC web repository via ftp access- point of contact: Bill Denig).
;
; DESCRIPTION
;   This routine computes the sunspot darkening index, which is passed by structure, 'sunspot_blocking_data', to the calling 
;   function, 'get_sunspot_blocking'. This routine calls a series of subroutines with the names and purposes, summarized below:
;   get_sunspot_data.pro - aquire USAF white light sunspot region data from NOAA/NGDC web repository and store
;                          in a structure, 'sunspot_data', identified by index -> (jd, lat, lon, area, station)
;                          An optional keyword, 'stations', is used to restrict data to a user-defined particular station(s).
;                          By default, all stations are used in computing the sunspot darkening index.
;   group_by_day.pro     - group the USAF white light data by Julian date: jdn -> (jd, lat, lon, area, station)
;                          Stored in structure, 'daily_sunspot_data'
;   get_solar_latitutude.pro - Obtains the ecliptic plane correction, B0, for the given day. The B0 factor is used to correct the
;                              heliocentric latitude of the sunspot grouping, 'lat' for an approximate +/- 7 degree annual 
;                              change in the ecliptic plane (the angle between the perpendicular of the line from the 
;                              earth center to the center of the Sun) and the angle of rotation of the Sun. The B0 correction is an 
;                              area projection (cosine weighting). The corrected solar latitude = latitude - B0
;   compute_sunspot_blocking.pro -  The delta change (reduction) in irradiance computed from the latitude/longitude and
;                                   sunspot area computed from the individual measurements of sunspot area for daily recorded
;                                   sunspot grouping(s) of a particular station.
;   group_and_sum.pro - The total delta change in irradiance due to sunspots is the sum of the sunspot blocking over each measuring station. 
;                       If a station is missing data for a particular sunspot grouping, a quality flag to indicate missing data is set.                                                      
;   write_sunspot_blocking_data.pro - If optional 'output_dir' keyword is defined, the sunspot darkening index, and its standard deviation 
;                                     of the is output to intermediate ascii file 
;                                     ('sunspot_blocking_YMD1_YMD2_VER.txt'), where time ranges specify start/end date of desired time range.
;                                     'VER' is a hardcoded development version value to help keep track of data output. Intermediate file
;                                     output used for QA analysis.
;                                     
;   Note**: Input time periods of YYYY-MM-DD format are internally converted to Modified Julian Date for these routines.
;                                     
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, in Modified Julian day (converted from 'yyyy-mm-dd' in main driver).
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), 
;   stations = stations - Optional keyword to restrict sunspot darkening index to specified monitoring stations in the USAF white light network.
;                         If omitted (default), all stations are included. Used for QA analysis.
;   output_dir=output_dir - Optional keyword to specify directory path to store sunspot darkening index in a text file. If omitted (default), output
;                           is not written to intermediate file. Used for QA analysis.  
;   
; OUTPUTS
;   sunspot_blocking_struct - a structure containing the following variables:
;   mjdn - the modified julian date (converted from YYYY-MM-DD format) 
;   ssbt - the sunspot darkening index (a mean value of the reporting stations)
;   dssbut - the standard deviation of the sunspot darkening index
;   quality flag - a value of 0 or 1 (1 = missing data); Used for QA analysis.
;
;   if optional keyword 'output_dir' is defined, an intermediate text file of the naming convention, 'sunspot_blocking_YMD1_YMD2_VER.txt',
;   contains the structure data listed above.  Used for QA monitoring. 
;
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
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
;   09/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   process_sunspot_blocking,ymd1,ymd2,stations=stations,output_dir=output_dir
;
;@***** 
function process_sunspot_blocking, ymd1, ymd2, stations=stations, output_dir=output_dir
  ;ymd2 is NOT inclusive, it represents midnight GMT - the start of the given day.
  ;ymd values for time range are expected to be dates of the form 'yyyy-mm-dd'.
  
  ;use a development version to help keep track of data output
  version='v0.4'
  
  ;Process just one day if ymd2 is not provided.
  if n_elements(ymd2) eq 0 then ymd2 = ymd1
  
  ;Use this as a fill value when there is no valid data.
  fill_value = !Values.F_NAN ;-999
  
  ;Get sunspot data for the given time range.
  ;Array of structures, one element per line.
  ;  struct = {mjd:0.0, lat:0.0, lon:0.0, area:0.0, station:''}
  ;  index -> (mjd, lat, lon, area, station)
  sunspot_data = get_sunspot_data(ymd1, ymd2, stations=stations)
  
  ;Group by Modified Julian Day Number (MJD rounded down)
  ; mjdn -> (mjd, lat, lon, area, station)
  daily_sunspot_data = group_by_day(sunspot_data)

  ;Convert start and stop dates to Modified Julian Day Number (integer).
  mjd_start = iso_date2mjdn(ymd1)
  mjd_stop  = iso_date2mjdn(ymd2) - 1 ;end time from get_sunspot_data not inclusive
  
  ;Number of time samples (days)
  n = mjd_stop - mjd_start + 1
  
  ;Define struct to hold final daily averaged results
  sunspot_blocking_struct = {sunspot_blocking,  $
    mjdn:0l,   $
    ssbt:0.0, dssbt:0.0,   $
    ssbuv:0.0, dssbuv:0.0,  $
    quality_flag:0  $
  }
    
  ;Define array of structures to hold final daily averaged results for each day.
  sunspot_blocking_data = replicate(sunspot_blocking_struct, n)
  
  ;Iterate over days.
  for i = 0, n-1 do begin
    mjdn = i + mjd_start
    
    ;Set Modified Julian Day Number
    sunspot_blocking_data[i].mjdn = mjdn
    
    ;Process data if we have any for this day
    if daily_sunspot_data.hasKey(mjdn) then begin
      ;Get the sunspot data for this day
      ssdata = daily_sunspot_data[mjdn]
      ; i -> (mjd, lat, lon, area, station)
      
      ;Adjust latitude
      ;TODO: use time of day to get more accurate solar latitude?
      B0 = get_solar_latitude(mjdn + 2400000.5) ;convert to Julian Date
      lat = ssdata.lat - B0
      
      ;Compute the total and uv sunspot blocking contribution for each sample
      ssbt  = compute_sunspot_blocking(ssdata.area, lat, ssdata.lon) ;array
      ssbuv = compute_sunspot_blocking_uv(ssdata.area, lat, ssdata.lon) ;array
      
      ;If the resulting value is NaN (from missing area) set quality flag
      imissing = where(~ FINITE(ssbt), nmissing)
      if nmissing gt 0 then sunspot_blocking_data[i].quality_flag = 1 ;TODO: consider bit mask for multiple flags
      
      ;Group data by station and sum ssb from contributing sunspot groups.
      ;Hash: station -> ssb  with NaNs where area was missing replaced with 0
      ssbt_by_station  = group_and_sum(ssdata.station, ssbt);, /nan_as_zero)
      ssbuv_by_station = group_and_sum(ssdata.station, ssbuv, /nan_as_zero)
      
      ;Average the results from all stations, drop NaNs
      ;TODO: weighted avg time? instead of assume all obs at noon
      ;IDL can't do mean ... on List so convert to array
    
    ;TODO: deal with only one sample, stddev of array of one is NaN
      ; nstn = ssbt_by_station.count() ;number of stations going into the average
      ;TODO: record how many stations went into avg
      ;good enough but lots of "Floating divide by 0" illegal operand
    
      ssbt_list = ssbt_by_station.values()
      ssbt_array = ssbt_list.toArray()
      sunspot_blocking_data[i].ssbt  = mean(ssbt_array, /NaN)
      sunspot_blocking_data[i].dssbt = stddev(ssbt_array, /NaN)
      
      ssbuv_list = ssbuv_by_station.values()
      ssbuv_array = ssbuv_list.toArray()
      sunspot_blocking_data[i].ssbuv  = mean(ssbuv_array, /NaN)
      sunspot_blocking_data[i].dssbuv = stddev(ssbuv_array, /NaN)
    endif else begin
      ;no data for this day, fill with missing value
      sunspot_blocking_data[i].ssbt   = fill_value
      sunspot_blocking_data[i].dssbt  = fill_value
      sunspot_blocking_data[i].ssbuv  = fill_value
      sunspot_blocking_data[i].dssbuv = fill_value
    endelse
    
  endfor  
  
  ;Write the results if output_dir is specified
  if n_elements(output_dir) eq 1 then begin
    file = output_dir + '/sunspot_blocking_' + ymd1 +'_'+ ymd2 +'_'+ version +'.txt'
    write_sunspot_blocking_data, sunspot_blocking_data, file
  endif
  
  return, sunspot_blocking_data
end
