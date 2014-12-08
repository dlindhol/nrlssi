pro compare_lasp_nrl_sb
;goto, lasp
  nrl_output = 'data/spot_fac_1882_2014.txt';Judith's new (area-dependent contrast) file
  nrl_output2 = 'data/spotAIndC_fac_1882_2014_21Nov14.txt' ;Judith's new (area-independent contrast) file - we will validate against this

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

LASP:
  ;LASP file - output from process_sunspot_blocking.pro with NaN replaced with 0
  lasp_sb_output = 'sunspot_blocking_1979-01-01_2014-09-30_v0.10_area_dependent.txt' ;area-dependent contrast
  lasp_sb_output2 = 'sunspot_blocking_1979-01-01_2014-09-30_v0.10_area_independent.txt' ;area-independent contrast 
    ;template to read LASP ascii file
  temp2 = {version:1.0, $
    datastart:0L, $
    delimiter:32b, $
    missingvalue:'NaN', $
    commentsymbol:'', $
    fieldcount:6l, $
    fieldtypes:[7l, 4l, 4l, 4l, 4l,2l], $ ; float
    fieldnames:['YMD', 'SSBT', 'DSSBT', $
    'SSBUV','DSSBUV','QAFLAG'], $
    fieldlocations:[0L, 17L, 27L, 37L, 47L,53L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L]}
    
  lasp = read_ascii(lasp_sb_output2,template = temp2) ; structure that hold the contest of lasp_sb_output2
  area_dep=read_ascii(lasp_sb_output,template=temp2)
  area_indep=read_ascii(lasp_sb_output2,template=temp2)
  
  
  ;truncate nrl data to year 1981-12-01 to be same size for comparison with LASP, end 2014-09-30
  sub1 = where(nrl.year eq 1981 and nrl.month eq 12 and nrl.day eq 1)
  sub1 = sub1[0]
  sub2 = where(nrl.year eq 2014 and nrl.month eq 9 and nrl.day eq 30)
  sub2 = sub2[0]
  ;sub = where(nrl.year eq 2000)
  nrl_year =nrl.year[sub1:sub2]
  nrl_month = nrl.month[sub1:sub2]
  nrl_day = nrl.day[sub1:sub2]
;  nrl_doy = nrl.doy[sub]
;  nrl_tsi2 = nrl.tsi2[sub]
  nrl_mg = nrl.fac[sub1:sub2]
  nrl_sb = nrl.spot[sub1:sub2]
  l1 = where(lasp.ymd eq '1981-12-01')
  l1 = l1[0]
  lasp_sb = lasp.ssbt[l1:*]
  lasp_ymd = lasp.ymd[l1:*]
  time = jd2yf4(mjd2jd(iso_date2mjdn(lasp_ymd)))
  
  ;make plots
;  goto, subset
 
  p1 = plot(time,lasp_sb,'-k',xtitle='Date',ytitle='Sunspot Blocking Index',name='LASP',margin = [0.2,0.2,0.05,0.05])
  p2 = plot(time,nrl_sb,'+r',overplot=1,name='NRL')
  p2.sym_size = 0.4
  l = legend(target=[p1,p2],/data)
  
  ;Plot difference and ratio in Results
  p3 = plot(time,lasp_sb - nrl_sb,'.k',xtitle='Date',ytitle='Difference in Sunspot Blocking Index',$
      name='LASP minus NRL',margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,1],title='LASP minus NRL')
  ;l2 = legend(target=[p3],/data)
  
  ;Plot Ratio of Results on Same Figure
  p4 = plot(time,lasp_sb/nrl_sb,'.k',xtitle='Date',ytitle='Ratio in Sunspot Blocking Index',$
      name='LASP divided by NRL',/ylog,margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,2],current=1,title='LASP divided by NRL')
  ;l3 = legend(target=[p4],/data)  
  
  
  
  ;Plot Results
  p1 = plot(nrl_doy,lasp_sb,'-k',xtitle='Days Since 01/01/1978',ytitle='Sunspot Blocking Index',name='LASP',margin=[0.2,0.2,0.05,0.05])
  p2 = plot(nrl_doy,nrl_sb,'+r',overplot=1,name='NRL')
  p2.sym_size = 0.4
  l = legend(target=[p1,p2],/data)
  
  ;Plot Difference in Results
  p3 = plot(nrl_doy,lasp_sb - nrl_sb,'-k',xtitle='Days Since 01/01/1978',ytitle='Difference in Sunspot Blocking Index',$
      name='LASP minus NRL',margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,1],title='LASP minus NRL')
  ;l2 = legend(target=[p3],/data)
  
  ;Plot Ratio of Results on Same Figure
  p4 = plot(nrl_doy,lasp_sb/nrl_sb,'-k',xtitle='Days Since 01/01/1978',ytitle='Ratio in Sunspot Blocking Index',$
      name='LASP divided by NRL',margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,2],current=1,title='LASP divided by NRL')
  ;l3 = legend(target=[p4],/data)
 
subset:
; Comparisons from 2012-current, only
  sp = 12419 ; = doy for 2012-01-01
  p1b = plot(nrl_doy(sp:*),lasp_sb(sp:*),'-k',xtitle='Cumulative Day (subset from 2012-01-01 to current)',ytitle='Sunspot Blocking Index',$
    name='LASP',margin=[0.2,0.2,0.05,0.05])
  p2b = plot(nrl_doy(sp:*),nrl_sb(sp:*),'+r',overplot=1,name='NRL')
  p2b.sym_size = 0.4
  lb = legend(target=[p1b,p2b],/data)
 

  ;Plot Difference in Results (2012-current, only)
  p3b = plot(nrl_doy(sp:*),lasp_sb(sp:*) - nrl_sb(sp:*),'-k',xtitle='Cumulative Day (subset from 2012-01-01 to current)',$
      ytitle='Difference in Sunspot Blocking Index',name='LASP minus NRL',margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,1],title='LASP minus NRL')
  ;l2b = legend(target=[p3b],/data)
  
  ;Plot Ratio of Results (2012-current, only)
  p4b = plot(nrl_doy(sp:*),lasp_sb(sp:*)/nrl_sb(sp:*),'-k',xtitle='Cumulative Day (subset from 2012-01-01 to current)',$
    ytitle='Ratio in Sunspot Blocking Index',name='LASP divided by NRL',/ylog,margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,2],current=1,title='LASP divided by NRL')
  ;l3b = legend(target=[p4b],/data)
  
  
  ;p5b = plot(nrl_doy(sp:*),lasp.qaflag(sp:*),'ok',name='QA Flag',/ylog,margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,2],current=1,title='LASP divided by NRL')
  
stop  
  
;  ;Display QA flag
;  p4 = plot(nrl_doy,lasp.qaflag*1100,'+r',overplot=1,name='QA Flag (= 0 or 1, mult. by 1100)')
;  p4.sym_size = 0.4
;  p3.xrange=[0,1000]
;  p5 = plot(nrl_doy,lasp.qaflag,'-k',overplot=1,name='QA Flag (0 or 1)')
;  l3 = legend(target=[p3,p4],/data)
  
  
  stop
end


