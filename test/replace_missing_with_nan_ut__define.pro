
function replace_missing_with_nan_ut::test_one_value_missing
  compile_opt strictarr
  
  data = [1.0,-999,3.0]
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 1
  assert, result[0] eq 1.0
  assert, result[1] ne -999

  return, 1
end

function replace_missing_with_nan_ut::test_first_value_missing
  compile_opt strictarr
  
  data = [-999,2.0,3.0]
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 1
  assert, result[0] ne -999

  return, 1
end

function replace_missing_with_nan_ut::test_last_value_missing
  compile_opt strictarr
  
  data = [1.0,2.0,-999]
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 1
  assert, result[2] ne -999

  return, 1
end

function replace_missing_with_nan_ut::test_all_values_missing
  compile_opt strictarr
  
  data = [-999,-999,-999]
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 3
  assert, result[0] ne -999

  return, 1
end

function replace_missing_with_nan_ut::test_no_missing_data
  compile_opt strictarr
  
  data = [1.0,2.0,3.0]
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 0

  return, 1
end

function replace_missing_with_nan_ut::test_missing_scalar
  compile_opt strictarr
  
  data = -999
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 1
  assert, result[0] ne -999

  return, 1
end

function replace_missing_with_nan_ut::test_not_missing_scalar
  compile_opt strictarr
  
  data = 1.0
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 0
  assert, result[0] eq 1.0

  return, 1
end

function replace_missing_with_nan_ut::test_immutability
  compile_opt strictarr
  
  data = [1.0,-999,3.0]
  result = replace_missing_with_nan(data, -999)
  assert, data[1] eq -999
  assert, result[1] ne -999

  return, 1
end

function replace_missing_with_nan_ut::test_integers
  compile_opt strictarr
  
  data = [1,-999,3]
  result = replace_missing_with_nan(data, -999)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 1
  assert, result[0] eq 1
  assert, result[1] ne -999

  return, 1
end

function replace_missing_with_nan_ut::test_doubles
  compile_opt strictarr
  
  data = [1d,-999d,3d]
  result = replace_missing_with_nan(data, -999d)
  tmp = where(finite(result, /nan) ne 0, nan_count)
  assert, nan_count eq 1
  assert, result[0] eq 1d
  assert, result[1] ne -999d

  return, 1
end


pro replace_missing_with_nan_ut__define
  compile_opt strictarr
  
  define = { replace_missing_with_nan_ut, inherits MGutTestCase }
end