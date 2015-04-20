pro compare_lasp_nrl_nrlssi2

time_bin = 'monthly' ;CHANGE

if time_bin eq 'daily' then begin 
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1882_1909d_6Apr15.txt'
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1910_1949d_6Apr15.txt'
  nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1950_1977d_6Apr15.txt'
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1978_2014d_6Apr15.txt'
  startyear=1950 ;CHANGE to match time frame in daily files
  endyear = 1977 ;CHANGE to match time frame in daily files
  jud = read_nrl_nrlssi2d(nrl_ssi,startyear,endyear) ;read Judith's MEGA files, 1978-2014
endif
if time_bin eq 'monthly' then begin
  ;nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1882_1959m_6Apr15.txt' 
  nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1960_2014m_6Apr15.txt'
  startyear=2014 ;CHANGE to match time frame in monthly files (ALSO NEED TO SUBSET DATA in lines 45-49)
  endyear = 2014 ;CHANGE to match time frame in monthly files (ALSO NEED TO SUBSET DATA in lines 45-49)
  jud = read_nrl_nrlssi2m(nrl_ssi,startyear,endyear) ;read Judith's MEGA files, 1978-2014
endif
if time_bin eq 'yearly' then begin
  nrl_ssi = '/Users/hofmann/Downloads/NRLSSI2_1882_2014a_6Apr15.txt' 
  startyear=1882 
  endyear = 2014 
  jud = read_nrl_nrlssi2a(nrl_ssi,startyear,endyear) ;read Judith's MEGA files, 1978-2014
endif

 
;judith data
judssi = jud.spec
judtsi = jud.tsi
judtotssi = jud.totspec
jwavelength=jud.wl[*,0]
jbandwidth=jud.wl[*,1]
k=n_elements(judssi[0,*]) ;elements in time series


;create LASP SSI data from saved annual, monthly and daily inputs
restore,'test/LASP_annual_month_day_indices_1882_2014.sav',/verb
if time_bin eq 'daily' then begin
  sbi = sb_d[24836:35062] ;(index 0:10225 spans 1882 through 1909-12-31), (index 24836:35062 spans 1950 through 1977-12-31)
  mgi = mg_d[24836:35062] 
  lasp_date=jd2yf4(mjd2jd(times_d[24836:35062]))
endif
if time_bin eq 'monthly' then begin
  sbi = sb_m[1584:*]
  mgi = mg_m[1584:*]
  lasp_date=jd2yf4(mjd2jd(times_m[1584:*])) ;index 936 = Jan, 1960; 1584 = Jan, 2014
endif

if time_bin eq 'yearly' then begin
  sbi = sb_a
  mgi = mg_a
  lasp_date=jd2yf4(mjd2jd(times_a))
endif

;Restore model parameters
model_params = get_model_params()
spectral_bins = get_spectral_bins() 

data_list = List()
;check to see if 'k' elements in judith's data matches the lasp data (subsetted to the same time frame).


;loop over days
for i = 0, k-1 do begin
    sb = sbi(i) 
    mg = mgi(i)
    
    nrl2_tsi = compute_tsi(sb ,mg ,model_params) ;calculate TSI for given sb and mg
    ssi = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
    nrl2_ssi = bin_ssi(model_params, spectral_bins, ssi) ; SSI on the binned wavelength grid
    
    ; TODO Add bandcenters and bandwidths and nband to data structure
    struct = {nrl2,               $
      tsi:    nrl2_tsi.totirrad,    $
      ssi:    nrl2_ssi.nrl2bin,     $
      ssitot: nrl2_ssi.nrl2binsum   $
    }
    
    data_list.add, struct
endfor
lasp = data_list.toArray()  
laspssi=lasp.ssi
lasptsi=lasp.tsi

;Bin SSI for comparisons
wav1a = 200 & wav1b = 210
wav2a = 300 & wav2b = 400
wav3a = 700 & wav3b = 1000
wav4a = 1000 & wav4b = 1300

;Judith binned results
jbin_ssi_1 = dblarr(k) ;200-210 nm
jbin_ssi_2 = dblarr(k) ;300-400 nm
jbin_ssi_3 = dblarr(k) ;700-1000 nm
jbin_ssi_4 = dblarr(k) ;1000-1300 nm

;LASP Binned results
lbin_ssi_1 = dblarr(k) ;200-210 nm  
lbin_ssi_2 = dblarr(k) ;300-400 nm
lbin_ssi_3 = dblarr(k) ;700-1000 nm
lbin_ssi_4 = dblarr(k) ;1000-1300 nm

bin_ssi_1_unc = dblarr(k)
bin_ssi_2_unc = dblarr(k)
bin_ssi_3_unc = dblarr(k)
bin_ssi_4_unc = dblarr(k)

bin_1 =where((jwavelength ge wav1a) and (jwavelength lt wav1b),cntwav)
bin_2 = where((jwavelength ge wav2a) and (jwavelength lt wav2b),cntwav)
bin_3 = where((jwavelength ge wav3a) and (jwavelength lt wav3b),cntwav)
bin_4 = where((jwavelength ge wav4a) and (jwavelength lt wav4b),cntwav)

for j=0, k-1 do begin
 jbin_ssi_1[j] = total(judssi[bin_1,j]*jbandwidth(bin_1),/double)
 jbin_ssi_2[j] = total(judssi[bin_2,j]*jbandwidth(bin_2),/double)
 jbin_ssi_3[j] = total(judssi[bin_3,j]*jbandwidth(bin_3),/double)
 jbin_ssi_4[j] = total(judssi[bin_4,j]*jbandwidth(bin_4),/double)

 lbin_ssi_1[j] = total(laspssi[bin_1,j]*jbandwidth(bin_1),/double)
 lbin_ssi_2[j] = total(laspssi[bin_2,j]*jbandwidth(bin_2),/double)
 lbin_ssi_3[j] = total(laspssi[bin_3,j]*jbandwidth(bin_3),/double)
 lbin_ssi_4[j] = total(laspssi[bin_4,j]*jbandwidth(bin_4),/double)
endfor

;PLOTS
p=plot(lasp_date[0:k-1],(1-(jbin_ssi_1/lbin_ssi_1))*100,layout=[1,4,1],title='Percent Difference in SSI: 200-210 nm',font_size=10)
p1=plot(lasp_date[0:k-1],(1-(jbin_ssi_2/lbin_ssi_2))*100,layout=[1,4,2],title='Percent Difference in SSI: 300-400 nm',/current,font_size=10)
p1=plot(lasp_date[0:k-1],(1-(jbin_ssi_3/lbin_ssi_3))*100,layout=[1,4,3],title='Percent Difference in SSI: 700-1000 nm',/current,font_size=10)
p1=plot(lasp_date[0:k-1],(1-(jbin_ssi_4/lbin_ssi_4))*100,layout=[1,4,4],title='Percent Difference in SSI: 1000-1300 nm',/current,font_size=10)

;Addendum - add comparison to new monthly/averaged data from .nc output
;open .nc file for NRLTSI2 and NRLSSI2 data from 1978-11-07 to 2014-12-31
cdfid = ncdf_open('ssi_v02r00_monthly_s201401_e201412_c20150420.nc',/nowrite)
ivaridt = ncdf_varid(cdfid,'SSI')
ncdf_varget,cdfid,ivaridt,dougssi
;ivaridt = ncdf_varid(cdfid,'SSI_UNC')
;ncdf_varget,cdfid,ivaridt,nrl_ssi_unc
ivaridt = ncdf_varid(cdfid,'time')
ncdf_varget,cdfid,ivaridt,dougdate
day_zero_mjd = iso_date2mjdn('1610-01-01')
dougdate = dougdate + day_zero_mjd
dougdate_jd = mjd2jd(dougdate)
dougdate = jd2yf4(mjd2jd(dougdate))
ivaridt=ncdf_varid(cdfid,'wavelength')
ncdf_varget,cdfid,ivaridt,wavelength
ivaridt=ncdf_varid(cdfid,'Wavelength_Bands')
ncdf_varget,cdfid,ivaridt,bandwidth
ivaridt=ncdf_varid(cdfid,'TSI')
ncdf_varget,cdfid,ivaridt,dougtsi
;ivaridt=ncdf_varid(cdfid,'TSI_UNC')
;ncdf_varget,cdfid,ivaridt,dougtsi_unc


;Doug binned results (using same bins)
dbin_ssi_1 = dblarr(k) ;200-210 nm
dbin_ssi_2 = dblarr(k) ;300-400 nm
dbin_ssi_3 = dblarr(k) ;700-1000 nm
dbin_ssi_4 = dblarr(k) ;1000-1300 nm

for j=0, k-1 do begin
 dbin_ssi_1[j] = total(dougssi[bin_1,j]*jbandwidth(bin_1),/double)
 dbin_ssi_2[j] = total(dougssi[bin_2,j]*jbandwidth(bin_2),/double)
 dbin_ssi_3[j] = total(dougssi[bin_3,j]*jbandwidth(bin_3),/double)
 dbin_ssi_4[j] = total(dougssi[bin_4,j]*jbandwidth(bin_4),/double)
endfor


;Compare Doug results (to be used to send final data to NCDC) to my version
p=plot(lasp_date[0:k-1],(1-(dbin_ssi_1/lbin_ssi_1))*100,layout=[1,4,1],title='Percent Difference in SSI: 200-210 nm',font_size=10)
p1=plot(lasp_date[0:k-1],(1-(dbin_ssi_2/lbin_ssi_2))*100,layout=[1,4,2],title='Percent Difference in SSI: 300-400 nm',/current,font_size=10)
p1=plot(lasp_date[0:k-1],(1-(dbin_ssi_3/lbin_ssi_3))*100,layout=[1,4,3],title='Percent Difference in SSI: 700-1000 nm',/current,font_size=10)
p1=plot(lasp_date[0:k-1],(1-(dbin_ssi_4/lbin_ssi_4))*100,layout=[1,4,4],title='Percent Difference in SSI: 1000-1300 nm',/current,font_size=10)

end ; pro