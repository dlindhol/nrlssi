;These first three routines take a data structure (record) with the only assumption 
;that the first element is time in Modified Julian Days (MJD).
;The time will be converted to a new MJD that represents the desired time bin:
; year, month, or day.

function get_year_as_mjd_from_record, record
  ;Get the time and convert to iso (yyyy-mm-dd)
  time = mjd2iso_date(record.(0))
  
  ;Extract the year
  year = strmid(time, 0, 4) ;yyyy
  
  ;Set the day to July 1st
  iso = year + '-07-01'
  
  ;Convert to MJD
  mjd = iso_date2mjdn(iso)
  
  return, mjd
end

function get_year_month_as_mjd_from_record, record
  ;Get the time and convert to iso (yyyy-mm-dd)
  time = mjd2iso_date(record.(0))

  ;Extract the year and month
  ym = strmid(time, 0, 7) ;yyyy-mm
  
  ;Set the day to the 15th of the month
  iso = ym + '-15'

  ;Convert to MJD
  mjd = iso_date2mjdn(iso)
  
  return, mjd
end

function get_day_as_mjd_from_record, record
  ;Truncate to the current day
  mjd = fix(record.(0))
  
  return, mjd
end


;Average the given data records for the given time bins.
;The time bin must be specified as 'year', 'month', or 'day'.
;'day' is the default.
;The first element of the record structure is assumed to be time
;in Modified Julian Days (MJD).
;The second element of the record structure is assumed to be the
;value to be averaged.
;All other elements will be ignored.
;The result will be a Hash that maps the time (MJD) to the average for that time bin.

function bin_average, records, bin
  ;Assumes records is a list of structures
  ;  where the first element is time in Modified Julian Date (MJD)
  ;  and the second element is the value to be averaged.
  ;All other structure elements will be ignored.
  ;'bin' is currently either 'year' or 'month' or 'day'.
  ;The default is 'day'.
  
  ;Define the function for extracting the nominal time of a bin.
  case bin of
    'year':  function_name = 'get_year_as_mjd_from_record' 
    'month': function_name = 'get_year_month_as_mjd_from_record'
    'day':   function_name = 'get_day_as_mjd_from_record'
    else:    function_name = 'get_day_as_mjd_from_record' ;default to 'day'
  endcase
  
  ;Make a hash such that each time bin maps to an array of records for that year.
  grouped = group_by_function(records, function_name)
  
  ;Extract just the values for each group of records.
  f = lambda(rec: rec.(1)) ;extract the value from a record
  grouped_values = grouped.map(f)
  
  ;Average the values in the records for each time bin.
  g = lambda(xs: mean(xs)) ;average the array of values
  averaged = grouped_values.map(g)
  
  return, averaged
end
