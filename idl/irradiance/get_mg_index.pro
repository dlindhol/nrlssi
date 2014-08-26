function get_mg_index_from_latis, ymd1, ymd2
  ;ymd: yyyy-mm-dd
  ;If neither time is specified, return the entire dataset.
  ;If only the first time is specified, return only that day.
  
  ;Note: Source data have time stored as Julian Day Number (noon).
  
  
  ;construct the query string for the time constraints
  has_t1 = n_elements(ymd1) eq 1
  has_t2 = n_elements(ymd2) eq 1
  if has_t1 and has_t2 then query = '&time>=' + ymd1 + '&time<' + ymd2   $
  else if has_t1 and not has_t2 then query = '&time=' + ymd1  $  ;add 12 since composite_mg_index since it uses JD (noon) + 'T12:00:00'  $ 
  else query = ''

  ;read the data from LaTiS as a 2D JSON array
  ;TODO: catch errors
  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST  = 'localhost' ;'lisird-dev.lasp.colorado.edu' ;'localhost'
  netUrl->SetProperty, URL_PORT  = 8080
  netURL->SetProperty, URL_PATH  = 'lisird3/latis/nrlssi_mg_index.jsona'
  netURL->SetProperty, URL_QUERY = query
  lines = netURL->Get(/string_array) ;TODO: check for empty results
  OBJ_DESTROY, netUrl
  
  ;concatenate the json results into a single string
  s = ''
  for i = 0, n_elements(lines)-1 do s = s + lines[i]
  
  ;convert json array output to IDL List
  data = json_parse(s)
  
  ; Convert List to array of structs ;TODO: factor out as function?
  
  ;define the data structure
  struct = {mg_index,   $
    jdn: 0l,     $
    index: 0.0  $
  }
  
  ;number of time samples (one per day)
  n = data.count()
  
  ;construct array of structures to hold results
  result = replicate(struct, n)
  
  ;fill the data structures
  for i = 0, n-1 do begin
    sample = data[i]
    result[i].jdn = unix2jdn(double(sample[0])/1000.0) ;convert unix time (ms) to julian day number
    result[i].index = sample[1]
  endfor
  
  return, result
end



function get_mg_index, ymd1, ymd2
  ;ymd: yyyy-mm-dd
  ;If neither time is specified, return the entire dataset.
  ;If only the first time is specified, return only that day.
  return, get_mg_index_from_latis(ymd1, ymd2)
end

