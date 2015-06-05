;@***h* SOLAR_IRRADIANCE_FCDR/remove_duplicate_records.pro
; 
; NAME
;   remove_duplicate_records.pro
;
; PURPOSE
;   Checks for duplicate sunspot station records in the USAF white light observations. Removes duplicate records if found.
;
; DESCRIPTION
;   Called by process_sunspot_blocking.pro
;   If duplicate records are found, reports the number of duplicates

;   
; INPUTS
;   ssdata_by_station - An IDL hash observations by that station:
;     mjd - Modified Julian Date 
;     lat - latitude of sunspot group
;     lon - longitude of sunspot group
;     group   - sunspot group number 
;     area - recorded sunspot area
;     station - station name 
;   
; OUTPUTS
;   result - an IDL hash (an IDL Hash (compound data type of key-value pair) where the key is the Julian Day Number
;            and the value is a List of records with duplicate records removed 
;   ndup   - an integer value of the number of duplicate records found (default = 0)
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
;   result=remove_duplicate_records(ssdata_by_station, ndup)
;
;@***** 
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
