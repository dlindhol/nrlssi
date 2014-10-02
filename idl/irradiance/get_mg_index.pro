;@***h* SOLAR_IRRADIANCE_FCDR/get_mg_index.pro
;
; NAME
;   get_mg_index.pro
;
; PURPOSE
;   The get_mg_index.pro is a function that parses a time-series of the facular brightening index for the desired starting and ending date. 
;   
; DESCRIPTION
;   The get_mg_index.pro is a function that parses a time-series of the facular brightening index for the desired starting and ending date, 
;   that is passed to the routine from the main driver, nrl_2_irradiance.pro. The data is parsed from LASP's time-series server, LaTiS, via
;   an IDL net URL.
;   The output is returned to the main driver via a structure containing time and mg II index (the Mg II index is the proxy used to 
;   define the facular brightening index).
;      
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, in 'yyyy-mm-dd' format.
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), in 'yyyy-mm-dd' format.
;                  
; OUTPUTS
;   result - a structure containing the following variables:
;   jdn - the modified Julian date 
;   index - the Mg II index
;     
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
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
;   09/08/2014 Initial Version prepared for NCDC
;
; USAGE
;   get_mg_index,ymd1,ymd2
;
;@*****
function get_mg_index_from_latis, ymd1, ymd2
  ;ymd: yyyy-mm-dd, ymd2 is inclusive
  ;If neither time is specified, return the entire dataset.
  ;If only the first time is specified, return only that day.
    
  ;LaTiS assume that yyyy-MM-dd is midnight of that date so we need to add a 
  ;day to make the request inclusive.
  end_date = mjd2iso_date(iso_date2mjdn(ymd2) + 1)
  
  ;construct the query string for the time constraints
  has_t1 = n_elements(ymd1) eq 1
  has_t2 = n_elements(ymd2) eq 1
  if has_t1 and has_t2 then query = '&time>=' + ymd1 + '&time<' + end_date   $
  else if has_t1 and not has_t2 then query = '&time=' + ymd1  $  ;add 12 since composite_mg_index since it uses JD (noon) + 'T12:00:00'  $ 
  else query = ''

  ;read the data from LaTiS as a 2D JSON array
  ;TODO: catch errors
  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST  = 'lisird-dev.lasp.colorado.edu' ;'localhost'
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
  ;ymd: yyyy-mm-dd, ymd2 is inclusive
  ;If neither time is specified, return the entire dataset.
  ;If only the first time is specified, return only that day.
  return, get_mg_index_from_latis(ymd1, ymd2)
end

