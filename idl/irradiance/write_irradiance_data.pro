function write_irradiance_data, ymd1,ymd2,irradiance_data, version, time_bin=time_bin, output_dir=output_dir
  ;TODO: use tsi, ssi keywords so we can choose to write just one or the other, default to both

  creation_date = jd2iso_date(systime(/julian, /utc)) ;now as yyyy-mm-dd UTC

;  ;Get the time range from the data.
;  times = irradiance_data.data.mjd
;  ymd1 = mjd2iso_date(times[0])  ;start time as yyyy-mm-dd
;  ymd2 = mjd2iso_date(times[-1]) ;end time as yyyy-mm-dd
  ;The above didn't work - was getting output ymd1 values of 1834-08-11 when expecting 2014-01-01
 
  ;Make sure we have a time bin defined. 'year', 'month', or 'day'
  if n_elements(time_bin) eq 0 then time_bin = 'day' ;default to daily

  ;Construct file names.
  tsi_file = create_filename(ymd1, ymd2, version, time_bin, /tsi)
  ssi_file = create_filename(ymd1, ymd2, version, time_bin, /ssi)

  ;Write data based on time bin.
  if (time_bin eq 'day') then begin
    status = write_tsi_model_to_netcdf2(ymd1, ymd2, creation_date, version, irradiance_data, output_dir=output_dir, tsi_file)
    status = write_ssi_model_to_netcdf2(ymd1, ymd2, creation_date, version, irradiance_data, output_dir=output_dir, ssi_file)
  endif
  if (time_bin eq 'month') then begin
    status = write_monthly_average_tsi_to_netcdf2(ymd1, ymd2, creation_date, version, irradiance_data, output_dir=output_dir, tsi_file)
    status = write_monthly_average_ssi_to_netcdf2(ymd1, ymd2, creation_date, version, irradiance_data, output_dir=output_dir, ssi_file)
  endif
  if (time_bin eq 'year') then begin
    status = write_yearly_average_tsi_to_netcdf2(ymd1, ymd2, creation_date, version, irradiance_data, output_dir=output_dir, tsi_file)
    status = write_yearly_average_ssi_to_netcdf2(ymd1, ymd2, creation_date, version, irradiance_data, output_dir=output_dir, ssi_file)
  endif
  
  ;Dynamically determine file size (in bytes) and MD5 checksum and output to manifest file
  ;TODO: refactor to make separate call for tsi, ssi
  manifest=create_manifest(output_dir=output_dir, tsi_file, ssi_file)

  ;Write the manifest data to file
  result = write_to_manifest(output_dir=output_dir, tsi_file, manifest.tsibytes, manifest.tsichecksum, tsi_file + '.mnf')
  result = write_to_manifest(output_dir=output_dir, ssi_file, manifest.ssibytes, manifest.ssichecksum, ssi_file + '.mnf')

  ;TODO: error handling, return combined status
  return, 0
end
