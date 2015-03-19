pro compare_lasp_nrl_sb_v2
;goto, lasp
  nrl_output2 = 'data/judith_2015_02_18/spotAIndC_fac_1882_2014_18Feb15_v3.txt' ;Judith's new (area-independent contrast) file - we will validate against this

  ;template to read NRL ascii file of facular brightening and sunspot darkening functions from file
  temp = {version:1.0, $
    datastart:5L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[3l, 3l, 3l, 4l,4l], $ ; float
    fieldnames:['Year', 'Month', 'Day', 'Spot','Fac'], $
    fieldlocations:[2L, 11L, 17L, 25L, 40L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]}
    
  nrl = read_ascii(nrl_output2, template = temp) ;structure that holds the contents of nrl_output
  ;Replace missing values with NaN (makes plotting easier)
  nrl.Spot = replace_missing_with_nan(nrl.Spot, -999.0)
  nrl.Fac = replace_missing_with_nan(nrl.Fac, -99.0)

  ;compare to Judith's result being served by LaTiS
  
  lean = read_latis_data('lean_spot_fac','1882-01-01','2015-01-01',query='convert(time,days since 1858-11-17)')
  lean = lean.toarray()
  
  p1 = plot(nrl.fac - lean.spot)
  
  
  lasp_ssb= get_sunspot_blocking('1980-01-01','2014-12-31',/final)
  lasp = lasp_ssb.toArray()
  
  ;truncate nrl data to  be same size for comparison with LASP, end 2014-09-30
  sub1 = where(nrl.year eq 1980 and nrl.month eq 1 and nrl.day eq 1)
  sub1 = sub1[0]
  sub2 = where(nrl.year eq 2014 and nrl.month eq 12 and nrl.day eq 31)
  sub2 = sub2[0]

  nrl_year =nrl.year[sub1:sub2]
  nrl_month = nrl.month[sub1:sub2]
  nrl_day = nrl.day[sub1:sub2]

  nrl_mg = nrl.fac[sub1:sub2]
  nrl_sb = nrl.spot[sub1:sub2]

  time = jd2yf4(mjd2jd(lasp.mjdn))

  p = plot(time,nrl_sb - lasp.ssbt,'-k',ytitle='Difference (NRL - LASP)',layout=[1,2,1])
  p1 = plot(time,nrl_sb/lasp.ssbt,'-k',xtitle='Year',ytitle='Ratio (NRL/LASP)',layout=[1,2,2],/current)
   
  p2 = plot(time,nrl.spot - lean.spot)
   
end

