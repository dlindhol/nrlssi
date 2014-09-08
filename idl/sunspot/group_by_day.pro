;@***h* SOLAR_IRRADIANCE_FCDR/group_by_day.pro
; 
; NAME
;   group_by_day.pro
;
; PURPOSE
;   Bins USAF white light sunspot data by day. 
;
; DESCRIPTION
;   This routine is called from process_sunspot_blocking.pro. It aquires USAF white light sunspot region data from a 
;   NOAA/NGDC web repository and stores it in a structure, 'result', identified by index -> (jd, lat, lon, area, station)
;   
; INPUTS
;   structures - A structure containing (for each record in the USAF data):
;   jd - Modified Julian Date 
;   lat - latitude of sunspot group
;   lon - longitude of sunspot group
;   area - recorded sunspot area
;   station - station name 
;   
; OUTPUTS
;   Returns a Hash where the key is the Julian Day Number and the value is a List of records for that day.  
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
;   group_by_day,structures
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
