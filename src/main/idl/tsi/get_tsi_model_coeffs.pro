;@***h* TSI_FCDR/get_tsi_model_coeffs.pro
; 
; NAME
;   get_tsi_model_coeffs.pro
;
; PURPOSE
;   The get_tsi_model_coeffs.pro function extracts an array of TSI model coefficients 
;   specific to the NRLTSI-2 model contained in [insert file name here].This function is 
;   called from the main routine, nrl_2_tsi.pro.
;
; DESCRIPTION
;   This routine returns a structure containing TSI model coefficients ('coeffs') to the main routine, nrl_2_tsi.pro.
; 
; INPUTS
;   None (TODO: Update if file passed as input)
;   
; OUTPUTS
;   structure containing TSI model coefficients
;   a0 = constant term in the multiple linear regression 
;   a1 = multiple linear regression coefficient for the relative sunspot component (darkening) contribution
;   a2 = multple linear regression coefficient for the relative facular component (brightening) contribution
;   S0 = adopted value of the quiet Sun irradiance (1360.700 Watt/m**2) 

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
;   04/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   get_tsi_model_coeffs
;
;@***** 
function get_tsi_model_coeffs

  openr,1,'data/tsi_mod_mr2_13Feb13.txt'
  line=''
  while not eof(1) do begin
    readf,1,line
    if strmid(line,5,5) eq 'quiet' then reads,strmid(line,21,10),S0, format = '(f16.6)'
    if strmid(line,1,2) eq 'a0' then reads,strmid(line,4,16),a0,format = '(f16.6)'
    if strmid(line,1,2) eq 'a1' then reads,strmid(line,4,16),a1,format = '(f16.6)'
    if strmid(line,1,2) eq 'a2' then reads,strmid(line,4,16),a2,format = '(f16.6)'
  endwhile
  close,1
  
  struct = {tsi_model_coeffs, a0:a0, a1:a1, a2:a2, S0:S0}
  return, struct
  
end
