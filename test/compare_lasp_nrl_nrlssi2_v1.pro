pro compare_lasp_nrl_nrlssi2_v1

jud = read_nrl_nrlssi2() ;read Judith's MEGA files, 1978-2014
;goto, float

;------compute LASP NRLSSI2 for time series
modver='28Jan15'
fn='~/git/nrlssi/data/judith_2015_01_28/NRL2_model_parameters_AIndC_21_'+modver+'.sav'
ymd1 = '2000-01-01'
ymd2 = '2000-12-31'
;Convert start and stop dates to Modified Julian Day Number (integer).
mjd_start = iso_date2mjdn(ymd1)
mjd_stop  = iso_date2mjdn(ymd2)  
;Number of time samples (days)
n = mjd_stop - mjd_start + 1
;Restore model parameters
model_params = get_model_params(fn)
;Set up wavelength bands for summing 1 nm spectrum
spectral_bins = get_spectral_bins() 
;Get input data
sunspot_blocking = get_sunspot_blocking(ymd1, ymd2, final=final) ;sunspot blocking/darkening data
mg_index = get_mg_index(ymd1, ymd2, final=final) ;Mg
;Create a Hash for each input dataset mapping MJD (assumed to be integer, i.e. midnight) to the appropriate record.
;Note, Hash values will be arrays but should have only one element: the data record for that day.
sunspot_blocking_by_day = group_by_tag(sunspot_blocking, 'MJDN')
mg_index_by_day = group_by_tag(mg_index, 'MJD')
;Make list to accumulate results
data_list = List()
;Iterate over days.
;TODO: consider passing complete arrays of data to these routines
  for i = 0, n-1 do begin
    mjd = mjd_start + i
    
    ;sb = sunspot_blocking[i].ssbt
    ;mg = mg_index[i].index
    sb = sunspot_blocking_by_day[mjd].ssbt
    sb = float(sb)
    mg = mg_index_by_day[mjd].index
    mg = float(mg)
    
    ;sanity check that we have one record per day
    if ((n_elements(sb) ne 1) or (n_elements(mg) ne 1)) then begin
      print, 'WARNING: Invalid input data for day ' + mjd2iso_date(mjd)
      continue  ;skip this day
    endif
    
    nrl2_tsi = compute_tsi(sb ,mg ,model_params) ;calculate TSI for given sb and mg
    ssi = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
    nrl2_ssi = bin_ssi(model_params, spectral_bins, ssi) ; SSI on the binned wavelength grid
    
    iso_time = mjd2iso_date(mjd)
    
    ; TODO Add bandcenters and bandwidths and nband to data structure
    struct = {nrl2,                 $
      mjd:    mjd,                  $
      iso:    iso_time,             $
      tsi:    nrl2_tsi.totirrad,    $
      tsiunc: nrl2_tsi.totirradunc, $
      ssi:    nrl2_ssi.nrl2bin,     $
      ssiunc: nrl2_ssi.nrl2binunc,  $
      ssitot: nrl2_ssi.nrl2binsum   $
    }
    
    data_list.add, struct
  endfor
;Convert data List to array
lasp = data_list.toArray()
;-------------end getting lasp data

;truncate judith data to same time period
;2000-01-01 through 2000-12-31 = jud[8035:8400]
j1 = 8035
j2 = 8400
tt=jd2yf4(mjd2jd(lasp.mjd))

sub = jud.tsi[j1:j2]
p=plot(tt,sub,layout = [1,2,1],name='NRL')
p1=plot(tt,lasp.tsi,'r',overplot=1,name='LASP')
l=legend(target=[p,p1],/data)
p.title='TSI Comparison'
p.ytitle='W m!U-2'
p=plot(tt,(1-(sub/lasp.tsi))*100,layout=[1,2,2],/current)
p.title='TSI Percent Difference'
p.ytitle='(1-NRL/LASP)*100'
p.xtitle='Year'

iband=400
sub = reform(jud.spec[iband,j1:j2])
p=plot(tt,sub,layout = [1,2,1],name='NRL')
p1=plot(tt,lasp.ssi[iband,*],'r',overplot=1,name='LASP')
l=legend(target=[p,p1],/data)
p.title='SSI Comparison: '+strtrim(spectral_bins.bandcenter[iband],2)+' nm'
p.ytitle='W m!U-2!N nm!U-1'
p=plot(tt,(1-(sub/lasp.ssi[iband,*]))*100,layout=[1,2,2],/current)
p.title='SSI Percent Difference: '+strtrim(spectral_bins.bandcenter[iband],2)+' nm'
p.ytitle='(1-NRL/LASP)*100'
p.xtitle='Year'

FLOAT:
;re do comparison against LASP .NC output (which is float precision)
ncdf_file = 'tsi_v02r00_daily_s2000-01-01_e2000-12-31_c2015-02-13.nc'
filename=ncdf_file
cdfid = ncdf_open(filename,/nowrite) ;open for read only
ivaridt = ncdf_varid(cdfid,'TSI')
ncdf_varget,cdfid,ivaridt,lasp_tsi ;read the data from the variables
ivaridt = ncdf_varid(cdfid,'time')
ncdf_varget,cdfid,ivaridt,lasp_time

ncdf_file = 'ssi_v02r00_daily_s2000-01-01_e2000-12-31_c2015-02-13.nc'
filename=ncdf_file
cdfid = ncdf_open(filename,/nowrite) ;open for read only
ivaridt = ncdf_varid(cdfid,'SSI')
ncdf_varget,cdfid,ivaridt,lasp_ssi ;read the data from the variables


sub = jud.tsi[j1:j2]
p=plot(tt,sub,layout = [1,2,1],name='NRL')
p1=plot(tt,lasp_tsi,'r',overplot=1,name='LASP')
l=legend(target=[p,p1],/data)
p.title='TSI Comparison'
p.ytitle='W m!U-2'
p=plot(tt,(1-(sub/lasp_tsi))*100,layout=[1,2,2],/current)
p.yrange=[-.0001,0.0001]
p.title='TSI Percent Difference'
p.ytitle='(1-NRL/LASP)*100'
p.xtitle='Year'

sub = reform(jud.spec[iband,j1:j2])
p=plot(tt,sub,layout = [1,2,1],name='NRL')
p1=plot(tt,lasp_ssi[iband,*],'r',overplot=1,name='LASP')
l=legend(target=[p,p1],/data)
p.title='SSI Comparison: '+strtrim(spectral_bins.bandcenter[iband],2)+' nm'
p.ytitle='W m!U-2!N nm!U-1'
p=plot(tt,(1-(sub/lasp_ssi[iband,*]))*100,layout=[1,2,2],/current)
p.title='SSI Percent Difference: '+strtrim(spectral_bins.bandcenter[iband],2)+' nm'
p.ytitle='(1-NRL/LASP)*100'
p.xtitle='Year'



end; pro