pro generate_final_files, output_dir=output_dir

;YEARLY-AVERAGED TSI and SSI
; each data product is stored in a single, period-of-record, file
;nrl2_to_irradiance,'1882-01-01','2014-12-31',time_bin='year',/final,output_dir = output_dir
ymd1 = '1610-01-01' & ymd2 = '2014-12-31'
version = 'v02r00'  ;default to current final release version

;Extract Historical Irradiance data in smaller "chunks", then concatenate the entire record together - speeds processing
data_hist1 = process_historical_irradiance('1610-01-01','1650-12-31',/final,time_bin='year',cycle=cycle)
data_hist2 = process_historical_irradiance('1651-01-01','1699-12-31',/final,time_bin='year',cycle=cycle)
data_hist3 = process_historical_irradiance('1700-01-01','1750-12-31',/final,time_bin='year',cycle=cycle)
data_hist4 = process_historical_irradiance('1751-01-01','1799-12-31',/final,time_bin='year',cycle=cycle)
data_hist5 = process_historical_irradiance('1800-01-01','1850-12-31',/final,time_bin='year',cycle=cycle)
data_hist6 = process_historical_irradiance('1851-01-01','1881-12-31',/final,time_bin='year',cycle=cycle)
data_rout = process_irradiance('1882-01-01', '2014-12-31', /final, time_bin='year')

;concatenate the historical irradiance structure with the routine processing irradiance structure (NOTE: need to fix process_historical_irradiance to include the SSI before can concatenate these structures)
irradiance_data = [data_hist1.data,data_hist2.data,data_hist3.data,data_hist4.data,data_hist5.data,data_hist6.data,data_rout.data]

;Construct resulting data structure, including the spectral bins.
irradiance_data = {wavelength: data_rout.wavelength, data: irradiance_data}
;Write the data files.
status = write_irradiance_data(ymd1,ymd2,irradiance_data, version, time_bin='year', output_dir=output_dir)


;DAILY and MONTHLY-AVERAGED TSI and SSI
; each data product is stored in file spanning one year.
starty = 1882
endy = 2014
nyear = endy - starty + 1

year = starty
for i=0,nyear -1 do begin
  y1 = strtrim(string(year),2)
  ymd1 = y1+'-01-01'
  ymd2=  y1+'-12-31'
  nrl2_to_irradiance,ymd1,ymd2,time_bin='month',/final,output_dir = output_dir
  year = year + 1
endfor

;DAILY TSI and SSI
; each data product is stored in a file spanning one year
starty = 1882
endy = 2014
nyear = endy - starty + 1

year = starty
for i=0,nyear -1 do begin
  y1 = strtrim(string(year),2)
  ymd1 = y1+'-01-01'
  ymd2=  y1+'-12-31'
  nrl2_to_irradiance,ymd1,ymd2,time_bin='day',/final,output_dir = output_dir
  year = year +1
endfor

end; pro