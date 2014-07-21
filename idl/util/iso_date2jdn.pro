function iso_date2jdn, ymd
;Convert a date of the form 'yyyy-mm-dd' to a julian day number.
;Note an integral Julian Date represents noon GMT, while the ymd input is 
;interpreted as midnight at the start of the day. IDL's julday will round up
;such that converting the julian back to UTC will be at noon (GMT) of the 
;original date. So, effectively, the input date is treated as noon (GMT) of that day.
;Assumes ymd of the form yyyy-mm-dd
;TODO: should be able to use TIMESTAMPTOVALUES but not found in my 8.2 install!?

  year = fix(strmid(ymd,0,4))
  mon  = fix(strmid(ymd,5,2))
  day  = fix(strmid(ymd,8,2))

  jd = julday(mon, day, year)
  
  return, jd
  
end

