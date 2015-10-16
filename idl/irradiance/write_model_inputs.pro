function write_model_inputs, ymd1, ymd2, output_dir=output_dir
  
  ;Get final sunspot blocking
  sb_final = get_sunspot_blocking(ymd1, ymd2, /final)
  ;Compute the start time for prelim data (after last day of final)
  nfinal = sb_final.count()
  if (nfinal gt 0) then ymd_prelim = mjd2iso_date(sb_final[-1].(0) + 1)
  ;Get prelim sunspot blocking
  sb_prelim = get_sunspot_blocking(ymd_prelim, ymd2)
  
  ;Get final facular brightening
  fb_final = get_mg_index(ymd1, ymd2, /final)
  ;Get prelim facular brightening (assume same start time as sunspot blocking)
  fb_prelim = get_mg_index(ymd_prelim, ymd2)


  ;Open output file
  if KEYWORD_SET(output_dir) then dir = output_dir else dir = ''
  file = dir + 'nrl2_model_inputs.csv'
  openw, unit, file, /get_lun

  ;Print header
  header = 'time (yyyy-MM-dd), sunspot_darkening_function, facular_brightening_function, source'
  printf, unit, header
  
  ;Loop over samples (days) and print row of csv data.
  ;Assume, but varify, that each dataset has data for the same days.
  for i = 0, nfinal-1 do begin
    ;make sure the times match
    sb_mjd = sb_final[i].(0)
    fb_mjd = fb_final[i].(0)
    if sb_mjd ne fb_mjd then begin
      print, "ERROR: sunspot blocking and facular brightening times don't match: " + strtrim(sb_mjd,2) + strtrim(fb_mjd,2)
      stop
    endif
    
    ;print the record
    ymd = mjd2iso_date(sb_mjd)
    sb = strtrim(sb_final[i].(1), 2)
    fb = strtrim(fb_final[i].(1), 2)
    source = 'final'
    printf, unit, strjoin([ymd, sb, fb, source], ',')
  endfor
  ;Now the prelim data.
  for i = 0, sb_prelim.count()-1 do begin
    ;make sure the times match
    sb_mjd = sb_prelim[i].(0)
    fb_mjd = fb_prelim[i].(0)
    if sb_mjd ne fb_mjd then begin
      print, "ERROR: sunspot blocking and facular brightening times don't match: " + strtrim(sb_mjd,2) + strtrim(fb_mjd,2)
      stop
    endif

    ;print the record
    ymd = mjd2iso_date(sb_mjd)
    sb = strtrim(sb_prelim[i].(1), 2)
    fb = strtrim(fb_prelim[i].(1), 2)
    source = 'prelim'
    printf, unit, strjoin([ymd, sb, fb, source], ',')
  endfor

  free_lun, unit

  return, 0
end
