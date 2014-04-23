; Return a float array containing the given data with
; any NaN replaced by the given value.
function replace_nan_with_value, data, value
  ;TODO: should we use doubles?

  ;Make a copy of the data as floats so 'data' is not impacted.
  result = float(data)
  
  ;Get the indices of the NaNs. Note, we can't use equality tests for NaNs.
  index = where (~ FINITE(data), count)
  
  ;Replace.
  ;Note, do the 'count' test, otherwise no matches means index will be -1 
  ;  which will cause the last sample to be replaced.
  if (count gt 0) then result[index] = value

  return, result

end