;Construct a data product file name.
function create_filename, ymd1, ymd2, version, time_bin, tsi=tsi, ssi=ssi, output_dir=output_dir

  ;Make sure output_dir is defined. Default to current directory.
  if n_elements(output_dir) eq 0 then output_dir = ''

  ;Format times.
  ;Start date as yyyymmdd
  symd = remove_hyphens(ymd1)
  ;End datae as yyyymmdd
  eymd = remove_hyphens(ymd2)
  ;Creation date
  ;(TO DO: change to form DDMMMYY, ex., 09Sep14, but saved under alternative variable name as .nc4 metadata requires this info as well in ISO 8601 form..)
  creation_date = jd2iso_date(systime(/julian, /utc)) ;now as yyyy-mm-dd UTC
  cymd = remove_hyphens(creation_date) ;yyyymmdd
  
  ;Get the name of the paramter we are saving: ssi or tsi
  if keyword_set(ssi) then param = 'ssi'
  if keyword_set(tsi) then param = 'tsi'
  ;TODO: error if neither set

  ;Construct file name based on time bin
  if (time_bin eq 'day') then filename = output_dir + param +'_'+ version +'_'+ 'daily_s' + symd +'_e'+ eymd +'_c'+ cymd +'.nc'
  if (time_bin eq 'month') then begin
    symd = strmid(symd,0,6);starting ym
    eymd = strmid(eymd,0,6) ;ending ym
    filename = output_dir + param +'_'+ version +'_'+ 'monthly_s' + symd +'_e'+ eymd +'_c'+ cymd +'.nc'
  endif
  if (time_bin eq 'year') then begin
    symd = strmid(symd,0,4);starting ym
    eymd = strmid(eymd,0,4) ;ending ym
    filename = output_dir + param +'_'+ version +'_'+ 'yearly_s' + symd +'_e'+ eymd +'_c'+ cymd +'.nc'
  endif
  ;TODO: else error

  return, filename

end
