function create_filenames,ymd1,ymd2,creation_date,algver,algrev, final=final, dev=dev,  $
  daily=daily,monthly=monthly, annual=annual

  ;Make output file name(s), dynamically
 
  cymd = remove_hyphens(creation_date) ;creation ymd
  
  if keyword_set(daily) then begin 
    symd = remove_hyphens(ymd1) ;starting ymd
    eymd = remove_hyphens(ymd2) ;ending ymd
    if keyword_set(final) then begin
      tsifile = 'tsi_' + algver +algrev +'_'+'daily_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
      ssifile = 'ssi_' + algver +algrev +'_'+'daily_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;     
    endif
    if keyword_set(dev) then begin
      tsifile = 'tsi_' + algver +algrev +'-preliminary_'+'daily_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
      ssifile = 'ssi_' + algver +algrev +'-preliminary_'+'daily_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
    endif
  endif
  
  if keyword_set(monthly) then begin
    symd = remove_hyphens(ymd1) & symd = strmid(symd,0,6);starting ym 
    eymd = remove_hyphens(ymd2) & eymd = strmid(eymd,0,6) ;ending ym
    if keyword_set(final) then begin
      tsifile = 'tsi_' + algver +algrev +'_'+'monthly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
      ssifile = 'ssi_' + algver +algrev +'_'+'monthly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;     
    endif
    if keyword_set(dev) then begin
      tsifile = 'tsi_' + algver +algrev +'-preliminary_'+'monthly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
      ssifile = 'ssi_' + algver +algrev +'-preliminary_'+'monthly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
    endif
  endif
  
  if keyword_set(annual) then begin
    symd = remove_hyphens(ymd1) & symd = strmid(symd,0,4);starting y 
    eymd = remove_hyphens(ymd2) & eymd = strmid(eymd,0,4) ;ending y
    if keyword_set(final) then begin
      tsifile = 'tsi_' + algver +algrev +'_'+'yearly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
      ssifile = 'ssi_' + algver +algrev +'_'+'yearly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;     
    endif
    if keyword_set(dev) then begin
      tsifile = 'tsi_' + algver +algrev +'-preliminary_'+'yearly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
      ssifile = 'ssi_' + algver +algrev +'-preliminary_'+'yearly_s'+symd +'_e'+ eymd +'_c'+ cymd +'.nc' ;
    endif
  endif
  
  tsifile_manifest = tsifile + '.mnf'
  ssifile_manifest = ssifile + '.mnf' 

  ;Create the resulting filenames structure.

    struct = {filenames,         $
      tsi:     tsifile,          $
      ssi:     ssifile,          $
      tsi_man: tsifile_manifest, $
      ssi_man: ssifile_manifest  $
    }
    
  return,struct
    
end ; pro  