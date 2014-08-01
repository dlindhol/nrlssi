;@***h* TSI_FCDR/get_ssb_by_station.pro
; 
; NAME
;   get_ssb_by_station.pro
;
; PURPOSE
;   Compute the sunspot blocking function from the given sunspot data.
;
; DESCRIPTION
;   This routine is called from the main driver, process_sunspot_blocking.pro. 
;   It first sorts the UTC-binned sunspot area data by station.  If 'stations',: optional list of stations to use,
;   otherwise the default is to use whatever stations are in the data.
;   An iterative loop over each station performs the following tasks:
;   apparent solar latitude of sunspot = solar latitude - (TODO? are these geocentric coordinates?)
;   
;   For each day of data, and for each sunspot measuring station, the (cosine-weighted) solar latitude, longitude, and 
;   area of each sunspot grouping is recorded. The sunspot blocking for each grouping is 
;   calculated (compute_sunspot_blocking.pro) and the total sunspot blocking function (total and uv) for each measuring 
;   station is the sum of the sunspot blocking for the individual groupings.
;   
;   The daily mean and standard deviation for all available stations is stored for the total sunspot blocking 
;   function (ssbt and dssbt) and for the uv sunspot blocking function (ssbuv and dssbuv)
;   It takes the USAF white light sunspot data (binned by index) from get_sunspot_data.pro and bins the 
;   data by UTC time. 
;   
; INPUTS
;   sunspot_data - Data structure containing (for each record in the USAF data; data grouped by UTC time):
;                  jd - Julian Date (converted from yymmdd) 
;                  lat - latitude of sunspot group
;                  lon - longitude of sunspot group
;                  area - sunspot area
;                  station - station name four digit year (i.e. 1978) (TODO: update to time range args)
;   
; OUTPUTS
;   Returns a Hash where the key is the Julian Day Number and the value is a List of records for that day.  The list
;   of records is defined above under the heading 'Inputs'. 
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
;   get_ssb_by_station,sunspot_data,stations,uv=uv
;
;@***** 
;Compute the sunspot blocking from the given sunspot data.
;
;Set uv keyword to use the uv algorithm
function get_ssb_by_station, sunspot_data, stations, uv=uv
;TODO: factor out station logic
  ;Group by station
  station_data = group_structures_by_tag(sunspot_data, 'station')
  ; station -> (jd, lat, lon, area, station)
  ;TODO: deal with empty results (-1)
  
  ;If we weren't given a list of stations, use those in the data.
  if n_elements(stations) eq 0 then stations = station_data.keys()
  
  ;hash for ssb results for each station
  ssb_by_station = Hash()

  ;Iterate over stations
  for istn = 0, n_elements(stations)-1 do begin
    stn = stations[istn]  ;station name: key to station_data hash
    ssdata = station_data[stn]
    
    ;Iterate over samples and accumulate total ssb for this station
    ssb = 0.0
    for i = 0, n_elements(ssdata)-1 do begin
      s = ssdata[i]
      lat = s.lat - get_solar_latitude(s.jd)  ;apply B0 lat correction ;TODO: avoid calling for every iteration? but using time of observation, not just day
      lon = s.lon
      area = s.area
;TODO: flag if area is missing, no place for it in curernt return type
;note, previously set missing area to 0, now NaN - ssb is then NaN but we want it assuming 0 for missing
;TODO: look for duplicate records
      
      ;Compute the sunspot blocking for each sample.
      if keyword_set(uv) then ssb += compute_sunspot_blocking_from_area_uv(area, lat, lon) $
      else ssb += compute_sunspot_blocking_from_area(area, lat, lon)
    endfor
    
    ;add accumulated ssb for this station to the result
    ssb_by_station[stn] = ssb
  endfor
  
  return, ssb_by_station
end
