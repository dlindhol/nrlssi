;Parse the given record into a data structure.
;Each record is for a sunspot group measurement.
function parse_line, line

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
  area = float(strmid(line,48,4))
  
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
;Read sunspot data from NGDC usaf_mwl data files.
;e.g. http://www.ngdc.noaa.gov/stp/space-weather/solar-data/solar-features/sunspot-regions/usaf_mwl/usaf_solar-region-reports_2012.txt
function get_sunspot_data, year
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
;TODO: look for duplicate records
    ;Add valid data to the results list.
    if (size(struct, /type) eq 8) then records.add, struct
    
  endwhile
  
  ;close file
  close, 1
  
  ;Return results as an array of structures.
  return, records.toArray()
     
end
