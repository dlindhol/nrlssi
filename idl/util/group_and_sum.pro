;Group the data into a hash by the keys with each value being 
;the sum of the values with the matching key
function group_and_sum, keys, values
  ;TODO: assert both have same length

  ;Define Hash to contain the results.
  result = Hash()
  
  for i = 0, n_elements(keys)-1 do begin
    key = keys[i]
    if result.hasKey(key) then result[key] += values[i]  $
    else result[key] = values[i]
  endfor

  return, result
  
end
