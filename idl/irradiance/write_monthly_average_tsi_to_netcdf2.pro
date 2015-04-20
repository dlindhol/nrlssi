;@***h* SOLAR_IRRADIANCE_FCDR/write_monthly_average_tsi_to_netcdf.pro
; 
; NAME
;   write_monthly_average_tsi_to_netcdf.pro
;
; PURPOSE
;   The write_monthly_average_tsi_to_netcdf.pro function writes the date and monthly-averaged Model Total Solar Irradiance
;   to a netcdf4 file. It is called by the function average_by_month.pro
;
; DESCRIPTION
;   The write_monthly_average_tsi_to_netcdf.pro function writes the monthly-averaged Model Total Solar Irradiance, and (midpoint) 
;   date (YYYY-MM) to a netcdf4 formatted file. CF-1.5 metadata conventions are used in defining global and variable name attributes. 
;   Missing values (NaN's or '0's) are defined as -99.0. TODO: check: do we have NaN output still?
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
;   write_monthly_average_tsi_to_netcdf, ym1, ym2, ymd3, algver, result, file
;  
;@***** 
function write_monthly_average_tsi_to_netcdf2, ym1, ym2, algver, result, file

  ; Define missing value and replace NaNs in the modeled data with it.
  ; 
  ;if (n_elements(missing_value) eq 0) then missing_value = -99.0
  missing_value = -99.0
  tsi = replace_nan_with_value(result.tsi, missing_value)
  
   ;Creation date, used for output files 
  ymd3 = jd2iso_date(systime(/julian, /utc)) 
  
  dates =  mjd2iso_yyyymm(result.mjd) 
  
  ; Create NetCDF file for writing output
  id = NCDF_CREATE(file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrltsi.nc. (NC_ERROR=-35)
  
  ; Global Attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.5"
  NCDF_ATTPUT, id, /GLOBAL, "title", "Monthly Averaged TSI calculated using NRL2 solar irradiance model"
  NCDF_ATTPUT, id, /GLOBAL, "source", "nrl2_to_irradiance.pro"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"
  NCDF_ATTPUT, id, /GLOBAL, "standard_name_vocabularly", "CD Standard Name Table (v27, 28, November 2013)
  NCDF_ATTPUT, id, /GLOBAL, "Id", "Solar Irradiance FCDR"
  NCDF_ATTPUT, id, /GLOBAL, "naming_authority", "gov.noaa.ncdc"
  NCDF_ATTPUT, id, /GLOBAL, "date_created",ymd3
  NCDF_ATTPUT, id, /GLOBAL, "license","No constraints on data use."
  NCDF_ATTPUT, id, /GLOBAL, "summary", "This dataset contains total irradiance as a function of time created with the Naval Research Laboratory model for spectral and total irradiance (version 2). Total solar irradiance is the total, spectrally integrated energy input to the top of the Earth’s atmosphere, at a standard distance of one Astronomical Unit from the Sun. Its units are W per m2. The dataset is created by Judith Lean (Space Science Division, Naval Research Laboratory), Odele Coddington and Peter Pilewskie (Laboratory for Atmospheric and Space Science, University of Colorado).
  NCDF_ATTPUT, id, /GLOBAL, "keywords", "EARTH SCIENCE, ATMOSPHERE, ATMOSPHERIC RADIATION, INCOMING SOLAR RADIATION, SOLAR IRRADIANCE, SOLAR RADIATION, SOLAR FORCING, INSOLATION RECONSTRUCTION, SUN-EARTH INTERATIONS, CLIMATE INDICATORS, PALEOCLIMATE INDICATORS, SOLAR FLUX, SOLAR ENERGY, SOLAR ACTIVITY, SOLAR CYCLE"
  NCDF_ATTPUT, id, /GLOBAL, "keywords_vocabularly","NASA Global Change Master Directory (GCMD) Earth Science Keywords, Version 6.0"
  NCDF_ATTPUT, id, /GLOBAL, "cdm_data_type","Point"
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_start", ym1
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_end", ym2
  NCDF_ATTPUT, id, /GLOBAL, "cdr_program", "NOAA Climate Data Record Program, FY 2014"
  NCDF_ATTPUT, id, /GLOBAL, "cdr_variable", "total solar irradiance"
  NCDF_ATTPUT, id, /GLOBAL, "metadata_link", "????" ;***TODO
  NCDF_ATTPUT, id, /GLOBAL, "product_version", algver
  NCDF_ATTPUT, id, /GLOBAL, "platform", "SORCE, TSIS"
  NCDF_ATTPUT, id, /GLOBAL, "sensor", "Total Irradiance Monitor (TIM)"
  NCDF_ATTPUT, id, /GLOBAL, "spatial_resolution", "N/A"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_name", "Judith Lean, Peter Pilewskie, Odele Coddington"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_role", "Principal Investigator and originator of total and spectral solar irradiance model, Principal Investigator ensuring overall integrity of the data product, Co-Investigator and Point-of-Contact and translated research-grade code to operational routine with FCDR output data being written out in NetCDF-4"
  
  ; Define Dimensions
  tid = NCDF_DIMDEF(id, 'time', /UNLIMITED) ;time series
  bid = NCDF_DIMDEF(id, 'bounds', 2) ;time bounds dimension
  
  ; Variable Attributes
  x1id = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
  NCDF_ATTPUT, id, x1id, 'long_name', 'NOAA Fundamental Climate Data Record of Monthly Averaged Total Solar Irradiance (Watt/ m**2)'
  NCDF_ATTPUT, id, x1id, 'standard_name', 'toa_incoming_shortwave_flux'
  NCDF_ATTPUT, id, x1id, 'units', 'W/m**2'
  NCDF_ATTPUT, id, x1id, 'missing_value', missing_value
  NCDF_ATTPUT, id, x1id, 'valid_max',2.5; TODO, the maximum valid range for TSI
  NCDF_ATTPUT, id, x1id, 'valid_min',0.0 ;
  NCDF_ATTPUT, id, x1id, 'cell_methods', 'time: mean'
  
  x2id = NCDF_VARDEF(id, 'time', [tid], /FLOAT)
  NCDF_ATTPUT, id, x2id, 'long_name', 'time'
  NCDF_ATTPUT, id, x2id, 'units','days since 1610-01-01 00:00:00'
  NCDF_ATTPUT, id, x2id, 'standard_name','time'
  NCDF_ATTPUT, id, x2id, 'bounds', 'time_bnds'
  
  x3id = NCDF_VARDEF(id, 'time_bnds', [tid,bid], /FLOAT)
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  ;NCDF_VARPUT, id, x2id, dates ;YYYY-MM; ISO 8601 standards; 
  NCDF_VARPUT, id, x3id, data.mjd - day_zero_mjd
  NCDF_VARPUT, id, x1id, tsi
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end
