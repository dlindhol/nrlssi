;@***h* TSI_FCDR/group_by_day.pro
; 
; NAME
;   group_by_day.pro
;
; PURPOSE
;   Bins USAF white light sunspot data by UTC day. 
;
; DESCRIPTION
;   This routine is called from the main driver, process_sunspot_blocking.pro. 
;   It takes the USAF white light sunspot data (binned by index) from get_sunspot_data.pro and bins the 
;   data by UTC time. 
;   
; INPUTS
;   structures - Data structure containing (for each record in the USAF data):
;                jd - Julian Date (converted from yymmdd) 
;                lat - latitude of sunspot group
;                lon - longitude of sunspot group
;                area - sunspot area
;                station - station name four digit year (i.e. 1978) (TODO: update to time range args)
;   
; OUTPUTS
;   Returns a Hash where the key is the Julian Day Number and the value is a List of records for that day.  The list
;   of records is defined above under the heading 'Inputs'. 
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
;   04/09/2014 Initial Version prepared for NCDC
; 
; USAGE
;   group_by_day,structures
;
;@***** 
function group_by_day, structures
;Note Julian Day Number represents noon on a UTC day.
;Round JD to nearest JDN so data are binned by UTC day.

  ;Define Hash to contain the results.
  result = Hash()
  
  for i = 0, n_elements(structures)-1 do begin
    jdn = round(structures[i].jd)
    ;if result.hasKey(jdn) then result[jdn].add, structures[i]  $
    ;else result[jdn] = List(structures[i])
    ;Lists aren't well supported so make Arrays :-(
    if result.hasKey(jdn) then result[jdn] = [temporary(result[jdn]), structures[i]]  $
    else result[jdn] = [structures[i]]
  endfor

  return, result
  
end
