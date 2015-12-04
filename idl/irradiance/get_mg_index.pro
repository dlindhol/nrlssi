;@***h* SOLAR_IRRADIANCE_FCDR/get_mg_index.pro
;
; NAME
;   get_mg_index
;
; PURPOSE
;   The get_mg_index.pro is a function that parses a time-series of the facular brightening index for the desired starting and ending date. 
;   
; DESCRIPTION
;   The get_mg_index.pro is a function that parses a time-series of the facular brightening index (actually, a proxy of the facular brightening index - Mg II) 
;   for the desired starting and ending date, and passes the results to the routine, process_irradiance.pro. 
;   Final data is parsed from LASP's time-series server, LaTiS, via an IDL net URL.
;      
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, in 'yyyy-mm-dd' format.
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), in 'yyyy-mm-dd' format.
;   final      - delegate to the LaTiS server for final released data.
;                  
; OUTPUTS
;   data       - an IDL list containing the modified Julian date index and the Mg II index
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
;   result=get_mg_index(ymd1,ymd2,final=final)
;
;@*****
function get_mg_index_from_latis_orig, ymd1, ymd2
  ;ymd: yyyy-mm-dd, ymd2 is inclusive
  ;If neither time is specified, return the entire dataset.
  ;If only the first time is specified, return only that day.
    
  has_t1 = n_elements(ymd1) eq 1
  has_t2 = n_elements(ymd2) eq 1
  
  ;LaTiS assumes that yyyy-MM-dd is midnight of that date so we need to add a 
  ;day to make the request inclusive.
  if has_t2 then end_date = mjd2iso_date(iso_date2mjdn(ymd2) + 1)
  
  ;construct the query string for the time constraints
  if has_t1 and has_t2 then query = '&time>=' + ymd1 + '&time<' + end_date   $
  else if has_t1 and not has_t2 then query = '&time=' + ymd1  $ ;TODO: probably won't match exactly
  else query = ''

  ;read the data from LaTiS as a 2D JSON array
  ;TODO: catch errors
  ;TODO: use read_latis_data
  netUrl = OBJ_NEW('IDLnetUrl')
  ;netUrl->SetProperty, URL_HOST  = 'localhost'
  ;netUrl->SetProperty, URL_PORT  = 8080
  netUrl->SetProperty, URL_HOST  = 'lisird-dev.lasp.colorado.edu'
  netUrl->SetProperty, URL_PORT  = 8090
  netURL->SetProperty, URL_PATH  = 'lisird3/latis/bremen_composite_mg_index_v4.jsona'
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
    mjd: 0l,     $
    index: 0.0d  $
  }
  
  ;number of time samples (one per day)
  n = data.count()
  
  ;construct array of structures to hold results
  result = replicate(struct, n)
  
  ;fill the data structures
  for i = 0, n-1 do begin
    sample = data[i]
    result[i].mjd = unix2mjd(double(sample[0])/1000.0) ;convert unix time (ms) to Modified Julian Date
    result[i].index = sample[1]
  endfor
  
  return, result
end

;TODO: support missing ymd2, return just that day or no upper bound (latest)?
function get_mg_index_from_latis, ymd1, ymd2, final=final, cycle=cycle, dev=dev
  ;add day to end time to make it inclusive
  end_date = mjd2iso_date(iso_date2mjdn(ymd2) + 1)
  
  ;get the dataset name
  if keyword_set(final) then dataset = 'nrl2_facular_brightening_v02r00'  $
  else if keyword_set(cycle) then dataset = 'nrl2_facular_brightening_cycle'  $
  else if keyword_set(dev) then dataset = 'bremen_composite_mg_index'  $
  else dataset = 'nrl2_facular_brightening'
  
  ;add query parameters
  query = 'convert(time,days since 1858-11-17)' ;convert times to MJD
  query += '&rename(time,MJD)' ;rename parameters to match the structures we expect here.
  
  ;get the data as a list of structures
  data = read_latis_data(dataset, ymd1, end_date, query=query)
  return, data
end


function get_mg_index, ymd1, ymd2, final=final, cycle=cycle, dev=dev
  ;ymd: yyyy-mm-dd, ymd2 is inclusive
  ;If neither time is specified, return the entire dataset.
  ;If only the first time is specified, return only that day.
  return, get_mg_index_from_latis(ymd1, ymd2, final=final, cycle=cycle, dev=dev)
end

