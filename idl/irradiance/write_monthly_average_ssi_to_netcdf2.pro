;@***h* SOLAR_IRRADIANCE_FCDR/write_monthly_average_ssi_to_netcdf.pro
; 
; NAME
;   write_monthly_average_ssi_to_netcdf.pro
;
; PURPOSE
;   The write_monthly_average_ssi_to_netcdf.pro function writes the date and monthly-averaged Model Solar Spectral Irradiance
;   to a netcdf4 file. It is called by the function average_by_month.pro
;
; DESCRIPTION
;   The write_monthly_average_ssi_to_netcdf.pro function writes the monthly-averaged Model Solar Spectral Irradiance, and (midpoint) 
;   date (YYYY-MM) to a netcdf4 formatted file. CF-1.5 metadata conventions are used in defining global and variable name attributes. 
;   Missing values (NaN's or '0's) are defined as -99.0. 
; 
; INPUTS
;   result  - a structure containing the following variables:
;    iso - the ISO time 'YYYY-MM'
;    mjd - midpoint of the time series (in Modified Julian date)
;    min_mjd - the initial date (modified Julian date) in the time series used in the monthly average
;    max_mjd - the last date (modified Julian date) in the time series used in the monthly average
;    count - number of elements (i.e. dates) used in the temporal average
;    tsi - mean (monthly average) of total solar irradiance
;    tsi_stddev - standard deviation of the monthly-averaged total solar irradiance
;    ssi- mean (monthly average) of solar spectral irradiance
;    ssi_stddev- standard deviation of the monthly-averaged solar spectral irradiance
;    ssitot - mean (monthly average) of the integrated solar spectral irradiance
;    ssitot_stddev - standard deviation of the monthly-average of the integrated solar spectral irradiance
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
;   11/07/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_monthly_average_ssi_to_netcdf, ym1, ym2, ymd3, algver, result, file
;  
;@***** 
function write_monthly_average_ssi_to_netcdf2, ymd1, ymd2, ymd3, version, irradiance_data, output_dir=output_dir, file

  ;Extract data component
  data = irradiance_data.data
  ;Extract the wavelength bins
  spectral_bins = irradiance_data.wavelength
  
  ; Define missing value and replace NaNs in the modeled data with it.
  missing_value = -99.0
  ssi = replace_nan_with_value(data.ssi, missing_value)
  ;ssiunc = replace_nan_with_value(data.ssiunc, missing_value)
  tsi = replace_nan_with_value(data.tsi, missing_value)
  tsiunc = replace_nan_with_value(data.tsiunc, missing_value)
  day_zero_mjd = iso_date2mjdn('1610-01-01')

  ; Create NetCDF file for writing output
  id = NCDF_CREATE(output_dir+file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrltsi.nc. (NC_ERROR=-35)
  src = 'NRLSSI2_'+version ;'creates the dynamic 'source' model version/revision for global attributes
  
  ; Global Attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.6",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "Metadata_Conventions","CF-1.6, Unidata Dataset Discovery v1.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "title", "Monthly-averaged SSI calculated using NRL2 solar irradiance model. Includes monthly-averaged and spectrally integrated (total) TSI value",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "source", src,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "standard_name_vocabularly", "CF Standard Name Table v27",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "id", file,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "naming_authority", "gov.noaa.ncdc",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "date_created",ymd3,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "license","No constraints on data use.",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "summary", "This dataset contains spectral solar irradiance as a function of time (monthly-averaged) and wavelength created with the Naval Research Laboratory model for spectral and total irradiance (version 2). Spectral solar irradiance is the wavelength-dependent energy input to the top of the Earth’s atmosphere, at a standard distance of one Astronomical Unit from the Sun. Its units are W per m2 per nm. Also included is the value of monthly-averaged, total (spectrally integrated) solar irradiance in units W per m2. The dataset is created by Judith Lean (Space Science Division, Naval Research Laboratory), and Odele Coddington, Doug Lindholm, Peter Pilewskie, and Martin Snow (Laboratory for Atmospheric and Space Science, University of Colorado).",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "keywords", "EARTH SCIENCE, ATMOSPHERE, ATMOSPHERIC RADIATION, INCOMING SOLAR RADIATION, SOLAR IRRADIANCE, SOLAR RADIATION, SOLAR FORCING, INSOLATION RECONSTRUCTION, SUN-EARTH INTERATIONS, CLIMATE INDICATORS, PALEOCLIMATE INDICATORS, SOLAR FLUX, SOLAR ENERGY, SOLAR ACTIVITY, SOLAR CYCLE",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "keywords_vocabularly","NASA Global Change Master Directory (GCMD) Earth Science Keywords, Version 8.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "cdm_data_type","Any",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_start", ymd1,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_end", ymd2,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "cdr_program", "NOAA Climate Data Record Program",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "cdr_variable", "SSI, TSI",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "metadata_link", "gov.noaa.ncdc:C00899",/CHAR 
  NCDF_ATTPUT, id, /GLOBAL, "product_version", version,/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_min","-90.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_max"," 90.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_min","-180.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_max"," 180.0",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "spatial_resolution", "N/A",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "contributor_name", "Judith Lean, Peter Pilewskie, Odele Coddington",/CHAR
  NCDF_ATTPUT, id, /GLOBAL, "contributor_role", "Principal Investigator and originator of total and spectral solar irradiance model, Principal Investigator ensuring overall integrity of the data product, Co-Investigator and Point-of-Contact and translated research-grade code to operational routine with FCDR output data being written out in NetCDF-4",/CHAR
  
  ; Define Dimensions
  tid = NCDF_DIMDEF(id, 'time', /UNLIMITED) ;time series
  bid = NCDF_DIMDEF(id, 'bounds', 2) ;time bounds dimension
  lid = NCDF_DIMDEF(id, 'wavelength',spectral_bins.nband) ;wavelengths
 
  ; Variable Attributes
  x0id = NCDF_VARDEF(id, 'SSI', [lid,tid], /FLOAT)
  NCDF_ATTPUT, id, x0id, 'long_name', 'NOAA Climate Data Record of Monthly Averaged Solar Spectral Irradiance (W m-2 nm-1)',/CHAR
  NCDF_ATTPUT, id, x0id, 'standard_name', 'toa_solar_spectral_irradiance',/CHAR
  NCDF_ATTPUT, id, x0id, 'units', 'W m-2 nm-1',/CHAR
  NCDF_ATTPUT, id, x0id, 'cell_methods','time: mean',/CHAR
  NCDF_ATTPUT, id, x0id, 'missing_value', missing_value
  
  t0id = NCDF_VARDEF(id,'wavelength',[lid], /FLOAT) 
  NCDF_ATTPUT, id, t0id, 'long_name', 'Wavelength grid center',/CHAR
  NCDF_ATTPUT, id, t0id, 'units', 'nm',/CHAR
  NCDF_ATTPUT, id, t0id, 'standard_name','radiation_wavelength',/CHAR

  t1id = NCDF_VARDEF(id,'Wavelength_Band_Width',[lid], /FLOAT) ;cell-based metadata (ask NCDC how to do this?)
  NCDF_ATTPUT, id, t1id, 'long_name', 'Wavelength band width. Centered on wavelength.',/CHAR
  NCDF_ATTPUT, id, t1id, 'units', 'nm',/CHAR
  
  x1id = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
  NCDF_ATTPUT, id, x1id, 'long_name', 'NOAA Climate Data Record of Monthly Averaged Total Solar Irradiance (W m-2)',/CHAR
  NCDF_ATTPUT, id, x1id, 'standard_name', 'toa_total_solar_irradiance',/CHAR
  NCDF_ATTPUT, id, x1id, 'units', 'W m-2',/CHAR
  NCDF_ATTPUT, id, x1id, 'cell_methods','time: mean',/CHAR
  NCDF_ATTPUT, id, x1id, 'ancillary_variables','TSI_UNC',/CHAR
  NCDF_ATTPUT, id, x1id, 'missing_value', missing_value

  x2id = NCDF_VARDEF(id, 'time',[tid],/FLOAT)
  NCDF_ATTPUT, id, x2id, 'units','days since 1610-01-01 00:00:00',/CHAR
  NCDF_ATTPUT, id, x2id, 'standard_name','time',/CHAR
  NCDF_ATTPUT, id, x2id, 'axis','T',/CHAR
  NCDF_ATTPUT, id, x2id, 'bounds', 'time_bnds',/CHAR
  
  ;x3id = NCDF_VARDEF(id, 'time_bnds', [bid,tid], /FLOAT) ;this gave incorrect ranges in time_bnds (pegged at 9e36)
  x3id = NCDF_VARDEF(id, 'time_bnds', [tid,bid], /FLOAT)
  NCDF_ATTPUT, id, x3id, 'long_name', 'Minimum (inclusive) and maximum (exclusive) dates included in the time averaging',/CHAR
  NCDF_ATTPUT, id, x3id, 'units', 'days since 1610-01-01 00:00:00',/CHAR
  
  x4id = NCDF_VARDEF(id,'TSI_UNC',[tid],/FLOAT)
  NCDF_ATTPUT, id, x4id, 'long_name','Uncertainty in Monthly Averaged Total Solar Irradiance (W m-2)',/CHAR
  NCDF_ATTPUT, id, x4id, 'units', 'W m-2',/CHAR
  NCDF_ATTPUT, id, x4id, 'missing_value',missing_value
  
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, x2id, data.mjd - day_zero_mjd
  NCDF_VARPUT, id, x1id, tsi
  NCDF_VARPUT, id, x4id, tsiunc
  NCDF_VARPUT, id, x0id, ssi
  NCDF_VARPUT, id, t0id, spectral_bins.bandcenter
  NCDF_VARPUT, id, t1id, spectral_bins.bandwidth
  
  ;Define the bounds for each time bin.
  time_bounds = get_monthly_time_bounds(data.mjd)
  NCDF_VARPUT, id, x3id, time_bounds - day_zero_mjd
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end