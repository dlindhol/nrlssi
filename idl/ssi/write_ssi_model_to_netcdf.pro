;@***h* TSI_FCDR/write_ssi_model_to_netcdf.pro
; 
; NAME
;   write_ssi_model_to_netcdf.pro
;
; PURPOSE
;   The write_ssi_model_to_netcdf.pro function writes the Model Solar Spectral Irradiance and date
;   to a netcdf4 file. This function is called from the main routine, nrl_2_ssi.pro.
;
; DESCRIPTION
;   The write_ssi_model_to_netcdf.pro function writes the Model Solar Spectral Irradiance and date
;   to a netcdf4 formatted file. CF-1.5 metadata conventions are used in defining global and variable name attributes. 
;   Missing values are defined as -99.0, by default.
;   This function is called from the main routine, nrl_2_ssi.pro.
; 
; INPUTS
;   spectrum  - structure of Model SSI data 
;   file  - file name for output file containing netCDF4 formatted data 
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
;   07/07/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_ssi_model_to_netcdf, yr, mn, dy, spectrum
; 
;@***** 
function write_ssi_model_to_netcdf, yr, mn, dy, spectrum

  file = 'nrlssi.nc' ; TODO: replace hardcoded filename with input parameter
  
  ; Define missing value 
  ;if (n_elements(missing_value) eq 0) then missing_value = -99.0
  missing_value = -99.0
  
  specwl_center = spectrum.wavelength[*,0] ; wavelength (nm) grid centers
  specwl_band   = spectrum.wavelength[*,1] ; wavelength bands (nm) centered on above wavelengths
  specirrad     = spectrum.irradiance ; Spectral irradiance (mW/m2/nm)
  totspec       = total(specirrad*specwl_band)/1000. ; Total irradiance (W/m2)
 
  ; Create NetCDF file for writing output
  id = NCDF_CREATE(file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrlssi.nc. (NC_ERROR=-35)
  
  ; Add global attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.5"
  NCDF_ATTPUT, id, /GLOBAL, "title", "Solar spectral irradiance calculated using NRL SSI 2-component model"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"
  NCDF_ATTPUT, id, /GLOBAL, "comment", "Absolute irradiance scale is PMOD (multiply by 0.9965 for TIM scale)"

  ; Define dimensions
  t1id = NCDF_DIMDEF(id, 'ssi_data', /UNLIMITED) ;SSI data
  t2id = NCDF_DIMDEF(id, 'time', 1) ;TSI and time

  
  ; Define SSI, wavelength, and TSI variable and attributes
  xid = NCDF_VARDEF(id, 'SSI', [t1id], /FLOAT)
  NCDF_ATTPUT, id, xid, 'long_name', 'Solar Spectral Irradiance (mWatt/ m**2/ nm**1)'
  NCDF_ATTPUT, id, xid, 'units', 'mW/m2/nm'
  NCDF_ATTPUT, id, xid, 'missing_value', missing_value
  yid = NCDF_VARDEF(id, 'TSI', [t2id], /FLOAT)
  NCDF_ATTPUT, id, yid, 'long_name', 'Integrated Solar Spectral Irradiance (Watt/m**2)'
  NCDF_ATTPUT, id, yid, 'units', 'W/m2'
  NCDF_ATTPUT, id, yid, 'missing_value', missing_value  
  w1id = NCDF_VARDEF(id,'Central Wavelength',[t1id], /FLOAT)
  NCDF_ATTPUT, id, w1id, 'long_name', 'Wavelength grid center'
  NCDF_ATTPUT, id, w1id, 'units', 'nm'
  w2id = NCDF_VARDEF(id,'Wavelength Bands',[t1id], /FLOAT)
  NCDF_ATTPUT, id, w2id, 'long_name', 'Wavelength bands. Centered on Central Wavelength'
  NCDF_ATTPUT, id, w2id, 'units', 'nm'  
 
  ; Define the time/date variables
  ryid = NCDF_VARDEF(id, 'year', [t2id], /LONG)
  NCDF_ATTPUT, id, ryid, 'long_name', 'year'
  rmid = NCDF_VARDEF(id, 'month', [t2id], /LONG)
  NCDF_ATTPUT, id, rmid, 'long_name', 'month'
  rdid = NCDF_VARDEF(id, 'day', [t2id], /LONG)
  NCDF_ATTPUT, id, rdid, 'long_name', 'day'
   
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, ryid, yr 
  NCDF_VARPUT, id, rmid, mn
  NCDF_VARPUT, id, rdid, dy
  NCDF_VARPUT, id, w1id, specwl_center
  NCDF_VARPUT, id, w2id, specwl_band
  NCDF_VARPUT, id, xid, specirrad
  NCDF_VARPUT, id, yid, totspec
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id  
  
  ;TODO: error status
  return, 0
 
end
