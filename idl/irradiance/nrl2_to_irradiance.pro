;@***h* SOLAR_IRRADIANCE_FCDR/nrl2_to_irradiance.pro
;
; NAME
;   nrl2_to_irradiance
;
; PURPOSE
;   The nrl2_to_irradiance.pro is the main driver procedure.  It calls subfunctions to compute Total Solar Irradiance (TSI) and 
;   Solar Spectral Irradiance (SSI) to write the data output to NetCDF4 formatted files.
;
; DESCRIPTION
;   The nrl2_to_irradiance.pro is the main driver procedure.  It calls subfunctions to compute Total Solar Irradiance (TSI) and 
;   Solar Spectral Irradiance (SSI) to write the data output to NetCDF4 formatted files.
;      
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, of the form 'yyyy-mm-dd'
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), of the form 'yyyy-mm-dd'.
;   final      - Data processing is delegated to the LaTiS server for accessing final released values of model inputs.
;   time_bin   - A value of 'year', 'month', or 'day' that defines the time-averaging performed for the given data records.
;               'day' is the default.
;   version    - version and revision number of the NRLTSI2 and NRLSSI2 models (e.g., v02r00)            
;   output_dir - path to data output directory. 
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
;   nrl2_to_irradiance, ymd1, ymd2, final=final, time_bin=time_bin, version=version, output_dir=output_dir
;
;@*****

pro nrl2_to_irradiance, ymd1, ymd2, final=final, time_bin=time_bin, version=version, output_dir=output_dir

  ;Define the version of the data.
  ;If the version argument is not set, use the default.
  if n_elements(version) eq 0 then version = 'v02r00'  ;default to current final release version
  ;If the 'final' keyword is not set, add 'preliminary' to the version
  if (not keyword_set(final)) then version += '-preliminary'

  ;Generate the data.
  irradiance_data = process_irradiance(ymd1, ymd2, final=final, time_bin=time_bin)

  ;Write the data files.
  status = write_irradiance_data(ymd1,ymd2,irradiance_data, version, time_bin=time_bin, output_dir=output_dir)
  
end

