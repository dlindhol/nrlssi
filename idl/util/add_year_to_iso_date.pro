; Given a date of the form "yyyy-dd-mm" increment the year.
function add_year_to_iso_date, ymd

  year = strtrim(fix(strmid(ymd,0,4)) + 1, 2)
  ymd2 = year + strmid(ymd,4,6)
  
  return, ymd2

end
