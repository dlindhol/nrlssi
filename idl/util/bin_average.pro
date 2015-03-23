function get_year_from_record, record
  ;as 'yyyy'
  ;assumes first element is an iso formatted time: yyyy-mm-dd...
  year = strmid(record.(0), 0, 4)
  return, year
end

function get_year_month_from_record, record
  ;as 'yyyy-mm'
  ;assumes first element is an iso formatted time: yyyy-MM-dd...
  ym = strmid(record.(0), 0, 7)
  return, ym
end

function get_ymd_from_record, record
  ;as 'yyyy-mm-dd'
  ;assumes first element is in MJD units
  time = mjd2iso_date(record.(0))
  ymd = strmid(time, 0, 10)
  return, ymd
end


;function average_by_year, records
function bin_average, records, bin
  ;Assumes records is an array of structures
  ;  where the first element is an iso formatted time with hyphens (yyyy-MM-dd...)
  ;  and the second element is the value to be averaged.
  ;All other structure elements will be ignored.
  ;'bin' is currently either 'year' or 'month' or 'day'
  
  ;TODO: assume times are in mjd?
  ;TODO: allow either list or array
  ;TODO: include stddev, count, ...?
  
  ;Define the function for extracting the appropriate portion of the date
  case bin of
    'year':  function_name = 'get_year_from_record' 
    'month': function_name = 'get_year_month_from_record'
    'day':   function_name = 'get_ymd_from_record'
    else: print, "ERROR: bin_average requires a time bin of 'year' or 'month' or 'day'."
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
