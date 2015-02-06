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
;   ymd2       - ending time range respective to midnight GMT of the given day  
;   stations = stations - Optional keyword to restrict sunspot darkening index to specified monitoring stations in the USAF white light network.
;                         If omitted (default), all stations are included. Used for QA analysis.
;   output_dir=output_dir - Optional keyword to specify directory path to store sunspot darkening index in a text file. If omitted (default), output
;                           is not written to intermediate file. Used for QA analysis.  
;   
; OUTPUTS
;   sunspot_blocking_struct - a structure containing the following variables:
;     mjdn - the modified julian date 
;     ssbt - the sunspot darkening index (a mean value of the reporting stations)
;     dssbut - the standard deviation of the sunspot darkening index of the reporting stations
;     quality flag - a value of 0 or 1 (1 = missing data); Used for QA analysis.
;
;   if optional keyword 'output_dir' is defined, an intermediate text file of the naming convention, 'sunspot_blocking_YMD1_YMD2_VER.txt',
;   contains the structure data listed above, where version is a defined developmental version - Used for QA monitoring. 
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
;   01/14/2015 Initial Version prepared for NCDC
; 
; USAGE
;   process_sunspot_blocking,ymd1,ymd2,stations=stations,output_dir=output_dir
;
;@***** 
function process_sunspot_blocking, ymd1, ymd2, stations=stations, output_dir=output_dir
  ;ymd2 is inclusive. 
  ;Since a datetime without time is typically interpreted as midnight (time = 00:00)
  ;we will manage the addition of one day internal to these algorithms.
  ;ymd values for time range are expected to be dates of the form 'yyyy-mm-dd'.
  ;TODO: assert that time format is valid
  
  ;use a development version to help keep track of data output
  ;set to 1.0 for final release
  version='v0.15'
  
  ;TODO: error if ymd1 not provided
  
  ;Process just one day if ymd2 is not provided.
  ;TODO: or default to 'now'?
  if n_elements(ymd2) eq 0 then ymd2 = ymd1
  
  ;Define default set of stations here to be consistent with Judith's data.
  ;TODO: allow use of all stations, set these defaults at a higher level?
  ;if n_elements(stations) eq 0 then stations = ['LEAR','CULG','SVTO','RAMY','BOUL','MWIL','HOLL','PALE','MANI','ATHN']
  if n_elements(stations) eq 0 then stations = ['LEAR','CULG','SVTO','RAMY','BOUL','HOLL','PALE','MANI','ATHN']
  
  ;Get sunspot data for the given time range.
  ;Array of structures, one element per sunspot group observation.
  ;  struct = {mjd:0.0, lat:0.0, lon:0.0, group:0, area:0.0, station:''}
  sunspot_data = get_sunspot_data(ymd1, ymd2, stations=stations)
  
  ;Group by Modified Julian Day Number (MJD rounded down).
  ;Note, the original mjd in the structure will maintain the time component
  ;but we are assuming that each sunspot group is observed only once per day per station.
  ;Our duplicate record detection should find any exceptions.
  ; mjdn -> (mjd, lat, lon, group, area, station)
  daily_sunspot_data = group_by_day(sunspot_data)

  ;Convert start and stop dates to Modified Julian Day Number (integer)
  ;to simplify internal time management.
  mjd_start = iso_date2mjdn(ymd1)
  mjd_stop  = iso_date2mjdn(ymd2)
  
  ;Number of time samples (days)
  n = mjd_stop - mjd_start + 1
  
  ;Define the structure to hold a final daily averaged result.
  sunspot_blocking_struct = {sunspot_blocking,  $
    mjdn:0l,  $
    ssbt:0.0d, dssbt:0.0d,   $
;    ssbuv:0.0d, dssbuv:0.0d,  $
    quality_flag:0  $
  }
    
  ;Define array of structures to hold final daily averaged results for all day.
  sunspot_blocking_data = replicate(sunspot_blocking_struct, n)
  
  ;Iterate over days.
  for i = 0, n-1 do begin
    ;Modified Julian Day Number for this day.
    mjdn = i + mjd_start
    
    ;Set Modified Julian Day Number in the result.
    sunspot_blocking_data[i].mjdn = mjdn
    
    ;Initialize quality flag bits.
    MISSING_AREA_BIT = 0
    DUPLICATE_BIT = 0
    
    ;Process data if we have any for this day
    if daily_sunspot_data.hasKey(mjdn) then begin
      ;Get the sunspot data for this day: array of structures
      ssdata = daily_sunspot_data[mjdn]
      ; i -> (mjd, lat, lon, group, area, station)
      
      ;Make a Hash mapping station name to an array of observations by that station.
      ;Note, this is one day's worth of data.
      ; station -> (i -> (mjd, lat, lon, group, area, station))
      ssdata_by_station = group_by_tag(ssdata, 'station')
      
      ;TODO: sanity check that all times (mjd) are the same for a given station
      
      ;Remove duplicate records. Set a flag if any were found.
      ssdata_by_station = remove_duplicate_records(ssdata_by_station, ndup)
      if ndup ne 0 then DUPLICATE_BIT = 1
      
      ;Adjust latitude
      ;TODO: use time of day to get more accurate solar latitude?
      B0 = get_solar_latitude(mjdn + 2400000.5) ;uses Julian Date
      ;lat = ssdata.lat - B0
      
      ;Create Hash to hold sum of all sunspot group contribution to blocking for each station.
      ssbt_by_station  = Hash()
;      ssbuv_by_station = Hash()
      
      ;Compute the total and uv sunspot blocking contribution for each record/observation/sunspot group.
      ;Records with missing area will result in a ssb of NaN.
      ;Compute sums for each station. Treat missing areas as zero but set a flag.
      ;This is still grouped by station in a Hash. 
      ;  station -> ssb
      foreach records, ssdata_by_station, station do begin
        ;Note, these are all arrays, one element per record
        area = records.area
        lat  = records.lat - B0
        lon  = records.lon
        ssbt  = compute_sunspot_blocking(area, lat, lon)
;        ssbuv = compute_sunspot_blocking_uv(area, lat, lon)
 
        ;TODO: also compute total area for each station?

        ;Handle missing values.
        ;If any of the records had a missing area, assume it is zero and set a flag
;        ;Note, if ssbt has a missing value, so will ssbuv.
        imissing = where(~ FINITE(ssbt), nmissing)
        ;Drop any station with all values missing (e.g. MWIL) but don't set the flag since it doesn't affect the data
        if nmissing eq n_elements(ssbt) then begin
          print, 'WARNING: All areas missing on day ' + mjd2iso_date(mjdn) + ' for station: ' + station
          continue ;skip to the next station
        endif else if nmissing gt 0 then MISSING_AREA_BIT = 1  ;set flag
       
        ;Sum the total ssb contribution from all the sunspot groups observed by this station on this day.
        ;Missing values will be treated as 0. A quality flag is set above.
        ssbt_by_station[station]  = total(ssbt,  /NaN) ;treat NaNs as 0
;        ssbuv_by_station[station] = total(ssbuv, /NaN) ;treat NaNs as 0
      endforeach
      
      ;Average the results from all stations.
      ;TODO: record how many stations went into avg?
      station_count = ssbt_by_station.count()
      if station_count eq 0 then begin
        ;e.g. 1981-12-03 has only MWIL all with missing area
        print, 'WARNING: No sunspot records with valid areas found for day ' + mjd2iso_date(mjdn)
      endif else begin
        ;TODO: deal with only one sample, stddev of array of one is NaN
        ssbt_list = ssbt_by_station.values()
        ssbt_array = ssbt_list.toArray() ;IDL can't do mean ... on List so convert to array
        sunspot_blocking_data[i].ssbt  = mean(ssbt_array, /double)
        sunspot_blocking_data[i].dssbt = stddev(ssbt_array, /double)
      
;        ssbuv_list = ssbuv_by_station.values()
;        ssbuv_array = ssbuv_list.toArray() ;IDL can't do mean ... on List so convert to array
;        sunspot_blocking_data[i].ssbuv  = mean(ssbuv_array, /double)
;        sunspot_blocking_data[i].dssbuv = stddev(ssbuv_array, /double)
      endelse
      
      ;Compute the quality flag based on the bits set above.
      sunspot_blocking_data[i].quality_flag = MISSING_AREA_BIT + 2 * DUPLICATE_BIT
      
    endif else begin
      ;no data for this day, assume no sunspots thus ssb = 0 (as initialized above)
      print, 'WARNING: No sunspot records found for day ' + mjd2iso_date(mjdn)
    endelse
    
  endfor  ;loop over days
  
  ;Write the results if output_dir is specified
  if n_elements(output_dir) eq 1 then begin
    file = output_dir + '/sunspot_blocking_' + ymd1 +'_'+ ymd2 +'_'+ version +'.txt'
    write_sunspot_blocking_data, sunspot_blocking_data, file
  endif
  
  return, sunspot_blocking_data
end
