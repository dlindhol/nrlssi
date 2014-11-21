;@***h* SOLAR_IRRADIANCE_FCDR/write_ssi_model_to_netcdf.pro
; 
; NAME
;   write_ssi_model_to_netcdf.pro
;
; PURPOSE
;   The write_ssi_model_to_netcdf.pro function writes the date and Model Solar Spectral Irradiance
;   to a netcdf4 file. This function is called from the main routine, nrl2_2_irradiance.pro.
;
; DESCRIPTION
;   The write_ssi_model_to_netcdf.pro function writes the Model Solar Spectral Irradiance, wavelength grid (midpoints and range),
;   date (YYYY-MM-DD format) to a netcdf4 formatted file. Also included is the value of total (spectrally)
;   integrated Total Solar Irradiance for the particular date. CF-1.5 metadata conventions are used in defining global and 
;   variable name attributes. Missing values are defined as -99.0. TODO: check: do we have NaN output still?
;   This function is called from the main routine, nrl2_2_irradiance.pro.
; 
; INPUTS
;   ymd1  - starting time  (yyyy-mm-dd)
;   ymd2  - ending time  (yyyy-mm-dd)
;   mjd   - array of dates covering time period (Modified Julian date)
;   spectrum  - structure of Modeled Solar Spectral Irradiance (SSI) data containing date, ssi, wavelength grid (bin centers and ranges)
;   tsi   - Modeled Total Solar Irradiance (TSI)
;   file  - output file name. The default file naming convention is ssi_YMD1_YMD2_VER.nc 
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
;   11/18/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_ssi_model_to_netcdf, ymd1,ymd2,ymd3,algver,algrev,data,spectral_bins,ssifile_daily
;  
;@***** 
function write_ssi_model_to_netcdf2, ymd1,ymd2,ymd3,algver,algrev,data,spectral_bins,file

  ; Define missing value and replace NaNs in the modeled data with it.
  ;if (n_elements(missing_value) eq 0) then missing_value = -99.0
  missing_value = -99.0
  ssi = replace_nan_with_value(data.ssi, missing_value)
  dates =  data.iso 
  tsi = replace_nan_with_value(data.tsi, missing_value)
  
  
  ; Create NetCDF file for writing output
  id = NCDF_CREATE(file, /NOCLOBBER, /netCDF4_format) ;noclobber = don't overwrite existing file
  ;TODO: handle error: NCDF_CREATE: Unable to create the file, /data/tmp/nrltsi.nc. (NC_ERROR=-35)
  
  ; Global Attributes
  NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.6"
  NCDF_ATTPUT, id, /GLOBAL, "Metadata_Conventions","CF-1.6, Unidata Dataset Discovery v1.0"
  NCDF_ATTPUT, id, /GLOBAL, "title", "Daily SSI calculated using NRL2 solar irradiance model. Includes spectrally integrated (total) TSI value"
  NCDF_ATTPUT, id, /GLOBAL, "source", "nrl2_to_irradiance.pro"
  NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"
  NCDF_ATTPUT, id, /GLOBAL, "standard_name_vocabularly", "CF Standard Name Table v27)
  NCDF_ATTPUT, id, /GLOBAL, "id", file
  NCDF_ATTPUT, id, /GLOBAL, "naming_authority", "gov.noaa.ncdc"
  NCDF_ATTPUT, id, /GLOBAL, "date_created",ymd3
  NCDF_ATTPUT, id, /GLOBAL, "license","No constraints on data use."
  NCDF_ATTPUT, id, /GLOBAL, "summary", "This dataset contains spectral solar irradiance as a function of time and wavelength created with the Naval Research Laboratory model for spectral and total irradiance (version 2). Spectral solar irradiance is the wavelength-dependent energy input to the top of the Earth’s atmosphere, at a standard distance of one Astronomical Unit from the Sun. Its units are W per m2 per nm. Also included is the value of total (spectrally integrated) solar irradiance in units W per m2. The dataset is created by Judith Lean (Space Science Division, Naval Research Laboratory), Odele Coddington and Peter Pilewskie (Laboratory for Atmospheric and Space Science, University of Colorado).
  NCDF_ATTPUT, id, /GLOBAL, "keywords", "EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; INCOMING SOLAR RADIATION, EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; ATMOSPHERE &gt; ATMOSPHERIC RADIATION &gt; SOLAR RADIATION, EARTH SCIENCE &gt; SUN-EARTH INTERACTIONS &gt; SOLAR ACTIVITY &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; PALEOCLIMATE &gt; PALEOCLIMATE RECONSTRUCTIONS &gt; SOLAR FORCING/INSOLATION RECONSTRUCTION, EARTH SCIENCE &gt; SUN-EARTH INTERACTIONS &gt; SOLAR ACTIVITY &gt; SOLAR IRRADIANCE, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; SUN-EARTH INTERACTIONS &gt; SUNSPOT ACTIVITY &gt; SOLAR FLUX, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; PALEOCLIMATE INDICATORS &gt; PALEOCLIMATE RECONSTRUCTIONS &gt; SOLAR FORCING/INSOLATION RECONSTRUCTION, EARTH SCIENCE &gt; CLIMATE INDICATORS &gt; SUN-EARTH INTERACTIONS &gt; SUNSPOT ACTIVITY &gt; SOLAR FLUX";
  NCDF_ATTPUT, id, /GLOBAL, "keywords_vocabularly","NASA Global Change Master Directory (GCMD) Earth Science Keywords, Version 8.0"
  NCDF_ATTPUT, id, /GLOBAL, "cdm_data_type","Point"
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_start", ymd1
  NCDF_ATTPUT, id, /GLOBAL, "time_coverage_end", ymd2
  NCDF_ATTPUT, id, /GLOBAL, "program", "NOAA Climate Data Record Program"
  NCDF_ATTPUT, id, /GLOBAL, "cdr_variable", "solar spectral irradiance"
  NCDF_ATTPUT, id, /GLOBAL, "metadata_link", "gov.noaa.ncdc:C00899" 
  NCDF_ATTPUT, id, /GLOBAL, "product_version", algver+algrev
  NCDF_ATTPUT, id, /GLOBAL, "platform", "SORCE, TCTE"
  NCDF_ATTPUT, id, /GLOBAL, "instrument", "Spectral Irradiance Monitor (SIM)"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_min","-90.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lat_max"," 90.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_min","-180.0"
  NCDF_ATTPUT, id, /GLOBAL, "geospatial_lon_max"," 180.0"
  NCDF_ATTPUT, id, /GLOBAL, "spatial_resolution", "N/A"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_name", "Judith Lean, Peter Pilewskie, Odele Coddington"
  NCDF_ATTPUT, id, /GLOBAL, "contributor_role", "Principal Investigator and originator of total and spectral solar irradiance model, Principal Investigator ensuring overall integrity of the data product, Co-Investigator and Point-of-Contact and translated research-grade code to operational routine with FCDR output data being written out in NetCDF-4"
  
  ; Define Dimensions
  tid = NCDF_DIMDEF(id, 'time', n_elements(dates)) ;time series
  lid = NCDF_DIMDEF(id, 'wavelength',spectral_bins.nband) ;wavelengths
 
  ; Variable Attributes
  x0id = NCDF_VARDEF(id, 'SSI', [lid,tid], /FLOAT)
  NCDF_ATTPUT, id, x0id, 'long_name', 'NOAA Fundamental Climate Data Record of Daily Solar Spectral Irradiance (Watt/ m**2/ nm**1)'
  NCDF_ATTPUT, id, x0id, 'standard_name', 'toa_incoming_shortwave_flux_per_unit_wavelength'
  NCDF_ATTPUT, id, x0id, 'units', 'W m-2 nm-1'
  NCDF_ATTPUT, id, x0id, 'missing_value', missing_value

  
  t0id = NCDF_VARDEF(id,'wavelength',[lid], /FLOAT) 
  NCDF_ATTPUT, id, t0id, 'long_name', 'Wavelength grid center'
  NCDF_ATTPUT, id, t0id, 'units', 'nm'
  NCDF_ATTPUT, id, t0id, 'standard_name','radiation_wavelength'

  t1id = NCDF_VARDEF(id,'Wavelength_Band_Width',[lid], /FLOAT) ;cell-based metadata (ask NCDC how to do this?)
  NCDF_ATTPUT, id, t1id, 'long_name', 'Wavelength band width. Centered on wavelength.'
  NCDF_ATTPUT, id, t1id, 'units', 'nm'  
 
  x1id = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
  NCDF_ATTPUT, id, x1id, 'long_name', 'NOAA Fundamental Climate Data Record of Daily Total Solar Irradiance (Watt/ m**2)'
  NCDF_ATTPUT, id, x1id, 'standard_name', 'toa_incoming_shortwave_flux'
  NCDF_ATTPUT, id, x1id, 'units', 'W m-2'
  NCDF_ATTPUT, id, x1id, 'missing_value', missing_value
 
  x2id = NCDF_VARDEF(id, 'iso_time', [tid], /STRING) 
  NCDF_ATTPUT, id, x2id, 'long_name', 'ISO8601 date/time (YYYY-MM-DD) string'
  
  x3id = NCDF_VARDEF(id,'time',[tid],/FLOAT) ;Fix! This must be an integer or float with a reference time.; ask NCDC what reference day they like? Include iso_time as another variable?
  NCDF_ATTPUT, id, x3id, 'long_name','days since 1858-11-17 00:00:00.0'
  NCDF_ATTPUT, id, x2id, 'standard_name','time'
  
  ; Put file in data mode:
  NCDF_CONTROL, id, /ENDEF
  
  ; Input data:
  NCDF_VARPUT, id, x2id, dates ;YYYY-MM-DD; ISO 8601 standards
  NCDF_VARPUT, id, x3id, data.mjd ;CF-compliant time variable
  NCDF_VARPUT, id, x1id, tsi
  NCDF_VARPUT, id, x0id, ssi
  NCDF_VARPUT, id, t0id, spectral_bins.bandcenter
  NCDF_VARPUT, id, t1id, spectral_bins.bandwidth
  
  ; Close the NetCDF file.
  NCDF_CLOSE, id 
  
  ;TODO: error status
  return, 0
end
