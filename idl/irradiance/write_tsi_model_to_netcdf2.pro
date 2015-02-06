;@***h* SOLAR_IRRADIANCE_FCDR/write_tsi_model_to_netcdf2.pro
; 
; NAME
;   write_tsi_model_to_netcdf2.pro
;
; PURPOSE
;   The write_tsi_model_to_netcdf2.pro function outputs Model Total Solar Irradiance
;   to a netcdf4 file. This function is called from the main driver routine, nrl2_to_irradiance.pro.
;
; DESCRIPTION
;   The write_tsi_model_to_netcdf.pro function writes the Model Total Solar Irradiance to a netcdf4 formatted file. 
;   Two time format variables are also included: an ISO 8601 time ('yyyy-mm-dd') and a seconds since a 1610-01-01 00:00:00 epoch
;   CF-1.6 metadata conventions are used in defining global and variable name attributes. 
;   Missing values are defined as -99.0. 
;   This function is called from the main routine, nrl2_to_irradiance.pro.
; 
; INPUTS
;   ymd1  - starting time  (yyyy-mm-dd)
;   ymd2  - ending time  (yyyy-mm-dd)
;   ymd3  - creation date (yyyy-mm-dd)
;   algver - version number of the NRLTSI2 model
;   algrev - revision number of the NRLTSI2 model
;   data - a structure containing the following variables
;     mjd - Modified Julian Date  
;     iso - iso 8601 formatted time
;     tsi - Modeled Total Solar Irradiance
;     ssi - Modeled Solar Spectral Irradiance (in wavelength bins) 
;     ssitot - Integral of the Modeled Solar Spectral Irradiance 
;   file - output filename. Created dynamically within the driver routine, nrl2_to_irradiance.pro  
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
;   01/14/2015 Initial Version prepared for NCDC
; 
; USAGE
;   write_tsi_model_to_netcdf2, ymd1, ymd2, ymd3, algver, algrev, data, file
;  
;@***** 
function write_tsi_model_to_netcdf2, ymd1, ymd2, ymd3, algver,algrev, data, file

  ; Define missing value and replace NaNs in the modeled data with it.
  ;if (n_elements(missing_value) eq 0) then missing_value = -99.0
  missing_value = -99.0
  tsi = replace_nan_with_value(data.tsi, missing_value) 
  tsiunc = replace_nan_with_value(data.tsiunc, missing_value) ;DO THIS WAY?
  day_zero_mjd = iso_date2mjdn('1610-01-01')
  dates =  data.iso 
  
  ; Create NetCDF file for writing output
  id = NCDF_CREATE(file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrltsi.nc. (NC_ERROR=-35)
  src = 'NRLTSI2_'+algver+algrev ;'creates the dynamic 'source' model version/revision for global attributes
  
  ; Global Attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.6"
  NCDF_ATTPUT, id, /GLOBAL, "Metadata_Conventions","CF-1.6, Unidata Dataset Discovery v1.0"
  NCDF_ATTPUT, id, /GLOBAL, "title", "Daily TSI calculated using NRL2 solar irradiance model"
  NCDF_ATTPUT, id, /GLOBAL, "source", src
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"
  NCDF_ATTPUT, id, /GLOBAL, "standard_name_vocabularly", "CF Standard Name Table v27"
  NCDF_ATTPUT, id, /GLOBAL, "id", file
  NCDF_ATTPUT, id, /GLOBAL, "naming_authority", "gov.noaa.ncdc"
  NCDF_ATTPUT, id, /GLOBAL, "date_created",ymd3
  NCDF_ATTPUT, id, /GLOBAL, "license","No constraints on data use."
  NCDF_ATTPUT, id, /GLOBAL, "summary", "This dataset contains total irradiance as a function of time created with the Naval Research Laboratory model for spectral and total irradiance (version 2). Total solar irradiance is the total, spectrally integrated energy input to the top of the Earth’s atmosphere, at a standard distance of one Astronomical Unit from the Sun. Its units are W per m2. The dataset is created by Judith Lean (Space Science Division, Naval Research Laboratory), Odele Coddington and Peter Pilewskie (Laboratory for Atmospheric and Space Science, University of Colorado).
  NCDF_ATTPUT, id, /GLOBAL, "keywords", "EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; INCOMING SOLAR RADIATION, EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; SOLAR RADIATION, EARTH SCIENCE &gt; SUN-EARTH INTERACTIONS &gt; SOLAR ACTIVITY &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; PALEOCLIMATE &gt; PALEOCLIMATE RECONSTRUCTIONS &gt; SOLAR FORCING/INSOLATION RECONSTRUCTION, EARTH SCIENCE &gt; SUN-EARTH INTERACTIONS &gt; SOLAR ACTIVITY &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; SUN-EARTH INTERACTIONS &gt; SUNSPOT ACTIVITY &gt; SOLAR FLUX, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; PALEOCLIMATE INDICATORS &gt; PALEOCLIMATE RECONSTRUCTIONS &gt; SOLAR FORCING/INSOLATION RECONSTRUCTION, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; SUN-EARTH INTERACTIONS &gt; SUNSPOT ACTIVITY &gt; SOLAR FLUX";
  NCDF_ATTPUT, id, /GLOBAL, "keywords_vocabularly","NASA Global Change Master Directory (GCMD) Earth Science Keywords, Version 8.0"
  NCDF_ATTPUT, id, /GLOBAL, "cdm_data_type","Any"
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_start", ymd1
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_end", ymd2
  NCDF_ATTPUT, id, /GLOBAL, "cdr_program", "NOAA Climate Data Record Program"
  NCDF_ATTPUT, id, /GLOBAL, "cdr_variable", "total solar irradiance"
  NCDF_ATTPUT, id, /GLOBAL, "metadata_link", "gov.noaa.ncdc:C00828"
  NCDF_ATTPUT, id, /GLOBAL, "product_version", algver+algrev
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_min","-90.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_max"," 90.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_min","-180.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_max"," 180.0"
  NCDF_ATTPUT, id, /GLOBAL, "spatial_resolution", "N/A"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_name", "Judith Lean, Peter Pilewskie, Odele Coddington"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_role", "Principal Investigator and originator of total and spectral solar irradiance model, Principal Investigator ensuring overall integrity of the data product, Co-Investigator and Point-of-Contact and translated research-grade code to operational routine with FCDR output data being written out in NetCDF-4"
  
  ; Define Dimensions
  tid = NCDF_DIMDEF(id, 'time', /UNLIMITED) ;time series
  
  ; Variable Attributes
  x1id = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
  NCDF_ATTPUT, id, x1id, 'long_name', 'NOAA Fundamental Climate Data Record of Daily Total Solar Irradiance (W m-2)'
  NCDF_ATTPUT, id, x1id, 'standard_name', 'toa_incoming_shortwave_flux'
  NCDF_ATTPUT, id, x1id, 'units', 'W m-2'
  NCDF_ATTPUT, id, x1id, 'missing_value', missing_value
  
  x2id = NCDF_VARDEF(id, 'iso_time', [tid], /STRING)
  NCDF_ATTPUT, id, x2id, 'long_name', 'ISO8601 date (YYYY-MM-DD)'

  x3id = NCDF_VARDEF(id,'time',[tid],/FLOAT)
  NCDF_ATTPUT, id, x3id, 'units','days since 1610-01-01 00:00:00'
  NCDF_ATTPUT, id, x3id, 'standard_name','time'
  
  x4id = NCDF_VARDEF(id,'TSI_UNC',[tid],/FLOAT)
  NCDF_ATTPUT, id, x4id, 'long_name','Uncertainty in Daily Total Solar Irradiance (W m-2)'
  NCDF_ATTPUT, id, x4id, 'units', 'W m-2'
  
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, x2id, dates ;YYYY-MM-DD; ISO 8601 standards
  NCDF_VARPUT, id, x3id, data.mjd - day_zero_mjd ;CF-compliant time variable
  NCDF_VARPUT, id, x1id, tsi
  NCDF_VARPUT, id, x4id, tsiunc
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end
