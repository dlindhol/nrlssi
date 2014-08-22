;Return the month and day for a given Julian Date as a mmdd string.
function jd2mmdd, jd

  caldat, jd, mon, day
  
  format = '(I02,I02)'
  
  return, string(format=format, mon, day)
  
end

