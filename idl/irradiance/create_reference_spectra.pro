function create_reference_spectra,version=version, output_dir=output_dir

  if n_elements(version) eq 0 then version = 'v02r00'  ;default to current final release version
  creation_date = jd2iso_date(systime(/julian, /utc)) ;now as yyyy-mm-dd UTC
  cymd = remove_hyphens(creation_date)
  outfile = output_dir+'NRLSSI2_'+version+'_reference_spectra_c'+cymd+'.txt'
  
  ;Default to monthly averages
  time_bin = 'month'
  
  ;Get the NRL2 model parameters (includes quiet spectrum)
  model_params = get_model_params()
  lambda = model_params.lambda ;1 nm wavelength bins

  ;Quiet
  quiet = model_params.iquiet  ;quiet spectrum

  ;Low : defined as July 2008 (month avg)
  ymd1='2008-07-01'
  ymd2='2008-07-31'
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, /final) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, /final) ;MgII index data - facular brightening
  sb = sunspot_blocking.toArray() & sb = mean(sb.ssbt)
  mg = mg_index.toArray() & mg = mean(mg.index)
  low = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
  lowssi = low.nrl2 & lowssitot = low.nrl2tot

  ;Moderate: defined as May 2004 (month avg)
  ymd1 = '2004-05-01'
  ymd2 = '2004-05-31'
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, /final) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, /final) ;MgII index data - facular brightening
  sb = sunspot_blocking.toArray() & sb = mean(sb.ssbt)
  mg = mg_index.toArray() & mg = mean(mg.index)
  moderate = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
  moderatessi = moderate.nrl2 & moderatessitot = moderate.nrl2tot
    
  ;High: defined as Sept 2001 (month avg)
  ymd1 = '2001-09-01'
  ymd2 = '2001-09-30'
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, /final) ;sunspot blocking/darkening data
  mg_index = get_mg_index(ymd1, ymd2, /final) ;MgII index data - facular brightening
  sb = sunspot_blocking.toArray() & sb = mean(sb.ssbt)
  mg = mg_index.toArray() & mg = mean(mg.index)
  high = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)  
  highssi = high.nrl2 & highssitot = high.nrl2tot
    
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
  
  
  ;write to output file
  openw,1,outfile
  printf,1,'NRLSSI2 Reference Spectra in W per m^2 per nm'
  printf,1,'WAV (nm)     Sept 2001     May 2004      July 2008     Maunder Minimum    QUIET'

  printf,1,FORMAT = '(A6,5(5X,F10.4))','TSI',highssitot,moderatessitot,lowssitot, total(maunder_minimum,/double),total(quiet,/double)
  
  for i=0,n_elements(model_params.lambda)-1 do begin
    printf,1,FORMAT = '(F7.1,5(5X,e10.4E2))',lambda[i], highssi[i],moderatessi[i],lowssi[i],maunder_minimum[i],quiet[i]
  endfor  
  close,1
  
  
  end