function read_latis_data, dataset, start_time, end_time, host=host, port=port, base_path=base_path, query=query
  ;Times will be converted to modified julian date.
  ;TODO: consider complex datasets (nested functions)
  ;TODO: error handling
  ;TODO: support authentication
  
  if not keyword_set(host)      then host = 'lisird-dev'
  if not keyword_set(port)      then port = 8090
  if not keyword_set(base_path) then base_path = 'lisird3/latis'
  if n_elements(query) gt 0     then query = '&' + query else query=''

  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST  = host
  netUrl->SetProperty, URL_PORT  = port
  netURL->SetProperty, URL_PATH  = base_path + '/' + dataset + '.json'
  netURL->SetProperty, URL_QUERY = '&time>=' + start_time + '&time<' + end_time + query
  lines = netURL->Get(/string_array)
  OBJ_DESTROY, netUrl

  ;combine all the lines into a single string
  json = lines.Reduce(Lambda(x,y: x+y))

  ;parse the json response
  data = json_parse(json, /TOSTRUCT)
  ;Outer struct with dataset name.
  ;Inner struct with "samples (for the LaTiS Function)
  ;Then just a list of Structs with an element for each parameter. Return that.
  list = data.(0).(0)
  return, list

end
