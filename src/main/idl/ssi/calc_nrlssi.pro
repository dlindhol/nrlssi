pro calc_nrlssi
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

  uv_params = get_uv_model_params()
  
  spectrum = compute_spectrum(px, ps, spectrum_params, uv_params)
  
  status = write_spectrum(yr, mn, dy, spectrum)

end
