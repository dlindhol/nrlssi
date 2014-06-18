;@***h* TSI_FCDR/nrl_2_tsi.pro
; 
; NAME
;   nrl_2_tsi.pro
;
; PURPOSE
;   The nrl_2_tsi.pro procedure computes daily Model Total Solar Irradiance using the Judith Lean (Naval Research Laboratory)
;   model and writes the output to NetCDF4 format.
;
; DESCRIPTION
;   The nrl_2_tsi.pro procedure is the main driver routine that computes the Model Total Solar Irradiance 
;   using the 2-component regression formula, TI = a0 + a1*px + a2*S0*ps/1.e6 
;   Reference describing the solar variability model using a linear combination of sunspot darkening
;   and facular brightening: Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends 
;   and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998.
;   The output data are written to netCDF4 output file.
;   
; INPUTS
;   infile - an ascii text columnar file containing model coefficients and adopted quiet Sun irradiance value
;
; OUTPUTS
;   outfile - user provided output filename (default filename is 'nrl_tsi.nc') that contains a data structure of 
;   Modeled Total Solar Irradiance ('tsi'), 'year', day of year ('doy'), and 'day_number' 
;   (cumulative day number since Jan. 1, 1978) in netCDF4 format.
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
;   04/23/2014 Initial Version prepared for NCDC
; 
; USAGE
;   nrl_2_tsi,infile, outfile
;
;@***** 
PRO nrl_2_tsi,infile,outfile
  ; Define default output file if not provided by the user.
  if (n_elements(outfile) eq 0) then outfile = 'nrl_tsi.nc'

  ; Get the multiple linear regression coefficients for the TSI model
  coeffs = get_tsi_model_coeffs(infile)
  
  ; Get the facular brightening and sunspot blocking functions for the TSI model
  regression_data = get_tsi_model_functions(infile)
  
  ; Compute the TSI model
  model = compute_tsi_model(coeffs, regression_data)
  
  ; Save the model results to NetCDF
  status = write_tsi_model_to_netcdf(model, outfile)

end
