pro write_sunspot_blocking_data, sunspot_blocking_data, file
;sunspot_blocking_data: hash of structure by MJDN
;  ssb_struct = {sunspot_blocking,  $
;    mjdn:0l,  $
;    ssbt:0.0, dssbt:0.0,   $
;    ssbuv:0.0, dssbuv:0.0, $
;    quality_flag:0         $
;  }

;TODO: test if sunspot_blocking_data is empty
 
  ;Get the julian day numbers and sort them
  ;TODO: 8.3 has OrderedHash
  mjdn = sunspot_blocking_data.keys()
  mjdn_sorted = mjdn[sort(mjdn.toArray())]
  
  ;open output file
  openw, 8, file
  
  ;Iterate over sorted MJDN
  for i = 0, n_elements(mjdn_sorted)-1 do begin
    mjdn = mjdn_sorted[i]
    ;ymd = jd2yymmdd(jdn) ;TODO: consider yyyymmdd or yyyy-mm-dd
    ymd = mjd2iso_date(mjdn)  ;yyyy-mm-dd
    s = sunspot_blocking_data[jdn]
    printf, 8, format='(A10,4F10.2,I4)', ymd, s.ssbt, s.dssbt, s.ssbuv, s.dssbuv, s.quality_flag
  endfor

  close, 8
  
end
