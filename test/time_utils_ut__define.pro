
function time_utils_ut::test_mjd2iso_date
  compile_opt strictarr
  
  mjd = 56778
  ymd = mjd2iso_date(mjd)
  
  assert, '2014-05-01' eq ymd

  return, 1
end

function time_utils_ut::test_mjd2iso_yyyymm
  compile_opt strictarr
  
  mjd = 56778
  ym = mjd2iso_yyyymm(mjd)
  
  assert, '2014-05' eq ym

  return, 1
end

function time_utils_ut::test_mjd2iso_yyyy
  compile_opt strictarr
  
  mjd = 56778
  y = mjd2iso_yyyy(mjd)
  
  assert, '2014' eq y

  return, 1
end

function time_utils_ut::test_iso_to_dmy
  compile_opt strictarr
  
  dmy = iso_date2ddMonyy('2000-01-01')
  
  assert, '01Jan00' eq dmy

  return, 1
end

function time_utils_ut::test_mjd_iso_conversion_leap_year
  compile_opt strictarr
  
  date = '2012-02-28'
  date2 = mjd2iso_date(iso_date2mjdn(date) + 1 )
  
  assert, '2012-02-29' eq date2

  return, 1
end

function time_utils_ut::test_mjd_iso_conversion_end_of_year
  compile_opt strictarr
  
  date = '2014-12-31'
  date2 = mjd2iso_date(iso_date2mjdn(date) + 1 )
  
  assert, '2015-01-01' eq date2

  return, 1
end

function time_utils_ut::test_iso_date2mjd
  compile_opt strictarr
  
  date = '2014-05-01'
  mjd = iso_date2mjdn(date)
  
  assert, 'LONG' eq typename(mjd)  ;return type should be long
  assert, 56778 eq mjd

  return, 1
end


pro time_utils_ut__define
  compile_opt strictarr
  
  define = { time_utils_ut, inherits MGutTestCase }
end