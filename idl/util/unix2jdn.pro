;Return the given unix time (seconds since 1970-01-01) as a Julian Day Number.
function unix2jdn, unix_time
  jd_at_1970 = 2440587.5d ;1970-01-01T00:00:00Z
  unix_days = unix_time / 86400.0d
  jdn = floor(unix_days + jd_at_1970) ;floor to reduce Julian Date to Julian day Number
  return, jdn
end

;TODO: write tests
;The Julian date for CE  2000 January  1 00:00:00.0 UT is
;JD 2451544.500000
;Epoch timestamp: 946684800
;
;The Julian date for CE  2000 January  1 01:00:00.0 UT is
;JD 2451544.541667
;Epoch timestamp: 946688400
;
;The Julian date for CE  2000 January  1 12:00:00.0 UT is
;JD 2451545.000000
;Epoch timestamp: 946728000
;
;The Julian date for CE  2000 January  1 23:00:00.0 UT is
;JD 2451545.458333
;Epoch timestamp: 946767600
;
;JDN represents the night time period