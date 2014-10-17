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
