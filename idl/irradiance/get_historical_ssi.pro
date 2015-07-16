function get_historical_ssi, ymd1, ymd2
  ;These are yearly data but we still need to specify month and day in the ymd format.
  ;Sample usage: tsi = get_historical_tsi('1880-01-01', '1882-12-31')

  ;get the dataset name
  dataset = 'nrl2_historical_ssi'
  wldataset = 'nrl2_historical_ssi_wavelength'

  ;get the data as a list of structures
  ssidata = read_latis_data(dataset, ymd1, ymd2)
  time_list = List()
  ssi_list = List()
  foreach spectrum, ssidata do begin
    time_list.add, spectrum.time
    foreach sample, spectrum.samples do ssi_list.add, sample.ssi
  endforeach
  time = time_list.toArray()
  ssi = ssi_list.toArray()

  ;get the wavelengths and bandwidth
  wldata = read_latis_data(wldataset, ymd1, ymd2) ;time doesn't matter but reader requires it
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
