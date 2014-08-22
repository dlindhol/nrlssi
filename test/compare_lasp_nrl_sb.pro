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
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:6l, $
    fieldtypes:[3l, 7l, 7l, 7l, 7l,3l], $ ; float
    fieldnames:['YMD', 'SB', 'DSSBT', $
    'SSBUV','DSSBUV','FLAG'], $
    fieldlocations:[0L, 17L, 27L, 37L, 47L,53L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L]}
    
  lasp = read_ascii(lasp_sb_output,template = temp2) ; structure that hold the contest of lasp_sb_output
  
  ;truncate nrl data at 08/22/2014 to time and sunspot blocking arrays to be same size for comparison.
  np = n_elements(lasp.sb)
  nrl_year =nrl.year[0:np-1]
  nrl_month = nrl.month[0:np-1]
  nrl_day = nrl.day[0:np-1]
  nrl_doy = nrl.doy[0:np-1]
  nrl_tsi2 = nrl.tsi2[0:np-1]
  nrl_mg = nrl.mg[0:np-1]
  nrl_sb = nrl.sb[0:np-1]
  
  lasp_sb = lasp.sb
  
  ;make plots
  p1 = plot(nrl_doy,lasp_sb,'-k',xtitle='Days Since 01/01/1978',ytitle='Sunspot Blocking Index',name='LASP')
  p2 = plot(nrl.doy,nrl.sb,'or',overplot=1,name='NRL')
  p3 = plot(nrl.doy,lasp.sb-nrl.sb,'-k')
  stop
end


