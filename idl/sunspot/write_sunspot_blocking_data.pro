pro write_sunspot_blocking_data, sunspot_blocking_data, file
;sunspot_blocking_data: array of structures
;  ssb_struct = {sunspot_blocking,  $
;    mjdn:0l,  $
;    ssbt:0.0, dssbt:0.0,   $
;    ssbuv:0.0, dssbuv:0.0, $
;    quality_flag:0         $
;  }

;TODO: test if sunspot_blocking_data is empty
  
  ;open output file
  openw, 8, file
  
  ;Iterate over days
  for i = 0, n_elements(sunspot_blocking_data)-1 do begin
    mjdn = sunspot_blocking_data[i].mjdn
    ymd = mjd2iso_date(mjdn)  ;yyyy-mm-dd
    s = sunspot_blocking_data[i]
    printf, 8, format='(A10,4F10.2,I4)', ymd, s.ssbt, s.dssbt, s.ssbuv, s.dssbuv, s.quality_flag
  endfor

  close, 8
  
end
