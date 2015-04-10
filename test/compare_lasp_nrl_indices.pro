pro compare_lasp_nrl_indices

;obtain Judith's daily, monthly, and annually averaged indices
nrl_outputa = 'data/judith_2015_04_03/spotAIndC_fac_1882_2014a_6Apr15.txt' ;Judith's new annual averaged indices we will validate against
nrl_outputm = 'data/judith_2015_04_03/spotAIndC_fac_1882_2014m_6Apr15.txt' ;Judith's new monthly averaged indices we will validate against
nrl_outputd = 'data/judith_2015_04_03/spotAIndC_fac_1882_2014d_6Apr15.txt' ;Judith's new daily averaged indices we will validate against
 
;template to read NRL ascii file of annually averaged facular brightening and sunspot darkening functions from file
  tempa = {version:1.0, $
    datastart:5L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:3l, $
    fieldtypes:[3l, 5l,5l], $ ; float
    fieldnames:['FIELD1','SPOT','FAC'], $
    fieldlocations:[2L, 11L, 28L], $
    fieldgroups:[0L, 1L, 2L]}

;template to read NRL ascii file of monthly averaged facular brightening and sunspot darkening functions from file
  tempm = {version:1.0, $
    datastart:5L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:4l, $
    fieldtypes:[3l, 3l,5l,5l], $ ; float
    fieldnames:['FIELD1','FIELD2','SPOT','FAC'], $
    fieldlocations:[2L, 11L, 20L, 36L], $
    fieldgroups:[0L, 1L, 2L, 3L]}
    
;template to read NRL ascii file of daily averaged facular brightening and sunspot darkening functions from file
  tempd = {version:1.0, $
    datastart:5L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[3l, 3l, 3l, 5l,5l], $ ; float
    fieldnames:['FIELD1','FIELD2','FIELD3','SPOT','FAC'], $
    fieldlocations:[2L, 11L, 17L, 25L, 40L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]} 
 
       
  nrl_a = read_ascii(nrl_outputa, template = tempa) ;structure that holds the contents of nrl_outputa
  nrl_m = read_ascii(nrl_outputm, template = tempm) ;structure that holds the contents of nrl_outputm
  nrl_d = read_ascii(nrl_outputd, template = tempd) ;structure that holds the contents of nrl_outputd
 
;obtain LASP's daily, monthly, and annually averaged indices
goto, LASPFILE
  ymd1='1882-01-01'
  ymd2='2014-12-31'
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, /final)
  mg_index = get_mg_index(ymd1, ymd2, /final)

  ssb = bin_average(sunspot_blocking, 'year')
  mgi = bin_average(mg_index, 'year')
  times = (ssb.keys()).toArray()
  index = sort(times)
  times_a = times[index]
  sb_a = (ssb.values()).toArray()
  sb_a = sb_a[index]
  mg_a = (mgi.values()).toArray()
  mg_a = mg_a[index]  
  
  ssb = bin_average(sunspot_blocking, 'month')
  mgi = bin_average(mg_index, 'month')
  times = (ssb.keys()).toArray()
  index = sort(times)
  times_m = times[index]
  sb_m = (ssb.values()).toArray()
  sb_m = sb_m[index]
  mg_m = (mgi.values()).toArray()
  mg_m = mg_m[index]

  ssb = sunspot_blocking.toArray()
  mgi = mg_index.toArray()
  times = ssb.mjdn
  index = sort(times)
  times_d = times[index]
  sb_d = ssb.ssbt
  sb_d = sb_d[index]
  mg_d = mgi.index
  mg_d = mg_d[index]
  
  save,filename='LASP_annual_month_day_indices_1882_2014.sav',times_a,sb_a,mg_a,times_m,sb_m,mg_m,times_d,sb_d,mg_d,/verb
LASPFILE:
  restore,filename='test/LASP_annual_month_day_indices_1882_2014.sav',/verb
  ;make comparison plots
  yf4_a=jd2yf4(mjd2jd(times_a))
  yf4_m=jd2yf4(mjd2jd(times_m))
  yf4_d=jd2yf4(mjd2jd(times_d))

  ;spot
  p=plot(yf4_a,nrl_a.spot-sb_a,title='Spot Differences (NRL - LASP)',layout=[1,3,1],ytitle='Annual Average',font_size=14)
  p1=plot(yf4_m,nrl_m.spot-sb_m,layout=[1,3,2],ytitle='Monthly Average',/current,font_size=14) 
  p2=plot(yf4_d,nrl_d.spot-sb_d,layout=[1,3,3],ytitle='Daily Average',/current,font_size=14)
;  p2b=plot(yf4_d,nrl_dold.spot-sb_d,overplot=1,'r') ;"old" fixed NRL data.
  
 ;fac 
  p=plot(yf4_a,nrl_a.fac-mg_a,title='Facular Differences (NRL - LASP)',layout=[1,3,1],ytitle='Annual Average',font_size=14)
  p1=plot(yf4_m,nrl_m.fac-mg_m,layout=[1,3,2],ytitle='Monthly Average',/current,font_size=14) 
  p2=plot(yf4_d,nrl_d.fac-mg_d,layout=[1,3,3],ytitle='Daily Average',/current,font_size=14)

 ;with fac as float in LASP values
  p=plot(yf4_a,nrl_a.fac-float(mg_a),title='Facular Differences (NRL - LASP)',layout=[1,3,1],ytitle='Annual Average',font_size=14)
  p1=plot(yf4_m,nrl_m.fac-float(mg_m),layout=[1,3,2],ytitle='Monthly Average',/current,font_size=14) 
  p2=plot(yf4_d,nrl_d.fac-float(mg_d),layout=[1,3,3],ytitle='Daily Average',/current,font_size=14,yrange=[-1,1])
  
 



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

