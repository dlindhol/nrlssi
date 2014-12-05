;make function that extracts yyyy-mm from record
;use it with group_by
; then avg each month
;Input structure:
;    struct = {nrl2,                $
;      mjd:    mjd_start + i,       $
;      iso:    iso_time,             $
;      tsi:    nrl2_tsi.totirrad,   $
;      ssi:    nrl2_ssi.nrl2bin,    $
;      ssitot: nrl2_ssi.nrl2binsum  $
;    }

function get_ym_from_record, record
  return, mjd2iso_yyyymm(record.mjd)
end

function average_by_month, records
  ;Group data by month.
  ;Hash with keys yyyy-mm and array of records as values.
  grouped = group_by_function(records, 'get_ym_from_record')

  ;Number of wavelengths for sizing the array
  nwl = n_elements(records[0].ssi)

  ;Define the result structure
  struct = {nrl2_monthly_mean2, $
    iso: '',            $
    mjd: 0.0,           $
    min_mjd: 0.0,       $
    max_mjd: 0.0,       $
    count: 0,           $
    tsi: 0.0d,           $
    tsi_stddev: 0.0d,    $
    ssi: dblarr(nwl),        $
    ssi_stddev: dblarr(nwl), $
    ssitot: 0.0d,        $
    ssitot_stddev: 0.0d  $
  }
  
  ;Define resulting array of structures
  n = grouped.count() ;number of bins
  result = replicate(struct, n)

  ;Loop over months, make sure they are sorted
  keys = grouped.keys()
  key_array = keys.toArray()
  sorted_months = key_array[sort(key_array)]
  index = 0
  foreach ym, sorted_months do begin
    recs = grouped[ym]
    
    result[index].min_mjd = min(recs.mjd)
    result[index].max_mjd = max(recs.mjd) + 1  ;go up to the start of the next bin (one day later)
    result[index].mjd = (result[index].min_mjd + result[index].max_mjd) / 2  ;midpoint of bin
    result[index].iso = ym  ;yyyy-mm
    result[index].count = n_elements(recs)
    
    result[index].tsi        = mean(recs.tsi, /double)
    result[index].tsi_stddev = stddev(recs.tsi, /double)
    
    ;Note, ssi has an array for each time sample
    ssi = transpose(recs.ssi) ;so we can average over time dimension
    result[index].ssi        = mean(ssi, dimension=1, /double)
    result[index].ssi_stddev = stddev(ssi, dimension=1, /double)
    
    result[index].ssitot        = mean(recs.ssitot, /double)
    result[index].ssitot_stddev = stddev(recs.ssitot, /double)

    index += 1
  endforeach
  
  return, result
end
