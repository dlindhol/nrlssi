function get_historical_ssi, year1, year2
  ;add year to end time to make it inclusive
  end_year = strtrim(fix(year2) + 1, 2)

  ;get the dataset name
  dataset = 'nrl2_historical_ssi'
  wldataset = 'nrl2_historical_ssi_wavelength'

  ;add query parameters
  ;query = 'convert(time,days since 1858-11-17)' ;convert times to MJD
  ;query += '&rename(time,MJD)' ;rename parameters to match the structures we expect here.

  ;get the data as a list of structures
  ssidata = read_latis_data(dataset, year1, end_year, query=query)
  time_list = List()
  ssi_list = List()
  foreach spectrum, ssidata do begin
    time_list.add, spectrum.time
    foreach sample, spectrum.samples do ssi_list.add, sample.ssi
  endforeach
  time = time_list.toArray()
  ssi = ssi_list.toArray()

  wldata = read_latis_data(wldataset, year1, end_year) ;time doesn't matter but reader requires it
  wlarray = wldata.toArray()
  wavelength = wlarray.wavelength
  bandwidth = wlarray.bandwidth
  
  ;Reform SSI from 1D to 2D, if time elements > 1
  ntime = n_elements(time)
  nwavelength = n_elements(wavelength)
  if ntime gt 1 then ssi = reform(ssi,nwavelength,ntime)
    
  data = {wavelength: wavelength, bandwidth: bandwidth, time: time, ssi: ssi}
  
  return, data
end
