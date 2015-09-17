pro compare_lasp_nrl_reference
nrl_reference='data/judith_2015_01_28/NRLSSI2_Reference_Spectra_CDR_11Feb15.txt' ;nrl reference spectra

  ;template to read NRL ascii file of reference spectra
  temp = {version:1.0, $
    datastart:4L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[4l, 5l, 5l, 5l,5l], $ ; float
    fieldnames:['field1', 'field2', 'field3', 'field4','field5'], $
    fieldlocations:[3L, 14L, 30L, 46L, 62L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]}
 
  nrl = read_ascii(nrl_reference, template = temp) ;structure that holds the contents of nrl_output  
  nrl_lambda = nrl.field1
  nrl_high = nrl.field2
  nrl_moderate = nrl.field3
  nrl_low = nrl.field4
  nrl_quiet = nrl.field5
  
  algver = 'v02' ; get from function parameter?
  algrev = 'r00' ; for 'final' files;  get from function parameter?
  modver='28Jan15'
  fn='~/git/nrlssi/data/judith_2015_01_28/NRL2_model_parameters_AIndC_21_'+modver+'.sav'
  model_params = get_model_params(file=fn)
 
  ;these sb and mg values are monthly averages for Sept, 2001 (high), May 2004 (moderate), and July 2008 (low)
  lasp_high = compute_ssi(3162.5460,0.16737667,model_params) 
  lasp_high2 = compute_ssi(3162.5464,0.16737668,model_params) ;Judith's exact input values (note she averaged 31 days)
  lasp_high_tsi = compute_tsi(3162.5460,0.16737667,model_params)
  lasp_high_tsi2 = compute_tsi(3162.5464,0.16737668,model_params) 
  lasp_moderate = compute_ssi(671.66613,0.15545161,model_params)
  lasp_moderate2 = compute_ssi(671.66608,0.15545161,model_params) ;Judith's exact indice values
  lasp_moderate_tsi = compute_tsi(671.66613,0.15545161,model_params)
  lasp_moderate_tsi2 = compute_tsi(671.66608,0.15545161,model_params)
  lasp_low = compute_ssi(2.6735484,0.15061290,model_params)
  lasp_low2 = compute_ssi(2.6735482,0.15061291,model_params); Judith's exact indice values
  lasp_low_tsi = compute_tsi(2.6735484,0.15061290,model_params)
  lasp_low_tsi2 = compute_tsi(2.6735482,0.15061291,model_params)
  lasp_quiet = model_params.iquiet
  
  p=plot(model_params.lambda,(1.0-nrl_high/lasp_high.nrl2)*100,'k',name='High',xlog=1)
  p1=plot(model_params.lambda,(1-nrl_moderate/lasp_moderate.nrl2)*100,'r',overplot=1,name='Moderate')
  p2=plot(model_params.lambda,(1-nrl_low/lasp_low.nrl2)*100,'b',overplot=1,name='Low')
  p3=plot(model_params.lambda,(1-nrl_quiet/model_params.iquiet)*100,'g',overplot=1,name='Quiet')
  p.ytitle='(1 - NRL/LASP) * 100'
  p.xtitle='Wavelength'
  l=legend(target=[p,p1,p2,p3],/data)
  
  p=plot(model_params.lambda,(1.0-nrl_high/lasp_high2.nrl2)*100,'k',name='High',xlog=1)
  p1=plot(model_params.lambda,(1-nrl_moderate/lasp_moderate2.nrl2)*100,'r',overplot=1,name='Moderate')
  p2=plot(model_params.lambda,(1-nrl_low/lasp_low2.nrl2)*100,'b',overplot=1,name='Low')
  p3=plot(model_params.lambda,(1-nrl_quiet/model_params.iquiet)*100,'g',overplot=1,name='Quiet')
  p.ytitle='(1 - NRL/LASP) * 100'
  p.xtitle='Wavelength'
  l=legend(target=[p,p1,p2,p3],/data)
  p.xrange=[0,1000]
  
end