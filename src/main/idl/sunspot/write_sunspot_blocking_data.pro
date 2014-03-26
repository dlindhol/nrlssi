pro write_sunspot_blocking_data, sunspot_blocking_data
;sunspot_blocking_data: hash of structure by JDN
;  ssb_struct = {sunspot_blocking,  $
;    jdn:0l, version:'',    $
;    ssbt:0.0, dssbt:0.0,   $
;    ssbuv:0.0, dssbuv:0.0  $
;    
;  }
 
  ;Get the julian day naumers and sort them
  jdn = sunspot_blocking_data.keys()
  jdn_sorted = jdn[sort(jdn.toArray())]
  
  ;open output file
  ;TODO: better way to get version instead of putting in every record
  version = sunspot_blocking_data[jdn_sorted[0]].version
  start_date = jd2yymmdd(jdn_sorted[0])
  stop_date  = jd2yymmdd(jdn_sorted[-1])
  ;TODO: pad timestamp with 0s
  file = '/data/NRLSSI/SSB_USAF_' + start_date +'-'+ stop_date +'_'+ version +'.txt'
  openw, 8, file
  
  ;TODO: write header
;    fmt='("SSB :",I6," WITH AREA-DEPENDENT EXCESS:"," BOL=",F5.2," UV320=",F5.2)'
;    tt='   calc_spotindex.pro'
;    printf,8,systime(0),tt
;    printf,8,format=fmt,iyear,excess,excess320
  
  ;Iterate over sorted JDN
  for i = 0, n_elements(jdn_sorted)-1 do begin
    jdn = jdn_sorted[i]
    ymd = jd2yymmdd(jdn) ;TODO: consider .5 day offset
    
    s = sunspot_blocking_data[jdn]
    
    printf, 8, format='(I12,4F10.2)', ymd, s.ssbt, s.dssbt, s.ssbuv, s.dssbuv
  endfor

  close, 8
  
end
