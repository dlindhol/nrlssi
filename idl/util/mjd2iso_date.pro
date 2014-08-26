function mjd2iso_date, mjd

  jd = mjd + 2400000.5
  caldat, jd, mon, day, year
  
  format = '(I4,"-",I02,"-",I02)'
  
  return, string(format=format, year, mon, day)
  
end

