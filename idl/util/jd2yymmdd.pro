function jd2yymmdd, jd
;TODO: consider Jan 1 2000
;TODO: deal with dates outside 1950 - 2050

  caldat, jd, mon, day, year

  ;Assume 2-digit year is bewtween 1950 - 2050
  yy = year - 1900
  if (yy ge 100) then yy -= 100 
  
  ;format as yymmdd, fill with 0s
  ymd = yy * 10000 + mon * 100 + day
  
  return, strtrim(ymd,2)
end

