;@***h* TSI_FCDR/write_tsi_model_to_netcdf.pro
; 
; NAME
;   write_tsi_model_to_netcdf.pro
;
; PURPOSE
;   The write_tsi_model_to_netcdf.pro function writes the date and Model Total Solar Irradiance
;   to a netcdf4 file. This function is called from the main routine, nrl2_2_irradiance.pro.
;
; DESCRIPTION
;   The write_tsi_model_to_netcdf.pro function writes the Model Total Solar Irradiance, year, day of year, and cumulative day number 
;   to a netcdf4 formatted file. CF-1.5 metadata conventions are used in defining global and variable name attributes. 
;   Missing values (NaN's or '0's) are defined as -99.0. TODO: check: do we have NaN output still?
;   This function is called from the main routine, nrl2_2_irradiance.pro.
; 
; INPUTS
;   ymd1  - starting time range (yyyy-mm-dd)
;   ymd2  - ending time range (yyyy-mm-dd)
;   data  - structure of Model TSI data containing 'year', 'doy' (day of year), 'day_number' (cumulative since Jan 1, 1978), and 'tsi'
;   file  - file name for output file containing netCDF4 formatted data. The default
;           file naming convention is tsi_YMD1_YMD2_VER.nc 
;           
;           ; UPDATE: Include "creation date in file naming convention"
;      
; OUTPUTS
;
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
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
;   09/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_tsi_model_to_netcdf, ymd1, ymd2, mjd, data, file
;  
;@***** 
function write_tsi_model_to_netcdf2, ymd1, ymd2, mjd, data, file

  ; Define missing value and replace NaNs in the modeled data with it.
  ;if (n_elements(missing_value) eq 0) then missing_value = -99.0
  missing_value = -99.0
  tsi = replace_nan_with_value(data.totirrad, missing_value)

  ; Create NetCDF file for writing output
  id = NCDF_CREATE(file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrltsi.nc. (NC_ERROR=-35)
  
  ; Add global attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.5"
  NCDF_ATTPUT, id, /GLOBAL, "title", "Daily TSI calculated using NRL TSI 2-component model"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"
  
  ; Define dimensions
  tid = NCDF_DIMDEF(id, 'time', /UNLIMITED) ;time
  
  ; Define TSI variable and attributes
  xid = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
  NCDF_ATTPUT, id, xid, 'long_name', 'Daily Total Solar Irradiance (Watt/ m**2)'
  NCDF_ATTPUT, id, xid, 'standard_name', 'toa_incoming_shortwave_flux'
  NCDF_ATTPUT, id, xid, 'units', 'W/m**2'
  NCDF_ATTPUT, id, xid, 'missing_value', missing_value

  ; Define the time variable
  rid = NCDF_VARDEF(id, 'time', [tid], /STRING)
  NCDF_ATTPUT, id, rid, 'long_name', 'Date'
  NCDF_ATTPUT, id, rid, 'long_name','YYYY-MM-DD'
  
  ;Define start and end time variable
  r1id = NCDF_VARDEF(id,'time_coverage_start',[1],/STRING)
  r2id = NCDF_VARDEF(id,'time_coverage_end',[1],/STRING)
 
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, rid, mjd2iso_date(mjd) ;date expressed according to ISO 8601 standards; YYYY-MM-DD
  NCDF_VARPUT, id, r1id, ymd1 ;start date (YYYY-MM-DD)
  NCDF_VARPUT, id, r2id, ymd2 ;end date (YYYY-MM-DD)
  NCDF_VARPUT, id, xid, tsi
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end
