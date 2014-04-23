;@***h* TSI_FCDR/compute_tsi_model.pro
; 
; NAME
;   write_tsi_model_to_netcdf.pro
;
; PURPOSE
;   The write_tsi_model_to_netcdf.pro function writes the Model Total Solar Irradiance to a netcdf4 file.
;   This function is called from the main routine, nrl_2_tsi.pro.
;
; DESCRIPTION
;   This routine is passed a data array of Model TSI irradiance ('data'). It creates a netCDF4 formatted file
;   for data output. CF-1.5 metadata conventions are used in defining global and variable name attributes.
; 
; INPUTS
;   data  - structure of Model TSI Irradiance and Time [TODO: update to include whatever time variables we include: time, year, doy, etc.)
;   
; OUTPUTS
;   time       = Calendar date (ISO 8601 compliant, in the form <date>T<time>Z or[yyyy]-[MM]-[DD]T[hh]:[mm]:[ss])
;   year       = self-explanatory
;   doy        = Day of Year
;   day_number = Cumulative Day Number from Jan. 1, 1978
;   tsi        = Modeled Daily Total Solar Irradiance (Watts/m**2)

; AUTHOR
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
;   04/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_tsi_model_to_netcdf, data, file
;
;@***** 
function write_tsi_model_to_netcdf, data, file, missing_value

  ; Define missing value and replace NaNs in the data with it.
  if (n_elements(missing_value) eq 0) then missing_value = -99.0
  tsi = replace_nan_with_value(data.tsi, missing_value)

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
  NCDF_ATTPUT, id, xid, 'units', 'W/m2'
  NCDF_ATTPUT, id, xid, 'missing_value', missing_value

  ; Define the time variable
  rid = NCDF_VARDEF(id, 'time', [tid], /LONG)
  NCDF_ATTPUT, id, rid, 'long_name', 'Days Since 1 Jan 1978'
  NCDF_ATTPUT, id, rid, 'units','days since 1978-1-1 0:0:0'
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, rid, data.day_number - 1 ;day_number starts at 1
  NCDF_VARPUT, id, xid, tsi
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end
