
function time_utils_ut::test_iso_date2jd
  compile_opt strictarr
  
  date = '2014-05-01'
  jd = iso_date2jdn(date)
  
  assert, 'LONG' eq typename(jd)  ;return type should be long
  assert, 2456779 eq jd

  return, 1
end


pro time_utils_ut__define
  compile_opt strictarr
  
  define = { time_utils_ut, inherits MGutTestCase }
end