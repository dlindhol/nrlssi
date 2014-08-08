;@***h* TSI_FCDR/process_sunspot_blocking.pro
; 
; NAME
;   process_sunspot_blocking.pro
;
; PURPOSE
;   The process_sunspot_blocking.pro procedure computes the sunspot blocking function from U.S. Air Force
;   White Light sunspot region data (obtained from a NOAA/NGDC web repository- point of contact: Bill Denig).
;
; DESCRIPTION
;   This routine is the main driver routine.  It calls a series of subroutines with the name/purpose:
;   get_sunspot_data.pro - aquire USAF white light sunspot region data from NOAA/NGDC web repository and store
;                          in a structure identified by index -> (jd, lat, lon, area, station)
;   group_by_day.pro     - group the USAF white light data by Julian date: jdn -> (jd, lat, lon, area, station)
;   
;   For each day of data, and for each sunspot measuring station, the (cosine-weighted) solar latitude, longitude, and 
;   area of each sunspot grouping is recorded. The sunspot blocking for each grouping is 
;   calculated (compute_sunspot_blocking.pro) and the total sunspot blocking function (total and uv) for each measuring 
;   station is the sum of the sunspot blocking for the individual groupings.
;   
;   The daily mean and standard deviation for all available stations is stored for the total sunspot blocking 
;   function (ssbt and dssbt) and for the uv sunspot blocking function (ssbuv and dssbuv).
;   
;   write_sunspot_blocking_data.pro - Outputs the mean and standard deviation daily sunspot blocking functions to ascii 
;                                     file ('SSB_USAF_(start_date)-(stop_date)_(version).txt') with the format: 
;                                     time (YYMMDD), ssbt, dssbt, ssbuv, dssbuv. 
;                                     Missing data identified by -999
;   
; INPUTS
;   year - four digit year (i.e. 1978) (TODO: update to time range args)
;   
; OUTPUTS
;   Outputs the mean and standard deviation daily sunspot blocking functions to ascii 
;   file ('SSB_USAF_(start_date)-(stop_date)_(version).txt') with the format: 
;   time (YYMMDD), ssbt, dssbt, ssbuv, dssbuv. 
;
; AUTHOR
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
;   04/09/2014 Initial Version prepared for NCDC
; 
; USAGE
;   process_sunspot_blocking,year
;
;@***** 
pro process_sunspot_blocking, ymd1, ymd2, desired_stations
  ;ymd2 is NOT inclusive, it represents midnight GMT - the start of the given day.
  ;ymd values for time range are expected to be dates of the form 'yyyy-mm-dd'.
  
  ;Process just one day if ymd2 is not provided.
  if n_elements(ymd2) eq 0 then ymd2 = ymd1
  
  ;TODO: optional stations arg to limit to one station, or array
  ;stations = List('LEAR','CULG','SVTO','RAMY','BOUL','MWIL','HOLL','PALE','MANI','ATHN')
  ;if stations not defined, use whatever is in the data

  version='v0.3'
  
  ;Use this as a fill value when there is no valid data.
  missing_value = !Values.F_NAN ;-999
  
  ;Get sunspot data for the given time range.
  ;Array of structures, one element per line.
  ;  struct = {jd:0.0, lat:0.0, lon:0.0, area:0.0, station:''}
  ;  index -> (jd, lat, lon, area, station)
  sunspot_data = get_sunspot_data(ymd1, ymd2)
  
  ;Group by Julian Day number
  ; jdn -> (jd, lat, lon, area, station)
  daily_sunspot_data = group_by_day(sunspot_data)  ;TODO: check jd rounding
  
  ;Convert start and stop dates to Julian Day Number (integer).
  ;TODO: test: handling leap year, .5 day offset, binning by utc day
  jd_start = iso_date2jdn(ymd1)
  jd_stop  = iso_date2jdn(ymd2) - 1 ;end time not inclusive
  
  ;Define Hash to hold final daily averaged results with JDN as key.
  sunspot_blocking_data = Hash()
  
  ;Iterate over days.
  for jdn = jd_start, jd_stop do begin
    ;Define struct to hold final daily averaged results
    ;Reset data values each time.
    sunspot_blocking_struct = {sunspot_blocking,  $
      jdn:0l,   $
      ssbt:0.0, dssbt:0.0,   $
      ssbuv:0.0, dssbuv:0.0,  $
      quality_flag:0  $
    }
    
    ;Set Julian Day Number
    sunspot_blocking_struct.jdn = jdn
    
    ;Process data if we have any for this day
    if daily_sunspot_data.hasKey(jdn) then begin
      ;Get the sunspot data for this day
      ssdata = daily_sunspot_data[jdn]
      ; i -> (jd, lat, lon, area, station)
      
      ;Adjust latitude
      ;TODO: use time of day to get more accurate solar latitude?
      B0 = get_solar_latitude(jdn)
      lat = ssdata.lat - B0
      
      ;Compute the total and uv sunspot blocking contribution for each sample
      ssbt  = compute_sunspot_blocking(ssdata.area, lat, ssdata.lon) ;array
      ssbuv = compute_sunspot_blocking_uv(ssdata.area, lat, ssdata.lon) ;array
      
      ;If the resulting value is NaN (from missing area) set quality flag
      imissing = where(~ FINITE(ssbt), nmissing)
      if nmissing gt 0 then sunspot_blocking_struct.quality_flag = 1 ;TODO: consider bit mask for multiple flags
      
      ;Group data by station and sum ssb from contributing sunspot groups.
      ;Hash: station -> ssb  with NaNs where area was missing
      ssbt_by_station  = group_and_sum(ssdata.station, ssbt)
      ssbuv_by_station = group_and_sum(ssdata.station, ssbuv)
      
      ;Average the results from all stations, drop NaNs
      ;TODO: weighted avg time? instead of assume all obs at noon
      ;IDL can't do mean ... on List so convert to array
    
    ;TODO: deal with only one sample, stddev of array of one is NaN
     ; nstn = ssbt_by_station.count() ;number of stations going into the average
      ;TODO: record how many stations went into avg
    ;good enough but lots of "Floating divide by 0"
    ;2009-10-22  0.00       NaN      0.00       NaN   1  - only one record and it had missing area
    
      ssbt_list = ssbt_by_station.values()
      ssbt_array = ssbt_list.toArray()
      sunspot_blocking_struct.ssbt  = mean(ssbt_array, /NaN)
      sunspot_blocking_struct.dssbt = stddev(ssbt_array, /NaN)
      
      ssbuv_list = ssbuv_by_station.values()
      ssbuv_array = ssbuv_list.toArray()
      sunspot_blocking_struct.ssbuv  = mean(ssbuv_array, /NaN)
      sunspot_blocking_struct.dssbuv = stddev(ssbuv_array, /NaN)
    endif else begin
      ;no data for this day, fill with missing value
      ;print, 'WARNING: No data produced for date: ' + strtrim(jd2iso_date(jdn),2)
      sunspot_blocking_struct.ssbt   = missing_value
      sunspot_blocking_struct.dssbt  = missing_value
      sunspot_blocking_struct.ssbuv  = missing_value
      sunspot_blocking_struct.dssbuv = missing_value
    endelse
    
    ;Add structure to result hash for this day.
    sunspot_blocking_data[jdn] = sunspot_blocking_struct
  endfor
  
  ;Write the results.
  file = '/data/NRLSSI/sunspot_blocking_' + ymd1 +'_'+ ymd2 +'_'+ version +'.txt'
  write_sunspot_blocking_data, sunspot_blocking_data, file
  
end
