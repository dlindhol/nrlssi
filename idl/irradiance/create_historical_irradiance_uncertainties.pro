pro create_historical_irradiance_uncertainties,ymd1,ymd2,cycle=cycle
;determine uncertainties (cycle + background) for historical (1610-1882) time period

;Steps:


;1. compute annual TSI values using spot and facular values *for cycle only* for 1882-2014
; Cycle data has same spot values but differing fac values, 
; because the estimate of ACCUMULATED TOTAL flux background component has been remove. 
; The total flux is mainly closed flux, and is accumulating because of increasing solar cycle amplitude since 1610. 
; The open flux extends into the heliosphere and does not produce spots and faculae, so doesn't impact irradiance 
; (but it does affect the cosmogenic isotopes, which we don't use for the background determination).
cycle = process_irradiance('1882-01-01', '2014-12-31', final=final, time_bin='year',/cycle) ;right way

;2. Compute linear regression fit of TSI and TSI uncertainty in hist_irrad (i.e. cycle only data).
fit=linfit(cycle.data.tsi,cycle.data.tsiunc,chisq=chisq,covar=covar,prob=prob,sigma=sigma,yfit=yfit)
p=plot(cycle.data.tsi,cycle.data.tsiunc,'ok')
p1=plot(cycle.data.tsi,yfit,'-r',overplot=1)


;3. Determine uncertainty in TSI for cycle only in 1610-1882 using results of linear regression fit.
cycle_hist = get_historical_tsi('1610-01-01','1881-12-31',/cycle) ;Doug is working on fixing time bound ranges: for now this provides through 1881
cycle_hist = cycle_hist.toArray()
cycle_unc = fit[0] + cycle_hist.irradiance*fit[1]

;4. Extract accumulated total flux background component over 1610-1882 
; from differencing the TSI in the background + cycle data from Judith (on MEGA) and the "cycle only" data from Judith
cycle_and_background = get_historical_tsi('1610-01-01', '1881-12-31') ;judith cycle + background data (served by LaTiS) (PLUS, see note above re tme bound ranges)
cycle_and_background=cycle_and_background.toArray()
background = cycle_hist.irradiance - cycle_and_background.irradiance

;5. Assume uncertainty in background is equal to the magnitude of the background for 1610-1881
background_unc = background

;6. Total uncertainty for 1610-1882 equals the sum of the cycle uncertainty and the background uncertainty
total_unc = background_unc + cycle_unc

;make a plot
p1=plot(jd2yf4(iso2jd(cycle_hist.time)),background,'-r',name='Background Uncertainty',xtitle='Time',ytitle='TSI Unc')
p2=plot(jd2yf4(iso2jd(cycle_hist.time)),cycle_unc,'-b',overplot=1,name='Cycle Uncertainty')
p3=plot(jd2yf4(iso2jd(cycle_hist.time)),total_unc,'-k',name='Total (background+cycle) Uncertainty',overplot=1)
l=legend(target=[p1,p2,p3],/data)
;p1.save,'historical_tsi_uncertainty.png'

;create historical params structure and
;store historical params to save file
struct = {hist_params,     $
  time: cycle_hist.time,   $
  tsiunc: total_unc,       $
  backgroundunc:  background_unc, $
  cycleunc:       cycle_unc, $
  cycle_fit:      fit $
  }

;save,filename='/Users/hofmann/git/nrlssi/data/NRL2_historical_cycle_parameters_v02r00.sav',struct,/verb

;
;;;compare my irradiance uncertainties with judith
;;
;;template 
;temp = {version:1.0, $
;  datastart:5L, $
;  delimiter:32b, $
;  missingvalue:!VALUES.F_NAN, $
;  commentsymbol:'', $
;  fieldcount:3l, $
;  fieldtypes:[3l, 4l, 4l], $ ; float
;  fieldnames:['field1', 'field2', 'field3'], $
;  fieldlocations:[2L, 10L, 25L], $
;  fieldgroups:[0L, 1L, 2L]}
;
;judith=read_ascii('data/NRLTSI2_1610_2014a_22Jun15.txt')
;p4=plot(judith.field1[0,5:278],judith.field1[2,5:278],'ok',name='Judith: Total (background+cycle) Uncertainty',overplot=1)
;
;p5 = plot(judith.field1[0,5:278],(1-judith.field1[2,5:278]/total_unc)*100,ytitle='(1-NRL/LASP)*100',xtitle='Time',title='Percent difference in total (background+cycle) Uncertainty')
;



end