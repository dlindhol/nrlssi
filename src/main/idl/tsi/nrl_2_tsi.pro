;@***h* TSI_FCDR/nrl_2_tsi.pro
; 
; NAME
;   nrl_2_tsi.pro
;
; PURPOSE
;   The nrl_2_tsi.pro procedure computes Judith Lean (Naval Research Laboratory) daily
;   Model Total Solar Irradiance and writes the output to NetCDF4 format.
;
; DESCRIPTION
;   The nrl_2_tsi.pro procedure is the main routine that applies pre-computed multi-regression 
;   coefficients to facular brightening and sunspot blocking functions in 2-component formula
;   (Judith Lean-Naval Research Laboratory) to compute daily Model Total Solar Irradiance. The 
;   model output is written to NetCDF4 format.
;   Reference describing the solar variability model using a linear combination of sunspot darkening
;   and facular brightening: Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends 
;   and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998.
;   
;   2-Component regression formula and coefficients: TI = a0 + a1*px + a2*S0*ps/1.e6
;   
; INPUTS
;   infile - is an ascii text columnar file from which the following inputs and 2-component 
;            multiple regression output are obtained:
;   PS     - sunspot blocking function computed using area-dependent contrasts - Dec 05
;   PX     - facular brightening function from Viereck, R. A., et al. (2004), Space Weather, 2, S100005 
;            and SORCE Mg index
;   S0     - adopted value of quiet Sun irradiance
;   a0     - constant term in the multiple linear regression 
;   a1     - multiple linear regression coefficient for the relative sunspot component (darkening) contribution
;   a2     - multple linear regression coefficient for the relative facular component (brightening) contribution
;
; OUTPUTS
;   in netCDF4 format (output filename will be named 'nrl_tsi.nc')
;   TSI        - daily Total Solar irradiance (units W/m2) derived from multi-regression formula 
;                (from 1 JAN 1978 to 31 DEC 2005)
;   Year       - Year (1978, 1979, etc.)
;   DOY        - Day of Year (from 1 to 365; then repeats for next year, etc.)
;   Day_Number - Day Number (cumulative from start of time series; Day number 1 is 1 JAN 1978)  
;
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
;   02/04/2014 Initial Version prepared for NCDC
; 
; USAGE
;   nrl_2_tsi,infile
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
