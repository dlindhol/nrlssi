function iso_date2ddMonyy, ymd

  yy = strmid(ymd,2,2)
  mm = fix(strmid(ymd,5,2))
  dd = strmid(ymd,8,2)

  months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  mon = months[mm-1]

  dmy = dd + mon + yy

  return, dmy
end
