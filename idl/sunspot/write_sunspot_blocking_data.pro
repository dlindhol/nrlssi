;@***h* SOLAR_IRRADIANCE_FCDR/write_sunspot_blocking.pro
; 
; NAME
;   write_sunspot_blocking.pro
;
; PURPOSE
;   The write_sunspot_blocking.pro procedure outputs time, sunspot darkening index, the standard deviation of the sunspot darkening index,
;   and a quality flag to an output text file.
;
; DESCRIPTION
;   This routine is executed only if an optional keyword input, 'output_dir', is set in process_sunspot_blocking.pro.
;   The write_sunspot_blocking.pro procedure outputs time, sunspot darkening index, the standard deviation of the sunspot darkening index,
;   and a quality flag to an output text file.  This intermediate file is used in QA analysis.                                                    
;   The file- naming convention of the output follows 'sunspot_blocking_YMD1_YMD2_VER.txt', where time ranges specify start/end date 
;   of the time range over which the sunspot darkening is computed, and 'VER' is a hardcoded development version value to help keep track of 
;   data output.
;                                     
; INPUTS
;   sunspot_blocking_data - a structure containing the following variables:
;   mjdn - the modified julian date (converted from YYYY-MM-DD format) 
;   ssbt - the sunspot darkening index (a mean value of the reporting stations)
;   dssbut - the standard deviation of the sunspot darkening index
;   quality flag - a value of 0 or 1 (1 = missing data); Used for QA analysis.
;   
; OUTPUTS
;   file - a text file of the data in the sunspot_blocking_data structure
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
;   09/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   write_sunspot_blocking,sunspot_blocking_data,file
;
;@***** 
pro write_sunspot_blocking_data, sunspot_blocking_data, file
;sunspot_blocking_data: array of structures
;  ssb_struct = {sunspot_blocking,  $
;    mjdn:0l,  $
;    ssbt:0.0, dssbt:0.0,   $
;    ssbuv:0.0, dssbuv:0.0, $
;    quality_flag:0         $
;  }

;TODO: test if sunspot_blocking_data is empty
  
  ;open output file
  openw, 8, file
  
  ;Iterate over days
  for i = 0, n_elements(sunspot_blocking_data)-1 do begin
    mjdn = sunspot_blocking_data[i].mjdn
    ymd = mjd2iso_date(mjdn)  ;yyyy-mm-dd
    s = sunspot_blocking_data[i]
    printf, 8, format='(A10,4F10.2,I4)', ymd, s.ssbt, s.dssbt, s.ssbuv, s.dssbuv, s.quality_flag
  endfor

  close, 8
  
end
