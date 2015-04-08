
function remove_duplicate_records_ut::test
  compile_opt strictarr
    
  ;Create fake data
  struct = {mjd:0.0, lat:0.0, lon:0.0, group:0, area:0.0, station:""}
  
  foo_records = replicate(struct, 3)
  foo_records[0] = {mjd:57000.0, lat:30.0, lon:120.0, group:12345, area:20.0, station:"FOO"}
  foo_records[1] = {mjd:57000.0, lat:31.0, lon:121.0, group:12346, area:21.0, station:"FOO"}
  foo_records[2] = {mjd:57000.0, lat:30.0, lon:120.0, group:12345, area:20.0, station:"FOO"}
  
  bar_records = replicate(struct, 3)
  bar_records[0] = {mjd:57000.0, lat:30.0, lon:120.0, group:12345, area:20.0, station:"BAR"}
  bar_records[1] = {mjd:57000.0, lat:31.0, lon:121.0, group:12346, area:21.0, station:"BAR"}
  bar_records[2] = {mjd:57000.0, lat:30.0, lon:120.0, group:12345, area:20.0, station:"BAR"}
  
  hash = Hash("FOO", foo_records, "BAR", bar_records)
  
  result = remove_duplicate_records(hash, n)
  
  ;number of duplicates
  assert, n eq 2
  
  ;number of resulting records
  assert, n_elements(result["FOO"]) eq 2
  assert, n_elements(result["BAR"]) eq 2

  return, 1
end



pro remove_duplicate_records_ut__define
  compile_opt strictarr
  
  define = { remove_duplicate_records_ut, inherits MGutTestCase }
end