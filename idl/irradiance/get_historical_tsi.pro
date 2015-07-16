function get_historical_tsi, ymd1, ymd2, cycle=cycle
  ;These are yearly data but we still need to specify month and day in the ymd format.
  ;Sample usage: tsi = get_historical_tsi('1880-01-01', '1882-12-31')

  ;get the dataset name
  if keyword_set(cycle) then dataset = 'nrl2_historical_tsi_cycle'  $
  else dataset = 'nrl2_historical_tsi'

  ;get the data as a list of structures
  data = read_latis_data(dataset, ymd1, ymd2)
  return, data
end
