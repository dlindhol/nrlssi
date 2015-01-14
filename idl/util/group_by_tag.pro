;@***h* SOLAR_IRRADIANCE_FCDR/group_by_tag.pro
; 
; NAME
;   group_by_tag.pro
;
; PURPOSE
;   Given an array of structures and the name (a tag) in those structures,
;   creates a Hash where each value of that tag becomes a key and the value
;   for each key is an array of the structures that has that value of that tag.
;   Does not modify the original structures.
;
; DESCRIPTION
;   Called by process_sunspot_blocking.pro
;   Makes a Hash mapping station name to an array of observations by that station.
;   station -> (i -> (mjd, lat, lon, group, area, station))

;   
; INPUTS
;   structures - A structure containing, for each day of records in the USAF data:
;     mjd - Modified Julian Date 
;     lat - latitude of sunspot group
;     lon - longitude of sunspot group
;     group   - sunspot group number 
;     area - recorded sunspot area
;     station - station name 
;   tag - an array of USAF station names  
;   
; OUTPUTS
;   result - a Hash where the key is the USAF station name and the value is a List of sunspot records for that station (for a particular day).  
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
;   01/14/2015 Initial Version prepared for NCDC
; 
; USAGE
;   group_by_tag,structures, tag
;
;@***** 
; Given an array of structures and the name a tag in those structures
; create a Hash where each value of that tag becomes a key and the value
; for each key is an array of the structures that have that value of that tag.
; Note, the original structures will not be modified.
function group_by_tag, structures, tag

  ;Define Hash to contain the results.
  result = Hash()
  
  ;IDL will consider the tag names as upper case so make sure the one we are looking for is.
  tag_upper = STRUPCASE(tag)
  
  ;Get the tag names and find the index of the one we want to use for the key.
  tags = tag_names(structures[0])
  tag_index = where(tags eq tag_upper, n)
  ;TODO: if n ne 1
    
  for i = 0, n_elements(structures)-1 do begin
    key = structures[i].(tag_index)
    ;Lists aren't well supported so make Arrays :-(
    if result.hasKey(key) then result[key] = [temporary(result[key]), structures[i]]  $  ;append to array
    else result[key] = [structures[i]]  ;new array
  endfor

  return, result
  
end
