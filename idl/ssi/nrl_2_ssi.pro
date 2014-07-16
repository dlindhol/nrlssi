;@***h* TSI_FCDR/nrl_2_ssi.pro
; 
; NAME
;   nrl_2_ssi.pro
;
; PURPOSE
;   The calc_nrlssi.pro procedure computes daily Model Spectral Solar Irradiance using the Judith Lean (Naval Research Laboratory)
;   model and writes the output to NetCDF4 format.
;
; DESCRIPTION
;   The calc_nrlssi.pro procedure is the main driver routine that computes the Model Spectral Solar Irradiance 
;   using the 2-component regression formula, TI = a0 + a1*px + a2*S0*ps/1.e6 as a function of wavelength
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
;   nrl_2_ssi
;
;@***** 
pro nrl_2_ssi
  ;for 1 Jan 2003
  dy=1
  mn=1
  yr=2003
  px=0.2747
  ps=79.76
;
; for checking calculations quickly ...spectrum calculated using actual model 
; (on 3 Feb 2013) with these px and ps inputs is in the file 
; NRLSSI_1Jan2003_13Feb13.txt
;
; the TSI, detemined independently, and the ps and px inputs, from 2000
; to 2012 are in the file NRLTSI_2000_2012d_13Feb13.txt
;
; using the px and ps values input to this current program 
; shold produce the spectral irradiance in the file 
; NRLSSI_spectra_2000_2012d_13Feb13.txt, from which the 
; spectrum on 1 Jan 2003 (NRLSSI_1Jan2003_13Feb13.txt) was extracted


  spectrum_params = get_spectrum_params()

  uv_params = get_uv_spectrum_params()
  
  spectrum = compute_spectrum(px, ps, spectrum_params, uv_params)
  
  status = write_spectrum(yr, mn, dy, spectrum)

end