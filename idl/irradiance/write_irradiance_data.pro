;@***h* SOLAR_IRRADIANCE_FCDR/write_irradiance_data.pro
;
; NAME
;   write_irradiance_data
;
; PURPOSE
;   The write_irradiance_data.pro function is the driver routine for writing irradiance output to netCDF4 output
;   
; DESCRIPTION
;   The write_irradiance_data.pro function is the driver routine for writing irradiance output to netCDF4 output
;
; INPUTS
;   ymd1            - starting time range respective to midnight GMT of the given day, of the form 'yyyy-mm-dd'
;   ymd2            - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), of the form 'yyyy-mm-dd'.
;   irradiance_data - a structure containing the following variables
;     mjd        - Modified Julian Date  
;     iso        - iso 8601 formatted time
;     tsi        - Modeled Total Solar Irradiance
;     ssi        - Modeled Solar Spectral Irradiance (in wavelength bins) 
;     ssitot     - Integral of the Modeled Solar Spectral Irradiance 
;     nband      - number of spectral bands, for a variable wavelength grid, that the NRLSSI2 model bins 1 nm solar spectral irradiance onto.
;     bandcenter - the bandcenters (nm) of the variable wavelength grid.
;     bandwidth  - the bandwidths (delta wavelength, nm)  of the variable wavelength grid, centered on bandcenter.
;   version         - version and revision number of the NRLTSI2 and NRLSSI2 models (e.g., v02r00)
;   time_bin        - A value of 'year', 'month', or 'day' that defines the time-averaging performed for the given data records.
;                     'day' is the default.
;   output_dir - Directory path for irradiance files
;   
; OUTPUTS
;
; AUTHOR
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
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
;   06/04/2015 Initial Version prepared for NCDC
;
; USAGE
;   result=write_irradiance_data(ymd1,ymd2,irradiance_data, version, time_bin=time_bin, output_dir=output_dir)
;
;@*****
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
  tsi_manifest = create_manifest(output_dir + tsi_file)
  ssi_manifest = create_manifest(output_dir + ssi_file)

  ;Write the manifest data to file
  result = write_to_manifest(output_dir=output_dir, tsi_file, tsi_manifest.bytes, tsi_manifest.checksum, tsi_file + '.mnf')
  result = write_to_manifest(output_dir=output_dir, ssi_file, ssi_manifest.bytes, ssi_manifest.checksum, ssi_file + '.mnf')

  ;TODO: error handling, return combined status
  return, 0
end
