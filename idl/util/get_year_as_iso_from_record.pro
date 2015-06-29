function get_year_as_iso_from_record, time
  ;Takes input iso time and converts the day to July 1st (assumes time_bin = year)
  ;
  ;Extract the year
  year = strmid(time, 0, 4) ;yyyy

  ;Set the day to July 1st
  iso = year + '-07-01'

  return, iso
end