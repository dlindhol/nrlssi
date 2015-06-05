;@***h* SOLAR_IRRADIANCE_FCDR/group_by_day.pro
; 
; NAME
;   group_by_day.pro
;
; PURPOSE
;   Bins USAF white light sunspot data by day. 
;
; DESCRIPTION
;   This routine is called from process_sunspot_blocking.pro. Using a structure containing USAF white light sunspot region data 
;   (from get_sunspot_data.pro), it returns a Hash where the key is the modified julian day number and the value is a list of sunspot records 
;   for that modified julian day number
;   
; INPUTS
;   structures - A structure containing (for each record in the USAF data):
;     mjd - Modified Julian Date 
;     lat - latitude of sunspot group
;     lon - longitude of sunspot group
;     group   - sunspot group number 
;     area - recorded sunspot area
;     station - station name 
;   
; OUTPUTS
;   result - an IDL Hash (compound data type of key-value pair) where the key is the Julian Day Number 
;            and the value is a List of records for that day.  
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
;   result=group_by_day(structures)
;
;@***** 
function group_by_day, structures

  ;Define Hash to contain the results.
  result = Hash()
  
  for i = 0, n_elements(structures)-1 do begin
    mjdn = floor(structures[i].mjd)
    ;Lists aren't well supported so make Arrays :-(
    if result.hasKey(mjdn) then result[mjdn] = [temporary(result[mjdn]), structures[i]]  $
    else result[mjdn] = [structures[i]]
  endfor

  return, result
  
end
