function jd2iso_date, jd

  caldat, jd, mon, day, year
  
  format = '(I4,"-",I02,"-",I02)'
  
  return, string(format=format, year, mon, day)
  
end

