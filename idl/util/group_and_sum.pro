;Group the data into a hash by the keys with each value being 
;the sum of the values with the matching key
function group_and_sum, keys, values, nan_as_zero=nan_as_zero
  ;TODO: assert both have same length

  ;Define Hash to contain the results.
  result = Hash()
  
  for i = 0, n_elements(keys)-1 do begin
    key = keys[i]
    value = values[i]
    if keyword_set(nan_as_zero) and finite(value, /nan) then value = 0
    if result.hasKey(key) then result[key] += value  $
    else result[key] = value
  endfor

  return, result
  
end
