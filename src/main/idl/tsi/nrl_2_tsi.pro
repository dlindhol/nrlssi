;@***h* TSI_FCDR/nrl_2_tsi.pro
; 
; NAME
;   nrl_2_tsi.pro
;
; PURPOSE
;   The nrl_2_tsi.pro routine reads pre-tabulated output of facular brightening (PX) and photometric
;   sunspot blocking (PS) and computes daily TSI (TI) from these values according to a multi-regression
;   formula.  The formula and coefficients (a0, a1, a2, and S0) for the multi-regression are 
;   identified in the routine are computed by Judith Lean.  The routine writes the output 
;   to NetCDF4 format.
;
; DESCRIPTION
;   This routine reads a text file of multiple regression output and computes a daily TSI value. 
;   Missing values are replaced with NaN values. The output data are written to a NetCDF4 file named
;   nrl_tsi.nc
;   Reference describing the solar variability model using a linear combination of sunspot darkening
;   and facular brightening: Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends 
;   and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998.
; 
; INPUTS
;   the input file 'infile' is an ascii text columnar file from which the following inputs and
;   2-component multiple regression output are obtained:
;   TSI measurements (TSI data)
;   sunspot blocking (PS): using area-dependent contrasts - Dec 05
;   facular brightening (PX): from Viereck, R. A., et al. (2004), Space Weather, 2, S100005 
;   and SORCE Mg index
;   quiet Sun (S0) =  1360.700 Watt/m**2
;   2-Component regression formula and coefficients: TI = a0 + a1*px + a2*S0*ps/1.e6
;                                                    a0 = 1327.371582
;                                                    a1 = 126.925819
;                                                    a2 = -1.351869
;
; OUTPUTS
;   in netCDF4 format (output filename will be named 'nrl_tsi.nc')
;   TSI        = daily Total Solar irradiance (units W/m2) derived from multi-regression formula 
;                (from 1 JAN 1978 to 31 DEC 2005)
;   Year       = Year (1978, 1979, etc.)
;   DOY        = Day of Year (from 1 to 365; then repeats for next year, etc.)
;   Day_Number = Day Number (cumulative from start of time series; Day number 1 is 1 JAN 1978)  
;
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
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


PRO nrl_2_tsi,infile

  ; Get the multiple linear regression coefficients for the TSI model
  coeffs = get_tsi_model_coeffs()
  
  ; Get the facular brightening and sunspot blocking functions for the TSI model
  regression_data = get_tsi_model_functions(infile)
  
  ; Compute the TSI model
  model = compute_tsi_model(coeffs, regression_data)
  
  ; Save the model results to NetCDF
  status = write_tsi_model_to_netcdf(model, 'nrl_tsi.nc')

end
