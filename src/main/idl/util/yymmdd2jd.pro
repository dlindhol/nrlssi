function yymmdd2jd, yymmdd
;TODO: consider Jan 1 2000

  yy = fix(strmid(yymmdd,0,2))
  mm = fix(strmid(yymmdd,2,2))
  dd = fix(strmid(yymmdd,4,2))

  ;Assume 2-digit year is bewtween 1950 - 2050
  year = 1900 + yy
  if (yy lt 50) then year += 100 ;20yy
  
  jd = julday(mm, dd, year)
  
  return, jd
  
end

