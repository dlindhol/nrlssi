
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

function time_utils_ut::test_get_year_from_iso
  compile_opt strictarr
  
  record = {time: '2014-05-01', value: 0.0}
  year = get_year_from_record(record)
  
  assert, 2014 eq year

  return, 1
end

function time_utils_ut::test_annual_average
  compile_opt strictarr

  records = List()
  records.add, {time: '2014-05-01', value: 1.0}
  records.add, {time: '2014-06-01', value: 2.0}
  records.add, {time: '2015-07-01', value: 3.0}
  records.add, {time: '2015-08-01', value: 4.0}
  averaged = bin_average(records.toarray(), 'year')

  years = averaged.keys()
  assert, 2 eq years.count()
  assert, '2015' eq (years.sort())[1]
  assert, 1.5 eq averaged['2014']
  assert, 3.5 eq averaged['2015']

  return, 1
end

function time_utils_ut::test_monthly_average
  compile_opt strictarr

  records = List()
  records.add, {time: '2014-05-01', value: 1.0}
  records.add, {time: '2014-05-02', value: 2.0}
  records.add, {time: '2014-08-01', value: 3.0}
  records.add, {time: '2014-08-03', value: 4.0}
  averaged = bin_average(records.toarray(), 'month')

  months = averaged.keys()
  assert, 2 eq months.count()
  assert, '2014-08' eq (months.sort())[1]
  assert, 1.5 eq averaged['2014-05']
  assert, 3.5 eq averaged['2014-08']

  return, 1
end




;---------------------------
pro time_utils_ut__define
  compile_opt strictarr
  
  define = { time_utils_ut, inherits MGutTestCase }
end