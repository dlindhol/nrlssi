function get_historical_tsi, ymd1, ymd2, cycle=cycle
  ;add year to end time to make it inclusive
  end_date = add_year_to_iso_date(ymd2)

  ;get the dataset name
  if keyword_set(cycle) then dataset = 'nrl2_historical_tsi_cycle'  $
  else dataset = 'nrl2_historical_tsi'

  ;get the data as a list of structures
  data = read_latis_data(dataset, ymd1, end_date, query=query, host='localhost', port=8080)
  return, data
end
