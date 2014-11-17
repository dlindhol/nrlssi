function unix2mjd, unix_time
  mjd_at_1970 = 40587.0d  ;Modified Julian Date at UNIX epoch: 1970-01-01T00:00:00Z
  unix_days = double(unix_time) / 86400.0d  ;days since UNIX epoch
  mjd = mjd_at_1970 + unix_days
  return, mjd
end
