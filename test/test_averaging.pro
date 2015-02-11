pro test_averaging
;compare the irradiance of averaged inputs to the average irradiance
;time period Jan 1, 2014 to Jan 31, 2014

ymd1 = '2014-01-01'
ymd2 = '2014-01-31'
modver='28Jan15'
fn='~/git/nrlssi/data/judith_2015_01_28/NRL2_model_parameters_AIndC_21_'+modver+'.sav'
model_params = get_model_params(fn)
spectral_bins = get_spectral_bins() 

;1 month of irradiance
result=nrl2_to_irradiance(ymd1,ymd2)
;time average of the irradiance
mean_tsi = mean(result.tsi)
tmp=result.ssi
mean_ssi = dblarr(3785) ; 3785 is number of wavelength bins
for i=0,3784 do begin
  mean_ssi[i] = mean(tmp[i,*])
endfor
mean_ssitot = mean(result.ssitot)
 
;average of 1 month of inputs
sunspot_blocking = get_sunspot_blocking(ymd1, ymd2) ;sunspot blocking data
sunspot_blockinga = sunspot_blocking.toArray()
mg_index = get_mg_index(ymd1, ymd2) 
mg_indexa = mg_index.toArray()
mean_sb = mean(sunspot_blockinga.ssbt)
mean_mg = mean(mg_indexa.index)

;irradiance of averaged inputs
tsi1 = compute_tsi(mean_sb ,mean_mg ,model_params) ;calculate TSI for given sb and mg
ssi1 = compute_ssi(mean_sb, mean_mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
ssi1_bin = bin_ssi(model_params, spectral_bins, ssi1) 
  
;print difference in tsi values and ssitot values
print,mean_tsi - tsi1.totirrad
print,mean_ssitot -ssi1_bin.nrl2binsum

;plot difference in ssi spectrum
p=plot(spectral_bins.bandcenter, mean_ssi / ssi1_bin.nrl2bin,xtitle='Wavelength',title='Ratio: Averaged Irradiance to Irradiance of Averaged Input',xrange=[100,500],yrange=[.99999,1.00001])



stop    
end; 