function write_tsi_composite, ymd1, ymd2, output_dir=output_dir
  ;output_dir is expected to end with the file separator (/)
  
  ;Read data from LaTiS
  ;Add one day since the LaTiS reader is exclusive
  data = read_latis_data('nrl2_observational_composite_tsi', ymd1, mjd2iso_date(iso_date2mjdn(ymd2) + 1))

  ;Open output file
  ;sample file name: observed-tsi-composite_s19780101_e20151231_c20151115.txt
  if KEYWORD_SET(output_dir) then dir = output_dir else dir = ''
  file = dir                                        ;directory
  file += 'observed-tsi-composite'                  ;base file name
  file += "_s" + remove_hyphens(ymd1)               ;start date
  file += "_e" + remove_hyphens(ymd2)               ;end date
  caldat, systime(/utc, /julian), mon, day, year
  file += "_c" + string(format='(I4,I02,I02)', year, mon, day)  ;current/cration date
  file += ".txt" 
  openw, unit, file, /get_lun

  ;Print header
  header = 'time (yyyy-MM-dd), TSI (W m-2), uncertainty (W m-2)'
  printf, unit, header
  
  ;Loop over samples (days) and print row of csv data.
  n = data.count()
  for i = 0, n-1 do begin
    ;print the record
    ymd = data[i].(0)
    tsi = strtrim(data[i].(1),2)
    unc = strtrim(data[i].(2),2)
    ;replace null with missing value: -99.0
    if (tsi eq '!NULL') then tsi = '-99.0'
    if (unc eq '!NULL') then unc = '-99.0'
    printf, unit, strjoin([ymd, tsi, unc], ',')
  endfor
  
  free_lun, unit

  return, 0
end
