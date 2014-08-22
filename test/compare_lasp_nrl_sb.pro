pro compare_lasp_nrl_sb

  nrl_output = 'data/judith_2014_08_21/NRLTSI2_1978_2014d_18Aug14.txt' ;Judith's file - we will validate against this

  ;template to read NRL ascii file of TSI, facular brightening and sunspot darkening functions from file
  temp = {version:1.0, $
    datastart:1L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:7l, $
    fieldtypes:[3l, 3l, 3l, 3l, 4l,4l, 4l], $ ; float
    fieldnames:['YEAR', 'MONTH', 'DAY', $
    'DOY','TSI2','MG','SB'], $
    fieldlocations:[1L, 10L, 16L, 26L, 36L,49L,62L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L, 6L]}
    
  nrl = read_ascii(nrl_output, template = temp) ;structure that holds the contents of nrl_output
  ;Replace missing values with NaN (makes plotting easier)
  nrl.SB = replace_missing_with_nan(nrl.SB, -999.0)
  nrl.MG = replace_missing_with_nan(nrl.MG, -99.0)


  lasp_sb_output = '~/data/sunspot_blocking_1978-01-01_2014-08-22_v0.3.txt' ;LASP file - output from process_sunspot_blocking.pro
    ;template to read NRL ascii file of TSI, facular brightening and sunspot darkening functions from file
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
    
  lasp = read_ascii(lasp_sb_output,template = temp2) ; structure that hold the contest of lasp_sb_output
  
  ;truncate nrl data at 08/22/2014 to time and sunspot blocking arrays to be same size for comparison.
  np = n_elements(lasp.ssbt)
  nrl_year =nrl.year[0:np-1]
  nrl_month = nrl.month[0:np-1]
  nrl_day = nrl.day[0:np-1]
  nrl_doy = nrl.doy[0:np-1]
  nrl_tsi2 = nrl.tsi2[0:np-1]
  nrl_mg = nrl.mg[0:np-1]
  nrl_sb = nrl.sb[0:np-1]
  
  lasp_sb = lasp.ssbt
  
  
  ;make plots
  goto, subset
  
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
      name='LASP divided by NRL',/ylog,margin=[0.2,0.2,0.05,0.1],LAYOUT=[1,2,2],current=1,title='LASP divided by NRL')
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


