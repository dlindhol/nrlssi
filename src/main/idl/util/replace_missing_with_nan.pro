; Return a float array containing the given data with
; missing values replaced with NaN (not a number).
function replace_missing_with_nan, data, missing_value
  ;TODO: should we use doubles?

  ;Make a copy of the data as floats:
  ;1) so 'data' remains immutable
  ;2) the result will be consistent with having float NaNs.
  result = float(data)
  
  ;Get the indices of the elements with missing values.
  index_of_missing = where (data eq missing_value, count)
  
  ;Replace missing values with NaN.
  ;Note, do the 'count' test, otherwise no matches means index will be -1 
  ;  which will cause the last sample to be replaced.
  if (count gt 0) then result[index_of_missing] = !VALUES.F_NAN

  return, result

end