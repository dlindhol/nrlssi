function yymmdd2mjd, yymmdd

  yy = fix(strmid(yymmdd,0,2))
  mm = fix(strmid(yymmdd,2,2))
  dd = fix(strmid(yymmdd,4,2))

  ;Assume 2-digit year is in the set [1950 - 2050)
  if (yy lt 50) then year = 2000 + yy  $
  else year = 1900 + yy
  
  mjd = julday(mm, dd, year) - 2400000.5
  
  return, mjd
  
end

