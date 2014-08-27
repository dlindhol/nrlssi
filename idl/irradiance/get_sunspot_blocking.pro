function get_sunspot_blocking_from_routine, ymd1, ymd2
  ;invoke the sunspot blocking routine
  data = process_sunspot_blocking(ymd1, ymd2)
  return, data
end


function get_sunspot_blocking, ymd1, ymd2
  return, get_sunspot_blocking_from_routine(ymd1, ymd2)
end
