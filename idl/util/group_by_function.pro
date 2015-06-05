;@***h* SOLAR_IRRADIANCE_FCDR/group_by_function.pro
;
; NAME
;   group_by_function
;
; PURPOSE
;   When given the name of a function that takes a structure as an argument, uses its return value as the key.
;   
; DESCRIPTION
;   When given the name of a function that takes a structure as an argument, uses its return value as the key.
;
; INPUTS
;   structures - A structure or list of structures 
;   hash_function - Name of the hash function
;
; OUTPUTS
;   result - an IDL Hash containing the key components of the structure 
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
;   result=group_by_function(structures, hash_function)
;
;@*****

function group_by_function, structures, hash_function
  
  ;Define Hash to contain the results.
  result = Hash()
  
  for i = 0, n_elements(structures)-1 do begin
    key = call_function(hash_function, structures[i])
    ;Lists aren't well supported so make Arrays :-(
    if result.hasKey(key) then result[key] = [temporary(result[key]), structures[i]]  $  ;append to array
    else result[key] = [structures[i]]  ;new array
  endfor
  
  return, result

end
