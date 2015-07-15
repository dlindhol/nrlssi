function get_historical_tsi, year1, year2, cycle=cycle
  ;add day to end time to make it inclusive
  end_date = mjd2iso_date(iso_date2mjdn(ymd2) + 1)

  ;get the dataset name
  if keyword_set(cycle) then dataset = 'nrl2_historical_tsi_cycle'  $
  else dataset = 'nrl2_historical_tsi'

  ;add query parameters
  ;query = 'convert(time,days since 1858-11-17)' ;convert times to MJD
  ;query += '&rename(time,MJD)' ;rename parameters to match the structures we expect here.

  ;get the data as a list of structures
  data = read_latis_data(dataset, ymd1, end_date, query=query)
  return, data
end
