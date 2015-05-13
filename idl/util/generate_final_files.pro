pro generate_final_files, output_dir=output_dir

;YEARLY-AVERAGED TSI and SSI
; each data product is stored in a single, period-of-record, file
nrl2_to_irradiance,'1882-01-01','2014-12-31',time_bin='year',/final,output_dir = output_dir

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