pro create_reference_spectra

  ;Get the NRL2 model parameters (includes quiet spectrum)
  model_params = get_model_params()
  lambda = model_params.lambda ;1 nm wavelength bins
  
  ;Quiet
  quiet = model_params.iquiet  ;quiet spectrum
  
  ;Low : defined as July 2008 (month avg)
  ymd1='2008-07-01'
  ymd2='2008-07-31'
  ;Get input data
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, /final) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, /final) ;MgII index data - facular brightening
  ssb = sunspot_blocking.toArray() & ssb = mean(ssb.ssbt)
  mgi = mg_index.toArray() & mgi = mean(mgi.index)
  print,'Low Solar Activity (July 2008): spot, fac: ', ssb, mgi
  ssi = compute_ssi(ssb, mgi, model_params) ;calculate SSI for given sb and mg (1 nm bands)
  low = ssi.nrl2
  
  ;Moderate: defined as May 2004 (month avg)
  ymd1='2004-05-01'
  ymd2='2004-05-31'
  ;Get input data
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, /final) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, /final) ;MgII index data - facular brightening
  ssb = sunspot_blocking.toArray() & ssb = mean(ssb.ssbt)
  mgi = mg_index.toArray() & mgi = mean(mgi.index)
  print,'Moderate Solar Activity (May 2004): spot, fac: ', ssb, mgi
  ssi = compute_ssi(ssb, mgi, model_params) ;calculate SSI for given sb and mg (1 nm bands)
  moderate = ssi.nrl2
  
  ;High: defined as Sept 2001 (month avg)
  ymd1='2001-09-01'
  ymd2='2001-09-30'
  ;Get input data
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, /final) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, /final) ;MgII index data - facular brightening
  ssb = sunspot_blocking.toArray() & ssb = mean(ssb.ssbt)
  mgi = mg_index.toArray() & mgi = mean(mgi.index)
  print,'High Solar Activity (Sept 2001): spot, fac: ', ssb, mgi
  ssi = compute_ssi(ssb, mgi, model_params) ;calculate SSI for given sb and mg (1 nm bands)
  high = ssi.nrl2  
  
  judssi = compute_ssi (3162.5464, 0.16737688,model_params)

  
  ;Maunder Minimum (need to get this from Judith's data file)
  mm_temp = {version:1.0, $
    datastart:5L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:2l, $
    fieldtypes:[4l,4l], $ ; float
    fieldnames:['FIELD1','FIELD2'], $
    fieldlocations:[7L, 19L], $
    fieldgroups:[0L, 1L]}

  mm = read_ascii('data/reference_spectra/NRLSSI2_1675a_18May15.txt', template = mm_temp) 
  maunder_minimum = mm.field2
  
  
  ;Compare low, moderate, and high against Judith's results:
  ;template to read NRL ascii file of reference spectra
  temp_jud = {version:1.0, $
    datastart:4L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[4l, 5l, 5l, 5l,5l], $ ; float
    fieldnames:['field1', 'field2', 'field3', 'field4','field5'], $
    fieldlocations:[3L, 14L, 30L, 46L, 62L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]}

  ;nrl = read_ascii('data/reference_spectra/NRLSSI2_Reference_Spectra_CDR_11Feb15.txt', template = temp_jud) ;structure that holds the contents of nrl_output
  nrl = read_ascii('~/Downloads/NRLSSI2_Reference_Spectra_CDR_11Feb15.txt', template = temp_jud) ;structure that holds the contents of nrl_output
  jlambda = nrl.field1
  jhigh = nrl.field2
  jmoderate = nrl.field3
  jlow = nrl.field4
  jquiet = nrl.field5
  
  ;Make Comparison Plots
  ;p=plot(lambda,(1.0-jhigh/high)*100,'k',name='High',xlog=1)
  p=plot(lambda,(1-jhigh/judssi.nrl2)*100,'k',name='High',xlog=1)
  p1=plot(lambda,(1-jmoderate/moderate)*100,'r',overplot=1,name='Moderate')
  p2=plot(lambda,(1-jlow/low)*100,'b',overplot=1,name='Low')
  p3=plot(lambda,(1-jquiet/quiet)*100,'g',overplot=1,name='Quiet')
  p.ytitle='(1 - NRL/LASP) * 100'
  p.xtitle='Wavelength'
  l=legend(target=[p,p1,p2,p3],/data)
  ;p.xrange=[0,1000]
  ;p.save,'data/reference_spectra/comparison_b.png'
  

  end