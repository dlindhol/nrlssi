pro poster

final=get_final_model_inputs('data/spotAIndC_fac_1882_2014_21Nov14.txt')
;convert year, month, day, to yymmdd
yy = strtrim(string(final.year),2)
mm=strtrim(string(final.month),2)
dd=strtrim(string(final.day),2)
yymmdd = strarr(n_elements(yy))
for i=0,n_elements(yy) -1 do begin
  if float(mm[i]) lt 10 then mm[i] = '0'+mm[i]
  if float(dd[i]) lt 10 then dd[i] = '0'+dd[i]
  yymmdd[i] = yy[i]+'-'+mm[i]+'-'+dd[i]
endfor

time=jd2yf4(mjd2jd(iso_date2mjdn(yymmdd)))

;determine delta irradiance changes (TSI)
modver='21Nov14'
fn='~/git/nrlssi/data/judith_2014_11_21/NRL2_model_parameters_AIndC_20_'+modver+'.sav'
model_params = get_model_params(fn)
spectral_bins = get_spectral_bins() 

nrl2_tsi = compute_tsi(final.spot , final.fac ,model_params) ;calculate TSI for given sb and mg
;make TSI and TSI related plots  
p1=plot(time,nrl2_tsi.totirrad,color='lime',title='Total Solar Irradiance',ytitle='W m-2',xtitle='Year',xrange=[1880,2020])
p2=plot(time,nrl2_tsi.totfac,color='magenta',title='Facular and Sunspot Component',name='faculae',ytitle='W m-2',xtitle='Year',xrange=[1880,2020])
p3=plot(time,nrl2_tsi.totspot,color='blue',name='sunspots',overplot=1)
l=legend(target=[p2,p3],/data)

goto, readin
;Make list to accumulate spectral results
data_list = List()
;Iterate over days.
n=n_elements(time)
for i = 43100, n-1 do begin ;only from 2000-01-01 to now
 
 sb= final.spot[i]
 mg = final.fac[i]   
 
 ssi = compute_ssi(sb, mg, model_params) ;calculate SSI for given sb and mg (1 nm bands)
 nrl2_ssi = bin_ssi(model_params, spectral_bins, ssi) ; SSI on the binned wavelength grid
 
 struct = {nrl2,                $
      ssi:    nrl2_ssi.nrl2bin,    $
      ssitot: nrl2_ssi.nrl2binsum  $
    }
 data_list.add, struct
endfor

;Convert data List to array
data = data_list.toArray() 


;Bin ssi into broad spectral bins
wav1a = 200 & wav1b = 210
wav2a = 300 & wav2b = 400
wav3a = 700 & wav3b = 1000
wav4a = 1000 & wav4b = 1300
k = n-43100

bin_ssi_1 = dblarr(k) ;200-210 nm
bin_ssi_2 = dblarr(k) ;300-400 nm
bin_ssi_3 = dblarr(k) ;700-1000 nm
bin_ssi_4 = dblarr(k) ;1000-1300 nm

bin_1 =where((spectral_bins.bandcenter ge wav1a) and (spectral_bins.bandcenter lt wav1b),cntwav)
bin_2 = where((spectral_bins.bandcenter ge wav2a) and (spectral_bins.bandcenter lt wav2b),cntwav)
bin_3 = where((spectral_bins.bandcenter ge wav3a) and (spectral_bins.bandcenter lt wav3b),cntwav)
bin_4 = where((spectral_bins.bandcenter ge wav4a) and (spectral_bins.bandcenter lt wav4b),cntwav)

for j=0,k-1 do begin
 bin_ssi_1[i] = total(data[i].ssi(bin_1)*spectral_bins.bandwidth(bin_1),/double)
 bin_ssi_2[i] = total(data[i].ssi(bin_2)*spectral_bins.bandwidth(bin_2),/double)
 bin_ssi_3[i] = total(data[i].ssi(bin_3)*spectral_bins.bandwidth(bin_3),/double)
 bin_ssi_4[i] = total(data[i].ssi(bin_4)*spectral_bins.bandwidth(bin_4),/double)
endfor

readin:
wav1a = 200 & wav1b = 210
wav2a = 300 & wav2b = 400
wav3a = 700 & wav3b = 1000
wav4a = 1000 & wav4b = 1300

restore,'/Users/hofmann/Desktop/ssi_binned_odele.sav',/verb
;make ssi related plots
subtime = time[43100:*]
p1 = plot(subtime,bin_ssi_1,title='200 - 210 nm',color='deep pink',layout=[1,4,1],margin = [0.15, 0.3, 0.1, 0.15],font_size=11)
p2 = plot(subtime,bin_ssi_2,title='300 - 400 nm', color='deep pink',layout=[1,4,2],/current,margin = [0.15, 0.3, 0.1, 0.15],font_size=11)
p3 = plot(subtime,bin_ssi_3,title='700 - 1000 nm', color='deep pink',layout=[1,4,3],/current,margin = [0.15, 0.3, 0.1, 0.15],font_size=11)
p4 = plot(subtime,bin_ssi_4,title='1000 - 1300 nm', color='deep pink',layout=[1,4,4],xtitle='Year',/current,margin = [0.15, 0.3, 0.1, 0.15],font_size=11)

;I made a save file ssi_binned_odele.sav
;can restore it, and compare to SORCE SIM V13/21 data.
sim='/Users/hofmann/Downloads/sorce_ssi_L3_c24h_0000nm_2413nm_20030301_20130729.txt'
simm=read_lasp_ascii_file(sim)

;define subset range from 2003.7 to 2004.2 (2003-09-12 to 2004-03-13)
t1 = mjd2jd(iso_date2mjdn('2003-09-12'))
t2 = mjd2jd(iso_date2mjdn('2004-03-13'))
trange=t2-t1+1
sorcedata1 = dblarr(trange) ;200-210 nm
sorcedata2 = dblarr(trange) ;300-400 nm
sorcedata3 = dblarr(trange) ;700-1000 nm
sorcedata4 = dblarr(trange) ;1000-1300 nm

xt = t1-0.5
for j=0,trange-1 do begin
  
   tmp = where(simm.nominal_date_jdn eq xt and simm.min_wavelength ge wav1a and simm.max_wavelength le wav1b,ntmp)
   if ntmp gt 0 then sorcedata1[j] = int_tabulated(simm[tmp].min_wavelength,simm[tmp].irradiance) else $
    sorcedata1[j] = !values.f_NAN
   tmp = where(simm.nominal_date_jdn eq xt and simm.min_wavelength ge wav2a and simm.max_wavelength le wav2b,ntmp)
   if ntmp gt 0 then sorcedata2[j] = int_tabulated(simm[tmp].min_wavelength,simm[tmp].irradiance) else $
    sorcedata2[j] = !values.f_NAN
   tmp = where(simm.nominal_date_jdn eq xt and simm.min_wavelength ge wav3a and simm.max_wavelength le wav3b,ntmp)
   if ntmp gt 0 then sorcedata3[j] = int_tabulated(simm[tmp].min_wavelength,simm[tmp].irradiance) else $
    sorcedata3[j] = !values.f_NAN
   tmp = where(simm.nominal_date_jdn eq xt and simm.min_wavelength ge wav4a and simm.max_wavelength le wav4b,ntmp)
   if ntmp gt 0 then sorcedata4[j] = int_tabulated(simm[tmp].min_wavelength,simm[tmp].irradiance) else $
    sorcedata4[j] = !values.f_NAN
   xt = xt +1
endfor

;make ssi related plots
time2=mjd2jd(iso_date2mjdn(yymmdd))

subtime1 = where(time2 eq t1)
subtime2 = where(time2 eq t2)

p1 = plot(time[subtime1:subtime2],bin_ssi_1[1348:1531],title='200 - 210 nm',color='deep pink',layout=[1,3,1],margin = [0.15, 0.3, 0.1, 0.15],font_size=11,/xstyle)
p1b=plot(time[subtime1:subtime2],sorcedata1*bin_ssi_1[1348]/sorcedata1[0],color='lime',/overplot)
;p2 = plot(time[subtime1:subtime2],bin_ssi_2[1348:1531],title='300 - 400 nm', color='deep pink',layout=[1,4,2],/current,margin = [0.15, 0.3, 0.1, 0.15],font_size=11)
;p2b=plot(time[subtime1:subtime2],sorcedata2*bin_ssi_2[1348]/sorcedata2[0],color='lime',/overplot)
p3 = plot(time[subtime1:subtime2],bin_ssi_3[1348:1531],title='700 - 1000 nm', color='deep pink',layout=[1,3,2],/current,margin = [0.15, 0.3, 0.1, 0.15],font_size=11)
p3b=plot(time[subtime1:subtime2],sorcedata3*bin_ssi_3[1348]/sorcedata3[0],color='lime',/overplot)
p4 = plot(time[subtime1:subtime2],bin_ssi_4[1348:1531],title='1000 - 1300 nm', color='deep pink',layout=[1,3,3],xtitle='Year',/current,margin = [0.15, 0.3, 0.1, 0.15],font_size=11)
p4b=plot(time[subtime1:subtime2],sorcedata4*bin_ssi_4[1348]/sorcedata4[0],color='lime',/overplot)

end; pro
