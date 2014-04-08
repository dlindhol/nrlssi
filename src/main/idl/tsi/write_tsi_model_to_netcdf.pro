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
function write_tsi_model_to_netcdf, data, file

  ; Create NetCDF file for writing output
  id = NCDF_CREATE(file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  
  ; Fill the file with default values
  ;NCDF_CONTROL, id, /FILL
  
  ; Add global attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.5"
  NCDF_ATTPUT, id, /GLOBAL, "title", "Daily TSI calculated using NRL TSI 2-component model"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"
  
  ; Define dimensions
  tid = NCDF_DIMDEF(id, 'T', /UNLIMITED) ;time
  
  ; Define variables and attributes
  xid = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
  NCDF_ATTPUT, id, xid, 'long_name', 'Daily Total Solar Irradiance (Watt/ m**2)'
  NCDF_ATTPUT, id, xid, 'standard_name', 'daily_TSI'
  NCDF_ATTPUT, id, xid, 'units', 'W/m2'
  
  pid = NCDF_VARDEF(id, 'Year', [tid], /FLOAT)
  NCDF_ATTPUT, id, pid, 'long_name', 'Year'
  NCDF_ATTPUT, id, pid, 'standard_name', 'year'
  NCDF_ATTPUT, id, pid, 'units','yr'
  
  qid = NCDF_VARDEF(id, 'DOY', [tid], /FLOAT)
  NCDF_ATTPUT, id, qid, 'long_name', 'Day of Year'
  NCDF_ATTPUT, id, qid, 'standard_name', 'day_of_year'
  
  rid = NCDF_VARDEF(id, 'Day_Number', [tid], /FLOAT)
  NCDF_ATTPUT, id, rid, 'long_name', 'Cumulative Day Number From 1 Jan 1978'
  NCDF_ATTPUT, id, rid, 'standard_name','cum_day_number_from_1_Jan_1978'
  NCDF_ATTPUT, id, rid, 'units','days since 1978-1-1 0:0:0'
  
  ;TODO: is year/time correct, how to do fill_value, missing_value, and/or valid_range
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, pid, data.year
  NCDF_VARPUT, id, qid, data.doy
  NCDF_VARPUT, id, rid, data.day_number
  NCDF_VARPUT, id, xid, data.tsi
  
  ; Read the data back out:
  ;NCDF_VARGET, id, xid, output_data
  ;NCDF_VARGET, id, rid, time
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: return status
  return, 1
end
