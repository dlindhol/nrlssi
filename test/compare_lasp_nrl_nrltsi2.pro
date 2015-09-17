pro compare_lasp_nrl_nrltsi2

time_bin = 'yearly'

if time_bin eq 'daily' then begin 
  nrl_tsi = '/Users/hofmann/Downloads/NRLTSI2_1882_2014d_6Apr15.txt'
endif
if time_bin eq 'monthly' then begin
  nrl_tsi = '/Users/hofmann/Downloads/NRLTSI2_1882_2014m_6Apr15.txt'
endif
if time_bin eq 'yearly' then begin
  ;nrl_tsi = '/Users/hofmann/Downloads/NRLTSI2_1882_2014a_6Apr15.txt' 
  nrl_tsi = '/Users/hofmann/Downloads/NRLTSI2_1610_2014a_18May15.txt'
endif
 
;template to read NRL ascii file of daily TSI
  tempd = {version:1.0, $
    datastart:4L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[3l, 3l, 3l, 4l,4l], $ ; float
    fieldnames:['year', 'month', 'day', 'tsi','tsiunc'], $
    fieldlocations:[2L, 11L, 17L, 22L, 38L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]}

;template to read NRL ascii file of monthly TSI
  tempm = {version:1.0, $
    datastart:4L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:4l, $
    fieldtypes:[3l, 3l, 4l,4l], $ ; float
    fieldnames:['year', 'month', 'tsi','tsiunc'], $
    fieldlocations:[2L, 11L, 16L, 32L], $
    fieldgroups:[0L, 1L, 2L, 3L]}

;template to read NRL ascii file of yearly TSI (goes with the '/Users/hofmann/Downloads/NRLTSI2_1882_2014a_6Apr15.txt' file)
;  tempa = {version:1.0, $
;    datastart:4L, $
;    delimiter:32b, $
;    missingvalue:!VALUES.F_NAN, $
;    commentsymbol:'', $
;    fieldcount:3l, $
;    fieldtypes:[3l, 4l,4l], $ ; float
;    fieldnames:['year','tsi','tsiunc'], $
;    fieldlocations:[2L, 10L, 26L], $
;    fieldgroups:[0L, 1L, 2L]}

  ;template to read NRL ascii file of yearly TSI (goes with the '/Users/hofmann/Downloads/NRLTSI2_1610_2014a_18May15.txt' file)
  tempa = {version:1.0, $
    datastart:5L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:2l, $
    fieldtypes:[3l, 4l], $ ; float
    fieldnames:['year','tsi'], $
    fieldlocations:[2L, 10L], $
    fieldgroups:[0L, 1L]}
    

if time_bin eq 'daily' then jud = read_ascii(nrl_tsi, template = tempd) ;structure that holds the contents of nrl_output  
if time_bin eq 'monthly' then jud = read_ascii(nrl_tsi, template = tempm) ;structure that holds the contents of nrl_output 
if time_bin eq 'yearly' then jud = read_ascii(nrl_tsi, template = tempa) ;structure that holds the contents of nrl_output 

;truncate judith data to same time period
judtsi = jud.tsi
;judtsiunc=jud.tsiunc

;create LASP TSI data from saved annual, monthly and daily inputs
;restore,'test/LASP_annual_month_day_indices_1882_2014.sav',/verb
restore,'test/LASP_annual_indices_1610_2014.sav',/verb ; goes with 'NRLTSI2_1610_2014a_18May15.txt' above for nrl_tsi
if time_bin eq 'daily' then begin
  sb = sb_d
  mg = mg_d
  lasp_date=jd2yf4(mjd2jd(times_d))
endif
if time_bin eq 'monthly' then begin
  sb = sb_m
  mg = mg_m
  lasp_date=jd2yf4(mjd2jd(times_m))
endif

if time_bin eq 'yearly' then begin
  sb = sb_a
  mg = mg_a
  lasp_date=jd2yf4(mjd2jd(times_a))
endif

;Restore model parameters
model_params = get_model_params()
nrl2_tsi = compute_tsi(sb ,mg ,model_params) ;calculate TSI for given sb and mg
lasptsi=nrl2_tsi.totirrad
lasptsiunc=nrl2_tsi.totirradunc

;PLOT
p=plot(lasp_date,(1-(judtsi/lasptsi))*100,layout=[1,2,1])
p.title='Percent Difference in TSI'
p.ytitle='(1-NRL/LASP)*100'
p.xtitle='Year'
p1=plot(lasp_date,(1-(judtsiunc/lasptsiunc))*100,'r',layout=[1,2,2],/current)
p1.ytitle='(1-NRL/LASP)*100'
p1.title='Percent Difference in TSI Uncertainty'
p.xrange=[1610,2015]
p1.xrange=[1610,2015]


end ; pro