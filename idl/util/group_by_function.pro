; Given the name of a funtion that takes a structure as an argument, use its return value as the key
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
