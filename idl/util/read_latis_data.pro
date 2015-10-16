;@***h* SOLAR_IRRADIANCE_FCDR/read_latis_data.pro
;
; NAME
;   read_latis_data
;
; PURPOSE
;   The read_latis_data.pro is a function that gets data from the LASP Time Series Server as a list of structures
;
; DESCRIPTION
;   The read_latis_data.pro is a function that gets data from the LASP Time Series Server as a list of structures
;   Data is parsed from LASP's time-series server, LaTiS, via an IDL net URL.
;
; INPUTS
;   dataset    - The name of the dataset
;   start_time - starting time range to aquire the data, in 'yyyy-mm-dd' format.
;   end_time   - ending time range to aquire the data, in 'yyyy-mm-dd' format.
;   host       - name of the server host
;   port       - the port on the server machine
;   base_path  - Directory path on server to the dataset
;   query      - query parameters used to convert time or rename parameters to match the structures in LaTiS.
;
; OUTPUTS
;   list       - an IDL list containing the dataset values
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
;   result=read_latis_data(dataset, start_time, end_time, host=host, port=port, base_path=base_path, query=query)
;
;@*****
function read_latis_data, dataset, start_time, end_time, host=host, port=port, base_path=base_path, query=query
  ;TODO: consider complex datasets (nested functions)
  ;TODO: error handling
  ;TODO: support authentication
 
  
;   if not keyword_set(host)      then host = 'localhost'
;   if not keyword_set(port)      then port = 8080
  if not keyword_set(host)      then host = 'lisird-dev.lasp.colorado.edu'
  if not keyword_set(port)      then port = 8090
  if not keyword_set(base_path) then base_path = 'lisird3/latis'
;  if not keyword_set(host)      then host = 'lasp.colorado.edu'
;  if not keyword_set(port)      then port = 80
;  if not keyword_set(base_path) then base_path = 'lisird/latis'
  if n_elements(query) gt 0     then query = '&' + query else query=''

  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST  = host
  netUrl->SetProperty, URL_PORT  = port
  netURL->SetProperty, URL_PATH  = base_path + '/' + dataset + '.json'
  netURL->SetProperty, URL_QUERY = '&time>=' + start_time + '&time<' + end_time + query
  lines = netURL->Get(/string_array)
  OBJ_DESTROY, netUrl

  ;combine all the lines into a single string
  ;json = lines.Reduce(Lambda(x,y: x+y)) ;requires IDL 8.4
  json = ''
  for i = 0, n_elements(lines)-1 do json += lines[i]

  ;parse the json response
  data = json_parse(json, /TOSTRUCT)
  ;Outer struct with dataset name.
  ;Inner struct with "samples (for the LaTiS Function)
  ;Then just a list of Structs with an element for each parameter. Return that.
  list = data.(0).(0)
  return, list

end
