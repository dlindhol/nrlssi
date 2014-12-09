;@***h* TSI_FCDR/get_sunspot_data.pro
; 
; NAME
;   get_sunspot_data.pro
;
; PURPOSE
;   Aquire U.S. Air Force white Light sunspot region data from a NOAA/NGDC web repository- point of contact: Bill Denig.
;   http://www.ngdc.noaa.gov/stp/space-weather/solar-data/solar-features/sunspot-regions/usaf_mwl/
;
; DESCRIPTION
;   This routine is called from the main driver, process_sunspot_blocking.pro. 
;   It accesses the above url and parses the given record into a data structure. Each record is for a sunspot group 
;   measurement. The time (YYMMDD), solar latitude and longitude, sunspot area, and station ID are parsed from each record.
;   
; INPUTS
;   year - four digit year (i.e. 1978) (TODO: update to time range args)
;   
; OUTPUTS
;   Data structure containing (for each record in the USAF data):
;   jd      - Julian Date (converted from yymmdd) 
;   lat     - latitude of sunspot group
;   lon     - longitude of sunspot group
;   area    - sunspot area
;   station - station name 
;
; AUTHOR
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
;   04/09/2014 Initial Version prepared for NCDC
; 
; USAGE
;   get_sunspot_data,year
;
;@***** 
function parse_line_orig, line

  ;Fail on short lines, e.g. strange character at end of file
  if (strlen(line) lt 80) then return, -1  ;TODO: log warning?

  ;          1         2         3         4         5         6         7
  ;01234567890123456789012345678901234567890123456789012345678901234567890123456789
  ;11080306 0110 S08W68 B           10984 BXO  2  1  30 080229.9 080229.8 009 2LEAR
  ;11080306 1855 S05W75 A           10984 AXX  1  1  20 0803 1.2 080229.8 010 2HOLL
  ;11080303 0650 S05E18 A           10984AAXX  1        0803 4.6 0803 4.6 004 3SVTO
  ;  yymmdd      latlon                            area                        stn_

  ;Parse the yymmdd date as Julian Date
  jd = yymmdd2jd(strmid(line,2,6))
  ;Note, if we only read date (00Z), jd will be x.5 which idl will round up when binning to jdn.
  ;  Thus the resulting JDN will be noon on the appropriate UTC day.
  ;TODO: test the assumption that it will always round up, precision concerns
  ;TODO: use time also, is it ever missing?
  
  ;Parse the latitude, get sign from hemisphere
  ;TODO: deal with missing?  if(xlat eq '  ') then xlat=' 0', will get format error otherwise
  lat = float(strmid(line,15,2))
  lathem = strmid(line,14,1)
  if (lathem eq 'S') then lat = -lat
  
  ;Parse the longitude, get sign from hemisphere
  ;TODO: deal with missing?  if(along eq '  ') then along=' 0', will get format error otherwise
  lon = float(strmid(line,18,2))
  lonhem = strmid(line,17,1)
  if(lonhem eq 'E') then lon = -lon
  ;east is negative!? doesn't really matter
  
  ;group, only used for output when a duplicate is found
  ;noaa=strmid(dumi,33,5)
  
  ;Parse sunspot area
  ;TODO: deal with missing?  if(iarea eq '    ') then iarea='-888'
  ;  skip record?
  ;  just count of parse error, catch and return -1?
  ;  invalidate all obs from that station for that day? since we need accumulation of all ss groups?
  ;  note some records have area = 0, assume 0 for missing?
  ;  compare obs from other stations
  area_string = strmid(line,48,4)
  if (area_string ne '    ') then area = float(area_string)  $
  else begin
    area = 0.0
    print, 'WARNING: No area define. Using 0. ' + line
    ;TODO: set quality flag
  endelse
  
  ;Station name
  station = strmid(line,76,4)
  
  ;Create result structure
  result = {   $
    jd:jd,     $
    lat:lat,   $
    lon:lon,   $
    area:area, $
    station:station  $
  }
  
  return, result
  
end

;-----------------------------------------------------------------------------
;Parse csv output from LaTiS
function parse_line, line

  vars = strsplit(line, ',', /EXTRACT)
  
  ;Parse the yymmdd date as Modified Julian Date
  mjd = yymmdd2mjd(vars[0])
  
  ;Parse the latitude, get sign from hemisphere
  ;TODO: deal with missing?  if(xlat eq '  ') then xlat=' 0', will get format error otherwise
  lat = double(vars[2])
  lathem = vars[1]
  if (lathem eq 'S') then lat = -lat
  
  ;Parse the longitude, get sign from hemisphere
  ;TODO: deal with missing?  if(along eq '  ') then along=' 0', will get format error otherwise
  lon = double(vars[4])
  lonhem = vars[3]
  if(lonhem eq 'E') then lon = -lon
  ;east is negative!? doesn't really matter
  
  ;Parse the sunspot group number
  group = fix(vars[5])
  
  ;Parse sunspot area, LaTiS will have replaced missing values with NaN
  ;We'll add a flag for it when we compute the average area.
  area = double(vars[6])
  
  ;Station name
  station = vars[7]
  
  ;Create result structure
  result = {       $
    mjd:mjd,       $
    lat:lat,       $
    lon:lon,       $
    group:group,   $
    area:area,     $
    station:station  $
  }
  
  return, result
end

;-----------------------------------------------------------------------------
;
;Read sunspot data from the NGDC usaf_mwl web site.
;e.g. http://www.ngdc.noaa.gov/stp/space-weather/solar-data/solar-features/sunspot-regions/usaf_mwl/usaf_solar-region-reports_2012.txt
function get_sunspot_data_ORIG, year

  url_path = 'stp/space-weather/solar-data/solar-features/sunspot-regions/usaf_mwl/usaf_solar-region-reports_' + strtrim(year,2) + '.txt'

  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST = 'www.ngdc.noaa.gov'
  ;netUrl->SetProperty, URL_PORT = port
  netURL->SetProperty, URL_PATH = url_path

  lines = netURL->Get(/string_array)

  OBJ_DESTROY, netUrl
  
  ;Make list to hold results
  records = List()
  
  ;Iterate through each line and parse into a data record
  for i = 0, n_elements(lines)-1 do begin
    ;This will return -1 if the line is not a valid data record.
    struct = parse_line(lines[i])
    ;Add valid data to the results list.
    if (size(struct, /type) eq 8) then records.add, struct
  endfor
  
  ;Return results as an array of structures.
  return, records.toArray()
end

;-----------------------------------------------------------------------------
;Read sunspot data from NGDC usaf_mwl data files.
;e.g. http://www.ngdc.noaa.gov/stp/space-weather/solar-data/solar-features/sunspot-regions/usaf_mwl/usaf_solar-region-reports_2012.txt
function get_sunspot_data_from_local_file, year
  ;TODO: time range?
  ;TODO: List of Hashes?

  ;Define the input data file name.
  ;TODO: get directly from ngdc web site?
  file = 'data/usaf_solar-region-reports_' + strtrim(year,2) + '.txt'
  openr, 1, file
  
  ;Make list to hold results
  records = List()
  
  ;Make sure each line is read in as a string by using a string variable.
  ;Otherwise, readf will read only the first field as a float.
  line = ''
  
  ;Read until we run out of lines.
  while ~ eof(1) do begin
    readf,1,line
    
    ;Create a data structure from each line.
    ;This will return -1 if the line is not a valid data record.
    struct = parse_line(line)
    ;Add valid data to the results list.
    if (size(struct, /type) eq 8) then records.add, struct
    
  endwhile
  
  ;close file
  close, 1
  
  ;Return results as an array of structures.
  return, records.toArray()
     
end

;-----------------------------------------------------------------------------
; Get data from LaTiS.
function get_sunspot_data_from_latis, ymd1, ymd2
  ;ymd2 is inclusive. 
  ;Since a datetime without time is typically interpreted as midnight (time = 00:00)
  ;we will manage the addition of one day internal to these algorithms.
  ;ymd values for time range are expected to be dates of the form 'yyyy-mm-dd'.

  ;LaTiS assume that yyyy-MM-dd is midnight of that date so we need to add a 
  ;day to make the request inclusive.
  end_date = mjd2iso_date(iso_date2mjdn(ymd2) + 1)

  ;Make LaTiS request for csv
  netUrl = OBJ_NEW('IDLnetUrl')
  netUrl->SetProperty, URL_HOST  = 'lisird-dev.lasp.colorado.edu' ;'localhost'
  netUrl->SetProperty, URL_PORT  = 8090
  netURL->SetProperty, URL_PATH  = 'lisird3/latis/usaf_mwl.csv'
  netURL->SetProperty, URL_QUERY = '&time>=' + ymd1 + '&time<' + end_date
  lines = netURL->Get(/string_array)
  ;buffer = netURL->Get(/buffer)
  OBJ_DESTROY, netUrl
  
  ;Make list to hold results
  records = List()
  
  ;Iterate through each line and parse into a data record
  ;TODO: use json?
  ;Skip header, start at 1
  for i = 1, n_elements(lines)-1 do begin
    ;This will return -1 if the line is not a valid data record.
    struct = parse_line(lines[i])
    ;Add valid data to the results list.
    if (size(struct, /type) eq 8) then records.add, struct
  endfor
  
  ;Return results as an array of structures.
  return, records.toArray()

end


;-----------------------------------------------------------------------------
; Use this routine to get USAF sunspot region data.
function get_sunspot_data, ymd1, ymd2, stations=stations
  data = get_sunspot_data_from_latis(ymd1, ymd2)
  
  ;Keep only requested stations
  if n_elements(stations) gt 0 then begin
    list = List() ;keep a list of records with station in stations
    for i=0, n_elements(data)-1 do begin
      station = data[i].station
      w = where(stations eq station, n)
      if n eq 1 then list.add, data[i]
    endfor
    
    data = list.toArray()
  endif
  
  return, data
end
