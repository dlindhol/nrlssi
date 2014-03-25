;Compute the sunspot blocking from the given sunspot data.
;stations: optional list of stations to use,
;  otherwise use whatever is in the data.
;Set uv keyword to use the uv algorithm
function get_ssb_by_station, sunspot_data, stations, uv=uv

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
      lat = s.lat - get_solar_latitude(s.jd)  ;apply B0 lat correction
      lon = s.lon
      area = s.area
      
      ;Compute the sunspot blocking for each sample.
      if keyword_set(uv) then ssb += compute_sunspot_blocking_uv(area, lat, lon) $
      else ssb += compute_sunspot_blocking(area, lat, lon)
    endfor
    
    ;add accumulated ssb for this station to the result
    ssb_by_station[stn] = ssb
  endfor
  
  return, ssb_by_station
end
