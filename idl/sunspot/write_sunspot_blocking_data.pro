pro write_sunspot_blocking_data, sunspot_blocking_data, file
;sunspot_blocking_data: hash of structure by JDN
;  ssb_struct = {sunspot_blocking,  $
;    jdn:0l,  $
;    ssbt:0.0, dssbt:0.0,   $
;    ssbuv:0.0, dssbuv:0.0, $
;    quality_flag:0         $
;  }

;TODO: test if sunspot_blocking_data is empty
 
  ;Get the julian day numbers and sort them
  ;TODO: 8.3 has OrderedHash
  jdn = sunspot_blocking_data.keys()
  jdn_sorted = jdn[sort(jdn.toArray())]
  
  ;open output file
  openw, 8, file
  
  ;TODO: write header
;    fmt='("SSB :",I6," WITH AREA-DEPENDENT EXCESS:"," BOL=",F5.2," UV320=",F5.2)'
;    tt='   calc_spotindex.pro'
;    printf,8,systime(0),tt
;    printf,8,format=fmt,iyear,excess,excess320
  
  ;Iterate over sorted JDN
  for i = 0, n_elements(jdn_sorted)-1 do begin
    jdn = jdn_sorted[i]
    ;ymd = jd2yymmdd(jdn) ;TODO: consider yyyymmdd or yyyy-mm-dd
    ymd = jd2iso_date(jdn)  ;yyyy-mm-dd
 ;TODO: consider .5 day offset
    s = sunspot_blocking_data[jdn]
    printf, 8, format='(A10,4F10.2,I4)', ymd, s.ssbt, s.dssbt, s.ssbuv, s.dssbuv, s.quality_flag
  endfor

  close, 8
  
end
