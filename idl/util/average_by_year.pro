function get_year_from_record, record
  ;assumes first element is an iso formatted time: yyyy-MM-dd...
  iso = record.(0)
  year = (strsplit(iso, "-", /extract))[0]
  
  return, fix(year) ;make it an int
end

function compute_mean_from_records, records ;array
  ;assume the second structure element is the value to be averaged
  list = list(records) ;convert array to list
  values = list.map(lambda(rec : rec.(1))) ;list of values
  average = mean(values.toarray())
end

function average_by_year, records
  ;Assumes an array of structures
  ;  where the first element is an iso formatted time
  ;  and the second element is the value to be averaged.
  ;All other elements will be ignored.
  
  ;TODO: include stddev, count, ...?
  
  ;Make a hash such that each year maps to an array of records for that year.
  grouped = group_by_function(records, 'get_year_from_record')
  
  ;Average the values in the records for each year.
;  struct_to_value = lambda(st : st.(1)) ;get the value (2nd element) out of a structure
;  list_to_array = lambda(list : list.map(struct_to_value)
;  f = lambda(x : mean(x.map(struct_to_value).toarray())) ;given a list of records (x), expose the value of each record as a double and compute the mean
  averaged = grouped.map('compute_mean_from_records')
print,'*** '+averaged
  return, averaged
end
