
function make_sunspot_record_hash_code, record
  ;records should already have same mjd and station so don't need to include those
  ;;but might as well for consistency?
  ;(mjd, lat, lon, group, area, station)
  ;Note, missing group will be -999
  ;Account for missing area = NaN, can't have hash key = NaN
  
  group = record.group
  area = replace_nan_with_value(record.area, 0.0)
  lat = record.lat
  lon = record.lon
  
  ;Compute a (hopefully) unique value from the parameters
  hc = group * 1009 + area * 1013 + lat * 1019 + lon * 1021

  return, hc
end


function remove_duplicate_records, ssdata_by_station, ndup
  ;Assumes that these are already for the same day.
  ;;TODO: check for multiple records for one day, diff time
  ;station -> (i -> (mjd, lat, lon, group, area, station))
  ;Uses ndup to return the number of duplicat records found.
  ndup = 0
  
  ; Hash to hold results - same as input but with duplicate records removed.
  result = Hash()
  
  ;Do for each station.
  foreach station, ssdata_by_station.keys() do begin
    records = ssdata_by_station[station]

    ;TODO: use group_by, too bad we can't pass the hash function as an arg - use call_function?!
    ;create a hash code of the key components
    ;get array of matching records, any length > 1 is a duplicate
    ;keep only first to remove dups
    hash_function = 'make_sunspot_record_hash_code'
    hash = group_by_function(records, hash_function)
    
    ;If the value (array) of any key has more than one element, we have duplicates.
    ;Reconstruct the input data without the duplicates.
    foreach value, hash.Values() do begin
      if (n_elements(value) gt 1) then begin 
        ndup += 1  ;increment duplication counter
      endif
      if (result.HasKey(station)) then result[station] = [temporary(result[station]), value[0]]  $ ;append to result, keep only first record
      else result[station] = [value[0]]  ;new array
    endforeach
    
  endforeach

  return, result
end
