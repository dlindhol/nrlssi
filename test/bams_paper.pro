pro bams_paper

;make plots for bams paper

;goto, review

;open .nc file for NRLTSI2 and NRLSSI2 data from 1978-11-07 to 2014-12-31
cdfid = ncdf_open('/Users/hofmann/Documents/FCDR_Solar/ssi_v02r00_daily_s19781107_e20141231_c20150321.nc',/nowrite)
ivaridt = ncdf_varid(cdfid,'SSI')
ncdf_varget,cdfid,ivaridt,nrl_ssi
ivaridt = ncdf_varid(cdfid,'SSI_UNC')
ncdf_varget,cdfid,ivaridt,nrl_ssi_unc
ivaridt = ncdf_varid(cdfid,'time')
ncdf_varget,cdfid,ivaridt,nrl_date
day_zero_mjd = iso_date2mjdn('1610-01-01')
nrl_date = nrl_date + day_zero_mjd
nrl_date_jd = mjd2jd(nrl_date)
nrl_date = jd2yf4(mjd2jd(nrl_date))
ivaridt=ncdf_varid(cdfid,'wavelength')
ncdf_varget,cdfid,ivaridt,wavelength
ivaridt=ncdf_varid(cdfid,'Wavelength_Band_Width')
ncdf_varget,cdfid,ivaridt,bandwidth
ivaridt=ncdf_varid(cdfid,'TSI')
ncdf_varget,cdfid,ivaridt,nrl_tsi
ivaridt=ncdf_varid(cdfid,'TSI_UNC')
ncdf_varget,cdfid,ivaridt,nrl_tsi_unc

;TIM measurements
tim=read_lasp_ascii_file('/Users/hofmann/Documents/FCDR_Solar/NCDC flyer/sorce_tsi_L3_c24h_latest.webarchive')
tim_time=jd2yf4(tim.nominal_date_jdn)
tim_tsi = tim.tsi_1au

;SIM measurements (this is combined solstice/sim data product)
sim=read_lasp_ascii_file('/Users/hofmann/Downloads/sorce_ssi_L3_c24h_0000nm_2413nm_20030301_20130729-3.txt')
;s=sort(sim.min_wavelength)
;qmin=uniq(sim[s].min_wavelength)
;s=sort(sim.max_wavelength)      
;qmax=uniq(sim[s].max_wavelength)

;MODTRAN5 surface calcs
restore,filename='/Users/hofmann/git/nrlssi/test/mod5surfacecalcs_shortwave_nm.sav',/verb
restore,filename='/Users/hofmann/git/nrlssi/test/mod5surfacecalcs_lw.sav'

goto, fig7

fig1:
;Figure 1-------------------------------
;NRLSSI2 reference spectrum with blackbody curve
  model_params = get_model_params()
  nrlssi2_ref = model_params.iquiet
  lambda=model_params.lambda
  spectral_bins = get_spectral_bins() 
  
  ;define constants for Planck blackbody calculation
  K  = 1.38062*10.^(-23)  ;Boltzmann's constant (units =J/K)
  c  = 2.99792458*10.^14  ;velocity of light (units = um/sec)
  h  = 6.62620*10.^(-34)  ;Planck's constant (units = J sec)
  c1 = 2*h*c^2.*(10.^6)^2 ;units = W m-2 sr-1 um4
  c2 = h*c/K              ;units = K um
  sigma = 5.670373 * 10^(-8.) ;units W m-2 K-4 : Stephan-Boltzman constant
  Teff = (model_params.tquiet/sigma)^(.25) ; effective temperature of the planet
  bwien=2897; um K ; Wien constant of proportionality
  RSE = 2.164487E-5 ;sun/earth distance squared
  imax = where(nrlssi2_ref eq max(nrlssi2_ref))
  lambda_max = lambda(imax)
  T_at_max = bwien/(lambda_max/1000.) ;6423.03 K
  
  
  lambda1=lambda/1000.
  T0 = 5000.
  T1 = 5770.; peak energy around 502 nm using Wien's displacement law
  T2 = 6000. ; peak energy around 480 nm
  ;T3 = T_at_max  ;peak energy at wavelength where quiet sun irradiance is largest
  T3 = 6450. ;
  T4 = 7000. ;
  
  ;Planck radiance function (function of wavelength) units = W m-2 sr-1 um-1 (lambda must be in microns!!)
  B0_rad = c1/lambda1^5./(exp(c2/lambda1/T0)-1) ;planck radiance function (wavelength units) -this is radiance at Sun (W m-2 sr-1 um-1)
  B1_rad = c1/lambda1^5./(exp(c2/lambda1/T1)-1) 
  B2_rad = c1/lambda1^5./(exp(c2/lambda1/T2)-1) 
  B3_rad = c1/lambda1^5./(exp(c2/lambda1/T3)-1) 
  B4_rad = c1/lambda1^5./(exp(c2/lambda1/T4)-1) 

  ;Planck Irradiance Function units = W m-2 um-1 (Irradiance = pi * radiance)
  B0_irrad = !pi * B0_rad ;Planck Irradiance function (wavelength units) - this is irradiance at Sun (W m-2 um-1)
  B1_irrad = !pi * B1_rad
  B2_irrad = !pi * B2_rad
  B3_irrad = !pi * B3_rad
  B4_irrad = !pi * B4_rad

  ;Account for distance dependency to convert to irradiance at 1 AU (units = W m-2 um-1)
  B0_irrad = B0_irrad * RSE 
  B1_irrad = B1_irrad * RSE
  B2_irrad = B2_irrad * RSE  
  B3_irrad = B3_irrad * RSE
  B4_irrad = B4_irrad * RSE
  

  wien_max = bwien/[T1,T2,T3] ;wavelengths where radiance at Planck temperatures peaks
;  a0 = where(lambda1 ge wien_max[0]) & a0 = a0[0]
  a1 = where(lambda1 ge wien_max[0]) & a1 = a1[0]
  a2 = where(lambda1 ge wien_max[1]) & a2 = a2[0]
  a3 = where(lambda1 ge wien_max[2]) & a3 = a3[0]
;  a4 = where(lambda1 ge wien_max[4]) & a4 = a4[0]
  
  B_at_wien_max = [B1_irrad[a1]/(10^3.),B2_irrad[a2]/(10^3.),B3_irrad[a3]/(10^3.)] ;irradiance at above wavelengths (in units W m-2 nm-1)
  
  p=plot(lambda[2286:*],nrlssi2_ref[2286:*],ytitle='Irradiance (W m!U-2!N nm!U-1!N)',xtitle='Wavelength (nm)','-k',axis_style=1,margin=[.2,.15,.2,.15],thick=2,font_size=16,title='Reference (Quiet Sun) Spectrum') 
  p0=plot(lambda[0:2285],nrlssi2_ref[0:2285],'-',color='medium purple',sym_size=0.2,thick=2,overplot=1) ;color section based on SORCE measurements purple
  p1=plot(lambda,B1_irrad/1000.,name='T!Dblackbody!N=5770 K','--',color='grey',overplot=1,font_size=16) ;units converted to W m-2 nm-1
  
  ;overplot Modtran5 surface calculations
  file='/Users/hofmann/Documents/FCDR_Solar/Modtran_calcs/BAMS_trial/sw/specflux'
  r1=specflux_reader(file,/nm,ds=2)
  p2=plot(r1.wavelength,r1.flux(*,0),color='green',overplot=1,font_size=16,name='Solar Irradiance at Surface') ;through 10000 nm in W m-2 nm-1
  file='/Users/hofmann/Documents/FCDR_Solar/Modtran_calcs/BAMS_trial/lw/specflux'
  r2=specflux_reader(file,/nm,ds=2)
  p3=plot(r2.wavelength,r2.flux(*,0),color='green',overplot=1,font_size=16); from 10000 to 100000 nm in W m-2 nm-1

  p.xlog=1
  p.ylog=1
  p.yrange=[10e-15,10e2]
  p2.min_value=10e-12
  p3.min_value=10e-12
  t1=text(1.9*10^2.,10^(1.),'Total Solar Irradiance = 1360.45 W m!U-2!N',font_size=14,/data)
  l=legend(target=[p1,p2],/data,linestyle=6,font_size=14,shadow=0,position=[1.4*10^4.,10.^(-11)])


  ;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig1_revised2.png';, /TRANSPARENT
;end of Figure 1------------------------------- 

fig2:
;Figure 2--------------------------------------
p=plot(nrl_date,nrl_tsi,'-',color='orange',ytitle='Irradiance (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,title='NRLTSI2 Total Solar Irradiance')
p.xrange=[1978,2015]
qline=[1360.45,1360.45]
p1=plot(p.xrange,qline,'.-.k',overplot=1) ;overplot line for quiet sun
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig2a.png';, /TRANSPARENT
;end of Figure 2a------------------------------- 

fig2b:
restore,file='model_inputs_daily_s19781107_e20141231_c20150329.sav'
nrl_date = jd2yf4(mjd2jd(mjd))
p=plot(nrl_date,totfac,'-',color='deep pink',ytitle='Irradiance (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16)
p1=plot(nrl_date,totspot,'-',color='dodger blue',margin=[.2,.15,.2,.15],font_size=16,overplot=1)
p.xrange=[1978,2015]
p.yrange=[-7,5]
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig2b.eps';, /TRANSPARENT
;end of Figure 2b------------------------------

fig3:
;Figure 3------------------------------
;;Time series (1978-2014 of binned SSI)
;200-210
;300-400
;700-1000
;1000-1300

wav1a = 200 & wav1b = 210
wav2a = 300 & wav2b = 400
wav3a = 700 & wav3b = 1000
wav4a = 1000 & wav4b = 1300
k = 13204 ;timelength of nrl_ssi time series

bin_ssi_1 = dblarr(k) ;200-210 nm
bin_ssi_2 = dblarr(k) ;300-400 nm
bin_ssi_3 = dblarr(k) ;700-1000 nm
bin_ssi_4 = dblarr(k) ;1000-1300 nm

bin_ssi_1_unc = dblarr(k)
bin_ssi_2_unc = dblarr(k)
bin_ssi_3_unc = dblarr(k)
bin_ssi_4_unc = dblarr(k)

bin_1 =where((wavelength ge wav1a) and (wavelength lt wav1b),cntwav)
bin_2 = where((wavelength ge wav2a) and (wavelength lt wav2b),cntwav)
bin_3 = where((wavelength ge wav3a) and (wavelength lt wav3b),cntwav)
bin_4 = where((wavelength ge wav4a) and (wavelength lt wav4b),cntwav)
k = 13204 ;timelength of nrl_ssi time series

for j=0,k-1 do begin
  bin_ssi_1[j] = total(nrl_ssi[bin_1,j]*bandwidth(bin_1),/double)
  bin_ssi_2[j] = total(nrl_ssi[bin_2,j]*bandwidth(bin_2),/double)
  bin_ssi_3[j] = total(nrl_ssi[bin_3,j]*bandwidth(bin_3),/double)
  bin_ssi_4[j] = total(nrl_ssi[bin_4,j]*bandwidth(bin_4),/double)
endfor

;modified to include a relative variability axis on right hand of each plot
p=plot(nrl_date,bin_ssi_1,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,1],color='deep pink',title='NRLSSI2 Solar Spectral Irradiance')
a=-1. & b = 1./mean(bin_ssi_1)
yaxis=axis('y',location='right',coord_transform=[a,b]*100.,tickfont_size=16,target=p,tickdir=1)
p1=plot(nrl_date,bin_ssi_2,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,ytitle='Irradiance (W m!U-2!N)',layout=[1,4,2],/current,color='deep pink')
a=-1. & b = 1./mean(bin_ssi_2)
yaxis=axis('y',location='right',title='relative !C variability !C (%)',coord_transform=[a,b]*100.,tickfont_size=16,target=p1,tickdir=1)
p2=plot(nrl_date,bin_ssi_3,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,3],/current,color='deep pink')
a=-1. & b = 1./mean(bin_ssi_3)
yaxis=axis('y',location='right',coord_transform=[a,b]*100.,tickfont_size=16,target=p2,tickdir=1)
p3=plot(nrl_date,bin_ssi_4,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,4],/current,color='deep pink')
a=-1. & b = 1./mean(bin_ssi_4)
yaxis=axis('y',location='right',coord_transform=[a,b]*100.,tickfont_size=16,target=p3,tickdir=1)

p.xrange=[1978,2015]
p1.xrange=[1978,2015]
p2.xrange=[1978,2015]
p3.xrange=[1978,2015]
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig3_revised.eps';, /TRANSPARENT
;end of Figure 3------------------------------

fig4:
;Figure 4------------------------------
subset = where(nrl_date ge 2003.6 and nrl_date le 2004.0)
p = ERRORPLOT(nrl_date(subset), nrl_tsi(subset), nrl_tsi_unc(subset),'-g2.',errorbar_capsize=0,errorbar_color='grey',ytitle='Irradiance (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,title='NRLTSI2 Total Solar Irradiance !C Compared to Measurements',name='NRLTSI2')
subset_tim = where(tim_time ge 2003.6 and tim_time le 2004.0)
p1=plot(tim_time(subset_tim),tim_tsi(subset_tim),symbol='o',color='light green',overplot=1,name='SORCE TIM',sym_size=0.5)
l=legend(target=[p,p1],/data,linestyle=6,font_size=16,shadow=0,position=[2003.75,1357])
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig4a.eps';, /TRANSPARENT

subset = where(nrl_date ge 2008.7 and nrl_date le 2009.0)
p = ERRORPLOT(nrl_date(subset), nrl_tsi(subset), nrl_tsi_unc(subset),'-g2.',errorbar_capsize=0,errorbar_color='grey',ytitle='Irradiance (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,title='NRLTSI2 Total Solar Irradiance !C Compared to Measurements',name='NRLTSI2')
subset_tim = where(tim_time ge 2008.7 and tim_time le 2009.0)
p1=plot(tim_time(subset_tim),tim_tsi(subset_tim),symbol='o',color='light green',overplot=1,name='SORCE TIM',sym_size=0.5)
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig4b.eps';, /TRANSPARENT

subset = where(nrl_date ge 2003.1527 and nrl_date le 2015.0)
p = ERRORPLOT(nrl_date(subset), nrl_tsi(subset), nrl_tsi_unc(subset),'-g2.',errorbar_capsize=0,errorbar_color='grey',ytitle='Irradiance (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,title='NRLTSI2 Total Solar Irradiance !C Compared to Measurements',name='NRLTSI2')
subset_tim = where(tim_time ge 2003.1527 and tim_time le 2015.0)
p1=plot(tim_time(subset_tim),tim_tsi(subset_tim),symbol='o',color='light green',overplot=1,name='SORCE TIM',sym_size=0.5,min_value=1300)
p.xrange=[2003,2015]
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig4c.eps';, /TRANSPARENT

;modified to have log y-axis on difference plot
tt=where(tim_tsi(subset_tim) eq 0.0)
tim_tsi(subset_tim(tt)) = !values.d_NaN
difference=tim_tsi(subset_tim) - nrl_tsi(subset)
p = plot(tim_time(subset_tim),difference,'-ok',sym_size=0.5,ytitle= 'Difference (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,name='TIM - NRLTSI2')
p.xrange=[2003,2015]
;p.yrange=[-1,2.5]
zero=[0,0]
p1=plot(p.xrange,zero,'-2',color='light grey',overplot=1)
result=smooth(difference,365,/NaN,/edge_wrap)
p2=plot(tim_time(subset_tim),result,'-',color='pink',overplot=1,name='365 day smooth')
l=legend(target=[p,p2],/data,position=[2008.6,2.0],linestyle=6,font_size=16,shadow=0)
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig4d_revised.eps';, /TRANSPARENT
;
;a new try: modified to have a break in the y-axis (create break in illustrator)
tt=where(tim_tsi(subset_tim) eq 0.0)
tim_tsi(subset_tim(tt)) = !values.d_NaN
difference=tim_tsi(subset_tim) - nrl_tsi(subset)
pbottom = plot(tim_time(subset_tim),difference,'-ok',sym_size=0.5,ytitle= 'Difference (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,name='TIM - NRLTSI2',yrange=[-.75,.75])
pbottom.xrange=[2003,2015]
zero=[0,0]
ax=pbottom.axes
ax[2].hide=1
p1=plot(pbottom.xrange,zero,'-2',color='light grey',overplot=1)
result=smooth(difference,365,/NaN,/edge_wrap)
p2=plot(tim_time(subset_tim),result,'-',color='pink',overplot=1,name='365 day smooth')
l=legend(target=[pbottom,p2],/data,position=[2008.6,0.5],linestyle=6,font_size=16,shadow=0)
;;pbottom.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig4d_bottom_revised.eps';, /TRANSPARENT
ptop =plot(tim_time(subset_tim),difference,'-ok',sym_size=0.5,margin=[.2,.15,.2,.50],font_size=16,name='TIM - NRLTSI2',yrange=[1,2.25],axis=2,ymajor=3,ytickvalues=[1.0,1.5,2.0])
ptop.xrange=[2003,2015]
axy=ptop.axes
axy[0].hide=1
;ptop.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig4d_top_revised.eps';, /TRANSPARENT

;end of Figure 4------------------------------

fig5:
;Figure 5------------------------------
;200-210
;300-400
;700-1000
;1000-1300

wav1a = 200 & wav1b = 210
wav2a = 300 & wav2b = 400
wav3a = 700 & wav3b = 1000
wav4a = 1000 & wav4b = 1300
k = 13204 ;timelength of nrl_ssi time series

bin_ssi_1 = dblarr(k) ;200-210 nm
bin_ssi_2 = dblarr(k) ;300-400 nm
bin_ssi_3 = dblarr(k) ;700-1000 nm
bin_ssi_4 = dblarr(k) ;1000-1300 nm

bin_ssi_1_unc = dblarr(k)
bin_ssi_2_unc = dblarr(k)
bin_ssi_3_unc = dblarr(k)
bin_ssi_4_unc = dblarr(k)

bin_1 =where((wavelength ge wav1a) and (wavelength lt wav1b),cntwav)
bin_2 = where((wavelength ge wav2a) and (wavelength lt wav2b),cntwav)
bin_3 = where((wavelength ge wav3a) and (wavelength lt wav3b),cntwav)
bin_4 = where((wavelength ge wav4a) and (wavelength lt wav4b),cntwav)
k = 13204 ;timelength of nrl_ssi time series

for j=0,k-1 do begin
  bin_ssi_1[j] = total(nrl_ssi[bin_1,j]*bandwidth(bin_1),/double)
  bin_ssi_2[j] = total(nrl_ssi[bin_2,j]*bandwidth(bin_2),/double)
  bin_ssi_3[j] = total(nrl_ssi[bin_3,j]*bandwidth(bin_3),/double)
  bin_ssi_4[j] = total(nrl_ssi[bin_4,j]*bandwidth(bin_4),/double)
  ;bin_ssi_1_unc[j] = total(nrl_ssi_unc[bin_1,j],/double) ;when quantities are added, the uncertainties add (as an upper bound), but if independent and random would be the quadrature sum of the uncertainties
  ;bin_ssi_2_unc[j] = total(nrl_ssi_unc[bin_2,j],/double)
  ;bin_ssi_3_unc[j] = total(nrl_ssi_unc[bin_3,j],/double)
  ;bin_ssi_4_unc[j] = total(nrl_ssi_unc[bin_4,j],/double)
  bin_ssi_1_unc[j] = total(nrl_ssi_unc[bin_1,j]*bandwidth(bin_1),/double) ;when quantities are added, the uncertainties add (as an upper bound), but if independent and random would be the quadrature sum of the uncertainties
  bin_ssi_2_unc[j] = total(nrl_ssi_unc[bin_2,j]*bandwidth(bin_2),/double)
  bin_ssi_3_unc[j] = total(nrl_ssi_unc[bin_3,j]*bandwidth(bin_3),/double)
  bin_ssi_4_unc[j] = total(nrl_ssi_unc[bin_4,j]*bandwidth(bin_4),/double)
  
  ; bin_ssi_1_unc[j] = SQRT(total((nrl_ssi_unc[bin_1,j])^2.)) ;when quantities are added, the uncertainties add (as an upper bound), but if independent and random would be the quadrature sum of the uncertainties
  ; bin_ssi_2_unc[j] = SQRT(total((nrl_ssi_unc[bin_2,j])^2.))
  ; bin_ssi_3_unc[j] = SQRT(total((nrl_ssi_unc[bin_3,j])^2.))
  ; bin_ssi_4_unc[j] = SQRT(total((nrl_ssi_unc[bin_4,j])^2.))
endfor

subset = where(nrl_date ge 2003.5 and nrl_date le 2005.0)

;ssi data.
;loop over julian date within subset
;s=sort(sim.nominal_date_jdn)
d1 = yf42jd(2003.5)
d2 = yf42jd(2005.0)
nday=548
sim_time=dblarr(nday)

; wavelength grid for SORCE SSI data
nwv=2412-115
sim_wl=findgen(nwv)+115.5   ;center of wavelength bin
sim_ssi=fltarr(nday,nwv);

dd1 = d1
dd1=2452823 ;this is '2003-07-02'
for i=0,nday-1 do begin
  ;obtain SORCE spectrum for this day and interpolate onto 1 nm grid
  result = where(sim.nominal_date_jdn eq dd1,cnt) ;also subset by wavelength
  sorwl = (sim[result].min_wavelength+sim[result].max_wavelength) / 2.
  sorflx = sim[result].irradiance
  ;;;;; SOLSTICE FUV
  r1 = sorwl gt 115.0
  r2 = sorwl lt 180
  r3 = sorflx gt 0
  rw=where(r1*r2*r3,cntw)
  ; for a full FUV spectrum there should be 65 points
  if(cntw eq 65) then begin
    ; interpolate onto 1 nm grid
    ngg=fix(sorwl(rw(cntw-1))-sorwl(rw(0))+1)
    gg=findgen(ngg)+sorwl(rw(0))
    yy=interpol(sorflx(rw),sorwl(rw),gg)
    ; put this spectrum into the approriate part of the sim_ssi array
    sim_ssi[i,gg(0)-115.5:gg(0)-115.5+ngg-1] = yy
  endif
  ;;;;; SOLSTICE MUV
  r1=sorwl gt 180.0
  r2=sorwl lt 310
  r3=sorflx gt 0
  rw=where(r1*r2*r3,cntw)
  ; for a full muv spectrum there should be 130 points
  if(cntw eq 130) then begin
    ; interpolate onto 1 nm grid
    ngg=fix(sorwl(rw(cntw-1))-sorwl(rw(0))+1)
    gg=findgen(ngg)+sorwl(rw(0))
    yy=interpol(sorflx(rw),sorwl(rw),gg)
    ; put this spectrum into the approriate part of the si array
    sim_ssi[i,gg(0)-115.5:gg(0)-115.5+ngg-1] = yy
  endif
  ;;;;; SIM
  r1=sorwl gt 310.1
  r2=sorwl lt 2412
  r3=sorflx gt 0.01
  rw=where(r1*r2*r3,cntw)
  ; note - avoid 310.02 since this has zero flux typically
  ; for a full vis-ir spectrum there should be >700 points
  if(cntw gt 600) then begin
    ; interpolate onto 1 nm grid - unlike FUV and MUV the SIM data are
    ; not on 1 nm grid so need to specify the grid to be from 310.5 to 2400.5
    ngg=fix(sorwl(rw(cntw-1))-sorwl(rw(0))+1)
    gg=findgen(ngg)+sorwl(rw(0))
    yy=interpol(sorflx(rw),sorwl(rw),gg)
    ; put this spectrum into the approriate part of the si array
    sim_ssi[i,gg(0)-115.5:gg(0)-115.5+ngg-1] = yy
  endif
  dd1=dd1+1.d0
endfor ; end of cycling through days of grid

;Bin SIM irradiance into same 4 broad wl bands as NRLSSI2 data
bin_1_sim = dblarr(nday)
bin_2_sim = dblarr(nday)
bin_3_sim = dblarr(nday)
bin_4_sim = dblarr(nday)

for i=0,nday-1 do begin
  result = where((sim_wl[*] ge wav1a) and (sim_wl[*] le wav1b),cntwav)  ;subset by wavelength
  if cntwav gt 0 then bin_1_sim[i] = total(sim_ssi[i,result]) else bin_1_sim[i] = !values.d_NaN ;don't count days with missing data in the total
  result = where((sim_wl[*] ge wav2a) and (sim_wl[*] le wav2b),cntwav)  ;subset by wavelength
  if cntwav gt 0 then bin_2_sim[i] = total(sim_ssi[i,result]) else bin_2_sim[i] = !values.d_NaN
  result = where((sim_wl[*] ge wav3a) and (sim_wl[*] le wav3b),cntwav)  ;subset by wavelength
  if cntwav gt 0 then bin_3_sim[i] = total(sim_ssi[i,result]) else bin_3_sim[i] = !values.d_NaN
  result = where((sim_wl[*] ge wav4a) and (sim_wl[*] le wav4b),cntwav)  ;subset by wavelength
  if cntwav gt 0 then bin_4_sim[i] = total(sim_ssi[i,result])  else bin_4_sim[i] = !values.d_NaN
endfor

b1 = where(bin_1_sim gt 0) ;exclude days with missing data (irradiance will =0 on these days, based on how we placed the daily spectra into arrays)
b2 = where(bin_2_sim gt 0)
b3 = where(bin_3_sim gt 0)
b4 = where(bin_4_sim gt 0)

bs1 = bin_ssi_1(subset(185))/bin_1_sim(b1(185)) ;these are scaling factors needed to make the NRLSSI2 and SORCE spectrum equal near start of 2004 ('2004-01-04')
bs2 = bin_ssi_2(subset(185))/bin_2_sim(b2(185))
bs3 = bin_ssi_3(subset(185))/bin_3_sim(b3(185))
bs4 = bin_ssi_4(subset(185))/bin_4_sim(b4(185))

print,'bin, wl, scaling factors'
print,'bin 1, 200-210, ',bs1
print,'bin 2, 300-700, ',bs2
print,'bin 3, 700-1000, ',bs3
print,'bin 4, 1000-1300, ',bs4

p=errorplot(nrl_date(subset),bin_ssi_1(subset),bin_ssi_1_unc(subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,layout=[1,4,1],color='deep pink',title='NRLSSI2 Solar Spectral Irradiance !C with Uncertainties',errorbar_capsize=0,errorbar_color='grey')
ps=plot(nrl_date(subset(b1)),bin_1_sim(b1)*bs1,margin=[0.25,.2,.2,.35],color='light green',sym_size=0.5,overplot=1,axis_style=1)
p1=errorplot(nrl_date(subset),bin_ssi_2(subset),bin_ssi_2_unc(subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,ytitle='Irradiance (W m!U-2!N)',layout=[1,4,2],/current,color='deep pink',errorbar_capsize=0,errorbar_color='grey')
p1s=plot(nrl_date(subset(b2)),bin_2_sim(b2)*bs2,margin=[0.25,.2,.2,.35],color='light green',sym_size=0.5,overplot=1,min_value=90.,axis_style=1)
p2=errorplot(nrl_date(subset),bin_ssi_3(subset),bin_ssi_3_unc(subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,layout=[1,4,3],/current,'deep pink',errorbar_capsize=0,errorbar_color='grey')
p2s=plot(nrl_date(subset(b3)),bin_3_sim(b3)*bs3,margin=[0.25,.2,.2,.35],color='light green',sym_size=0.5,overplot=1,axis_style=1)
p3=errorplot(nrl_date(subset),bin_ssi_4(subset),bin_ssi_4_unc(subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,layout=[1,4,4],/current,'deep pink',errorbar_capsize=0,errorbar_color='grey')
p3s=plot(nrl_date(subset(b4)),bin_4_sim(b4)*bs4,margin=[0.25,.2,.2,.35],color='light green',sym_size=0.5,overplot=1,axis_style=1)

p.yrange=[0.104,0.115]
p1.yrange=[92.6,93.6]
p2.yrange=[304.7,306]
p3.yrange=[165,165.7]
;p=errorplot(nrl_date(subset),bin_ssi_1(subset),bin_ssi_1_unc(subset),margin=[.25,.2,.2,.25],font_size=16,axis_style=1,layout=[1,2,1],color='deep pink',title='NRLSSI2 Solar Spectral Irradiance !C with Uncertainties',errorbar_capsize=0,errorbar_color='grey')
;ps=plot(nrl_date(subset),bin_1_sim*.85,margin=[0.25,.2,.2,.35],'.-',color='light green',overplot=1)
;p3=errorplot(nrl_date(subset),bin_ssi_4(subset),bin_ssi_4_unc(subset),margin=[.25,.2,.2,.25],font_size=16,axis_style=1,layout=[1,2,2],/current,'deep pink',errorbar_capsize=0,errorbar_color='grey')
;p3s=plot(nrl_date(subset),bin_4_sim*.994,margin=[0.25,.2,.2,.35],'.-',color='light green',overplot=1)
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig5_v2.eps';, /TRANSPARENT
;end of Figure 5------------------------------


fig6:
;compare NRLTSI to NRLTSI2
nrltsi2 = nrl_tsi ;opened at start of program
nrltsi2_date = nrl_date

;original NRLTSI values
result = read_nrl_nrlssi1()
nrltsi1 = result.tsi
;truncate judith data to same time period
;1978-11-07 through 2014-12-31 = result[310:*]
j1 = 310
j2 = 13513
;tt=jd2yf4(mjd2jd(lasp.mjd))
nrltsi1 = nrltsi1[j1:j2]

p=plot(nrltsi2_date,nrltsi2,'-',color='orange',ytitle='Irradiance (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,title='NRLTSI2 Total Solar Irradiance',name='NRLTSI2')
p1=plot(nrltsi2_date,nrltsi1-5.,'-',color='blue',overplot=1,name='NRLTSI - 5.0')
p.xrange=[1978,2014.3]
p1.min_value=1300.
l=legend(target=[p,p1],/data,linestyle=6,font_size=16,shadow=0)
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig6a.eps';, /TRANSPARENT

;difference plot
diff = nrltsi2-(nrltsi1-5.)
p=plot(nrltsi2_date,diff,'-',ytitle='Irradiance (W m!U-2!N)',margin=[.2,.15,.2,.15],font_size=16,title='Residual:NRLTSI2 - NRLTSI + 5')
p.xrange=[1978,2014.3]
p.max_value=5.
diff_mean = mean(diff(0:12897))
diff_std = stddev(diff(0:12897))
print,'mean diff', diff_mean
print,'stddev of diff', diff_std
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig6b.eps';, /TRANSPARENT
;end of Figure 6------------------------------

fig7:
upperflag = 1 ;if 1, do upper bound of uncertainties, if 0, do lower bound
if upperflag eq 1 then print,'***** Performing Upper bound of uncertainties'
if upperflag eq 0 then print, '***** Not Performing Upper bound of uncertainties'

;compare energy max to min from NRLSSI and NRLSSI2 (in energy units and in irradiance units)
;include uncertainties with NRLSSI2
;original NRLSSI values  (NOTE - 5 less wavelength bands for NRLSSI1 compared to NRLSSI2)
result = read_nrl_nrlssi1()
nrlssi1 = result.spec
wl_nrlssi1 = result.wl

;truncate data to same max/min time period
;max = 2013.03 to 2013.06 ('2013-01-11' to '2013-01-22')
;min = 2008.91 to 2008.98 ('2008-11-28' to '2008-12-23')
j1 = 12794
j2 = 12805
;tt=jd2yf4(mjd2jd(lasp.mjd))
nrlssi1_max = nrlssi1[*,j1:j2]
nrlssi1_max_mean = fltarr(3780)
for ii=0,3779 do begin
  nrlssi1_max_mean[ii] = mean(nrlssi1_max[ii,*]) ;average irradiance for max conditions
endfor

j1 = 11289
j2 = 11314
;tt=jd2yf4(mjd2jd(lasp.mjd))
nrlssi1_min = nrlssi1[*,j1:j2]
nrlssi1_min_mean = fltarr(3780)
for ii=0,3779 do begin
  nrlssi1_min_mean[ii] = mean(nrlssi1_min[ii,*]) ;average irradiance for min conditions
endfor

;NOW get NRLSSI2 data
;2013.03 to 2013.06 ('2013-01-11' to '2013-01-22')
nrlssi2 =nrl_ssi
nrlssi2unc=nrl_ssi_unc
nrlssi2_date = nrl_date
j1 = 12484 ; 12486 (12486 = Jan 13th, 2013, 12484=Jan 11, 2013)
j2 = 12495
nday = j2-j1+1.
nrlssi2_max = nrlssi2[*,j1:j2]
nrlssi2_max_unc = nrlssi2unc[*,j1:j2]
nrlssi2_max_mean = fltarr(3785)
unc_nrlssi2_max_mean = fltarr(3785)
for ii=0,3784 do begin
  nrlssi2_max_mean[ii] = mean(nrlssi2_max[ii,*]) ;average irradiance for max conditions.
  if upperflag eq 1 then unc_nrlssi2_max_mean[ii] = 1./nday * total(nrlssi2_max_unc[ii,*]) ; upper bound
  if upperflag eq 0 then unc_nrlssi2_max_mean[ii] =  1./nday * SQRT(total(nrlssi2_max_unc[ii,*])^2.) ;not upper bound
endfor

;min = 2008.91 to 2008.98 ('2008-11-28' to '2008-12-23')

j1 = 10979
j2 = 11004
nday = j2-j1+1
nrlssi2_min = nrlssi2[*,j1:j2]
nrlssi2_min_unc = nrlssi2unc[*,j1:j2]
nrlssi2_min_mean = fltarr(3785)
unc_nrlssi2_min_mean = fltarr(3785)
for ii=0,3784 do begin
  nrlssi2_min_mean[ii] = mean(nrlssi2_min[ii,*])
  ;unc_nrlssi2_min_mean[ii] = mean(nrlssi2_min_unc[ii,*])
  if upperflag eq 1 then unc_nrlssi2_min_mean[ii] = 1./nday * total(nrlssi2_min_unc[ii,*]) ; upper bound
  if upperflag eq 0 then unc_nrlssi2_min_mean[ii] = 1./nday * SQRT(total(nrlssi2_min_unc[ii,*])^2.) ;not upper bound
endfor

;;define wl grid for NRLSSI2 data
infile = '/Users/hofmann/Documents/FCDR_Solar/NRLSSI2_1978_2014d_S21_28Jan15.txt'
result = read_nrl_nrlssi2(infile,1978,2014)
jud_nrlssi2 = result.spec
wl_nrlssi2 = result.wl

;Now compute irradiance difference (max-min) and propagate uncertainties
nrlssi2_max_minus_min = nrlssi2_max_mean -nrlssi2_min_mean
if upperflag eq 1 then unc_nrlssi2_max_minus_min = (unc_nrlssi2_max_mean) + (unc_nrlssi2_min_mean) ;the upper bound
if upperflag eq 0 then unc_nrlssi2_max_minus_min = sqrt((unc_nrlssi2_max_mean)^2. + (unc_nrlssi2_min_mean)^2.) ; the quadrature sum of the individual uncertainties for the means.
nrlssi1_max_minus_min = nrlssi1_max_mean - nrlssi1_min_mean

;Now compute energy change (max/min) and propagate uncertainties ;need to account for different spectral range in nrlssi2 and nrlssi1
nrlssi2_max_over_min = ((nrlssi2_max_mean / nrlssi2_min_mean) -1.)*100. ;max to min energy change in %
if upperflag eq 1 then unc_nrlssi2_max_over_min = abs(1./nrlssi2_min_mean)*unc_nrlssi2_max_mean + abs((-1.)*nrlssi2_max_mean/nrlssi2_min_mean^2.)*unc_nrlssi2_min_mean ;upper bound
if upperflag eq 0 then unc_nrlssi2_max_over_min = SQRT( (unc_nrlssi2_max_mean/nrlssi2_min_mean)^2 + (((-1.)*unc_nrlssi2_min_mean*nrlssi2_max_mean)/nrlssi2_min_mean)^2 );lwer bound
;if upperflag eq 0 then unc_nrlssi2_max_over_min = SQRT((unc_nrlssi2_max_mean/nrlssi2_min_mean)^2 + (((-1.)*nrlssi2_max_mean*unc_nrlssi2_min_mean)/(nrlssi2_min_mean)^2)^2.) ;not upper bound
nrlssi1_max_over_min = ((nrlssi1_max_mean / nrlssi1_min_mean) -1.)*100. ;because it's relative, don't need to worry about converting from mW to W


;Irradiance difference
p=errorplot(wl_nrlssi2(*,0),nrlssi2_max_minus_min,unc_nrlssi2_max_minus_min,xtitle='Wavelength (nm)',ytitle='W m-2 nm-1',margin=[.2,.15,.2,.15],font_size=16,color='deep pink',errorbar_capsize=0,errorbar_color='grey',name='NRLSSI2')
p1=plot(wl_nrlssi1(*,0),(nrlssi1_max_minus_min)/1000.,xlog=1,overplot=1,name='NRLSSI') ;convert from mW to W
l=legend(target=[p,p1],/data,linestyle=6,font_size=16,shadow=0)
p.yrange=[-0.001,0.006]
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig7a_v2.eps';, /TRANSPARENT

;Energy Difference

;p=plot(wl_nrlssi2(*,0),nrlssi2_max_over_min,xtitle='Wavelength (nm)',ytitle='Percent',margin=[.2,.15,.2,.15],font_size=16,color='deep pink',name='NRLSSI2',xlog=1)
;p0=plot(wl_nrlssi2(a,0),nrlssi2_max_over_min(a),color='deep pink','--',overplot=1)
;p1=plot(wl_nrlssi2(*,0),nrlssi2_max_over_min+(unc_nrlssi2_max_over_min)*100,color='grey',overplot=1) ;positive bound of error bar
;p2=plot(wl_nrlssi2(*,0),abs(nrlssi2_max_over_min-(unc_nrlssi2_max_over_min)*100),color='grey',overplot=1) ;negative bound of error bar
;p3=plot(wl_nrlssi1(*,0),(nrlssi1_max_over_min),overplot=1,name='NRLSSI') ;convert from mW to W
;l=legend(target=[p,p3],/data,linestyle=6,font_size=16,shadow=0)
;p.yrange=[0.0001,100]
;p.ylog=1
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig7b_revised.eps';, /TRANSPARENT

high = nrlssi2_max_over_min+(unc_nrlssi2_max_over_min)*100 ;+1 error bar
low = nrlssi2_max_over_min-(unc_nrlssi2_max_over_min)*100 ;-1 error bar
a=where(nrlssi2_max_over_min lt 0)
a1=where(nrlssi1_max_over_min lt 0)
b=where(high lt 0)
;c=where(low lt 0)
;new_low = low
;new_low(c) = 1e-4

p=plot(wl_nrlssi2(*,0),nrlssi2_max_over_min,xtitle='Wavelength (nm)',ytitle='Percent',margin=[.2,.15,.2,.15],font_size=16,color='deep pink',name='NRLSSI2')
p0=plot(wl_nrlssi2(a,0),abs(nrlssi2_max_over_min(a)),color='deep pink',symbol='.',linestyle=6,overplot=1)
p3=plot(wl_nrlssi1(*,0),(nrlssi1_max_over_min),overplot=1,name='NRLSSI') ;convert from mW to W
p30=plot(wl_nrlssi1(a1,0),abs(nrlssi1_max_over_min(a1)),symbol='.',linestyle=6,overplot=1) ;convert from mW to W
p1=plot(wl_nrlssi2(*,0),high,'--',color='grey',overplot=1) ;positive bound of error bar
;p10=plot(wl_nrlssi2(b,0),high(b),'--',color='red',overplot=1) ;
p2=plot(wl_nrlssi2(*,0),low,'--',color='grey',overplot=1) ;negative bound of error bar
;p20=plot(wl_nrlssi2(c,0),(new_low(c)),'--',symbol='.',color='grey',overplot=1,linestyle=6)
p.xlog=1
p.ylog=1
l=legend(target=[p,p3],/data,linestyle=6,font_size=16,shadow=0)
p.yrange=[0.0001,100]
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig7b_revised.eps';, /TRANSPARENT

;subset energy difference (200-600 nm)
;p=plot(wl_nrlssi2(*,0),nrlssi2_max_minus_min,xtitle='Wavelength (nm)',ytitle='W m-2 nm-1',margin=[.2,.15,.2,.15],font_size=16,color='deep pink',name='NRLSSI2')
p=errorplot(wl_nrlssi2(*,0),nrlssi2_max_minus_min,unc_nrlssi2_max_minus_min,xtitle='Wavelength (nm)',ytitle='W m-2 nm-1',margin=[.2,.15,.2,.15],font_size=16,color='deep pink',errorbar_capsize=0,errorbar_color='grey',name='NRLSSI2')

p1=plot(wl_nrlssi1(*,0),(nrlssi1_max_minus_min)/1000.,overplot=1,name='NRLSSI') ;convert from mW to W
l=legend(target=[p,p1],/data,linestyle=6,font_size=16,shadow=0)
p.yrange=[-0.001,0.0045]
p.xrange=[200,600]
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig7c_revised_v2.eps';, /TRANSPARENT

;subset energy ratio (200-600 nm)
p=plot(wl_nrlssi2(*,0),nrlssi2_max_over_min,xtitle='Wavelength (nm)',ytitle='Percent',margin=[.2,.15,.2,.15],font_size=16,color='deep pink',name='NRLSSI2')
p0=plot(wl_nrlssi2(a,0),abs(nrlssi2_max_over_min(a)),color='deep pink',symbol='.',linestyle=6,overplot=1)
p3=plot(wl_nrlssi1(*,0),(nrlssi1_max_over_min),overplot=1,name='NRLSSI') ;convert from mW to W
p30=plot(wl_nrlssi1(a1,0),abs(nrlssi1_max_over_min(a1)),symbol='.',linestyle=6,overplot=1) ;convert from mW to W
p1=plot(wl_nrlssi2(*,0),high,'--',color='grey',overplot=1) ;positive bound of error bar
;p10=plot(wl_nrlssi2(b,0),high(b),'--',color='red',overplot=1) ;
p2=plot(wl_nrlssi2(*,0),low,'--',color='grey',overplot=1) ;negative bound of error bar
;p20=plot(wl_nrlssi2(c,0),(new_low(c)),'--',symbol='.',color='grey',overplot=1,linestyle=6)
p.xlog=0
p.ylog=1
l=legend(target=[p,p3],/data,linestyle=6,font_size=16,shadow=0)
p.yrange=[0.0001,100]
p.xrange=[200,600]
;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig7d_revised_v2.eps';, /TRANSPARENT

;compute the integral of the mean min/max periods for 300-400 nm, 400-600 nm, and 600-800 nm for NRLSSI2 and NRLSSI1
b1 = where(wl_nrlssi1[*,0] ge 300 and wl_nrlssi1[*,0] le 400)
b2 = where(wl_nrlssi1[*,0] ge 400 and wl_nrlssi1[*,0] le 600)
b3 = where(wl_nrlssi1[*,0] ge 600 and wl_nrlssi1[*,0] le 900)
nrlssi1_band1 = total(nrlssi1_max_mean[b1]/1000.*wl_nrlssi1[b1,1]) - total(nrlssi1_min_mean[b1]/1000.*wl_nrlssi1[b1,1]) ;W m-2
nrlssi1_band2 = total(nrlssi1_max_mean[b2]/1000.*wl_nrlssi1[b2,1]) - total(nrlssi1_min_mean[b2]/1000.*wl_nrlssi1[b2,1]) ;W m-2
nrlssi1_band3 = total(nrlssi1_max_mean[b3]/1000.*wl_nrlssi1[b3,1]) - total(nrlssi1_min_mean[b3]/1000.*wl_nrlssi1[b3,1]) ;W m-2
nrlssi1_band1_ratio = (total(nrlssi1_max_mean[b1]/1000.*wl_nrlssi1[b1,1]) / total(nrlssi1_min_mean[b1]/1000.*wl_nrlssi1[b1,1]) -1.)*100 ;%
nrlssi1_band2_ratio = (total(nrlssi1_max_mean[b2]/1000.*wl_nrlssi1[b2,1]) / total(nrlssi1_min_mean[b2]/1000.*wl_nrlssi1[b2,1]) -1.)*100 ;%
nrlssi1_band3_ratio = (total(nrlssi1_max_mean[b3]/1000.*wl_nrlssi1[b3,1]) / total(nrlssi1_min_mean[b3]/1000.*wl_nrlssi1[b3,1]) -1.)*100 ;%

b1 = where(wl_nrlssi2[*,0] ge 300 and wl_nrlssi2[*,0] le 400)
b2 = where(wl_nrlssi2[*,0] ge 400 and wl_nrlssi2[*,0] le 600)
b3 = where(wl_nrlssi2[*,0] ge 600 and wl_nrlssi2[*,0] le 900)
nrlssi2_band1 = total(nrlssi2_max_mean[b1]*wl_nrlssi2[b1,1]) - total(nrlssi2_min_mean[b1]*wl_nrlssi2[b1,1]) ;W m-2
nrlssi2_band2 = total(nrlssi2_max_mean[b2]*wl_nrlssi2[b2,1]) - total(nrlssi2_min_mean[b2]*wl_nrlssi2[b2,1]) ;W m-2
nrlssi2_band3 = total(nrlssi2_max_mean[b3]*wl_nrlssi2[b3,1]) - total(nrlssi2_min_mean[b3]*wl_nrlssi2[b3,1]) ;W m-2
nrlssi2_band1_ratio = (total(nrlssi2_max_mean[b1]*wl_nrlssi2[b1,1]) / total(nrlssi2_min_mean[b1]*wl_nrlssi2[b1,1])-1.)*100 ;%
nrlssi2_band2_ratio = (total(nrlssi2_max_mean[b2]*wl_nrlssi2[b2,1]) / total(nrlssi2_min_mean[b2]*wl_nrlssi2[b2,1])-1.)*100 ;%
nrlssi2_band3_ratio = (total(nrlssi2_max_mean[b3]*wl_nrlssi2[b3,1]) / total(nrlssi2_min_mean[b3]*wl_nrlssi2[b3,1])-1.)*100 ;%

print,nrlssi1_band1,nrlssi1_band2,nrlssi1_band3
print,nrlssi2_band1,nrlssi2_band2,nrlssi2_band3
print,nrlssi1_band1_ratio,nrlssi1_band2_ratio,nrlssi1_band3_ratio
print,nrlssi2_band1_ratio,nrlssi2_band2_ratio,nrlssi2_band3_ratio

;bar plot of max-min per integrated band
bp1 = barplot([nrlssi1_band1,nrlssi1_band2,nrlssi1_band3],index=0,nbars=2,fill_color='black',ytitle='W m!U-2',title='(Max - Min)',xtitle='nm',axis_style=1,xmajor=3,xtickname=['300-400','400-600','600-900'],xtickvalues=[0,1,2],xstyle=1)
bp2 = barplot([nrlssi2_band1,nrlssi2_band2,nrlssi2_band3],index=1,nbars=2,fill_color='deep pink',/overplot)
bp1.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig7e_revised_v3.eps';, /TRANSPARENT

;bar plot of (max/min)-1 * 100 per integrated band
bp3 = barplot([nrlssi1_band1_ratio,nrlssi1_band2_ratio,nrlssi1_band3_ratio],index=0,nbars=2,fill_color='black',ytitle='Percent',title='(Max / Min -1) * 100',xtitle='nm',axis_style=1,xmajor=3,xtickname=['300-400','400-600','600-900'],xtickvalues=[0,1,2],xstyle=1)
bp4 = barplot([nrlssi2_band1_ratio,nrlssi2_band2_ratio,nrlssi2_band3_ratio],index=1,nbars=2,fill_color='deep pink',/overplot)
bp3.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig7f_revised_v3.eps';, /TRANSPARENT


;fig5b:
;;Figure 5b--------------------------------------
;bin_1 =where(wavelength eq 120.5)
;bin_2=where(wavelength eq 250.5)
;bin_3=where(wavelength eq 500.5)
;bin_4=where(wavelength eq 1002.5)
;
;p=errorplot(nrl_date(subset),nrl_ssi(bin_1[0],subset),nrl_ssi_unc(bin_1[0],subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,layout=[1,4,1],color='deep pink',title='NRLSSI2 Solar Spectral Irradiance !C with Uncertainties',errorbar_capsize=0,errorbar_color='grey')
;p1=errorplot(nrl_date(subset),nrl_ssi(bin_2[0],subset),nrl_ssi_unc(bin_2[0],subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,ytitle='Irradiance (W m!U-2!N nm!U-1!N)',layout=[1,4,2],/current,color='deep pink',errorbar_capsize=0,errorbar_color='grey')
;p2=errorplot(nrl_date(subset),nrl_ssi(bin_3[0],subset),nrl_ssi_unc(bin_3[0],subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,layout=[1,4,3],/current,'deep pink',errorbar_capsize=0,errorbar_color='grey')
;p3=errorplot(nrl_date(subset),nrl_ssi(bin_4[0],subset),nrl_ssi_unc(bin_4[0],subset),margin=[.25,.2,.2,.35],font_size=16,axis_style=1,layout=[1,4,4],/current,'deep pink',errorbar_capsize=0,errorbar_color='grey')
;p.yrange=[1.4*10^(-4.),2.4*10^(-4.)]
;p1.yrange=[0.0546,0.0567]
;p2.yrange=[1.896,1.912]
;p3.yrange=[0.7302,0.7331]
;
;;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig5b.eps';, /TRANSPARENT
;;end of  Figure 5b------------------------------

review:
;respond to reviewer question 10:
;show a time series of the integral of the spectrum of the facular contributions to the quiet sun irradiance (computed without the added small correction factor), 
;relative to the integral of the spectrum of the facular contributions to the quiet sun irradiance (with the added small correction factor), and similarly for the sunspot darkening contribution.  
restore,'test/ssi_nocorr_proxy_contrast_s2000-01-01_e2014-12-31_c2015-08-27.sav'
model_params = get_model_params()
wav1a = 200 & wav1b = 210
wav2a = 300 & wav2b = 400
wav3a = 700 & wav3b = 1000
wav4a = 1000 & wav4b = 1300
k = n_elements(data.contrast.mjd)

ssifac = data.contrast.ssifac
ssifac_nocorr = data.contrast.ssifac_nocorr

ssispot = data.contrast.ssispot
ssispot_nocorr = data.contrast.ssispot_nocorr

bin_fac_1 = dblarr(k) ;200-210 nm
bin_fac_2 = dblarr(k) ;300-400 nm
bin_fac_3 = dblarr(k) ;700-1000 nm
bin_fac_4 = dblarr(k) ;1000-1300 nm

bin_fac_nocorr_1 = dblarr(k) ;200-210 nm
bin_fac_nocorr_2 = dblarr(k) ;300-400 nm
bin_fac_nocorr_3 = dblarr(k) ;700-1000 nm
bin_fac_nocorr_4 = dblarr(k) ;1000-1300 nm

bin_spot_1 = dblarr(k) ;200-210 nm
bin_spot_2 = dblarr(k) ;300-400 nm
bin_spot_3 = dblarr(k) ;700-1000 nm
bin_spot_4 = dblarr(k) ;1000-1300 nm

bin_spot_nocorr_1 = dblarr(k) ;200-210 nm
bin_spot_nocorr_2 = dblarr(k) ;300-400 nm
bin_spot_nocorr_3= dblarr(k) ;700-1000 nm
bin_spot_nocorr_4 = dblarr(k) ;1000-1300 nm

bin_1 =where((model_params.lambda ge wav1a) and (model_params.lambda lt wav1b),cntwav)
bin_2 = where((model_params.lambda ge wav2a) and (model_params.lambda lt wav2b),cntwav)
bin_3 = where((model_params.lambda ge wav3a) and (model_params.lambda lt wav3b),cntwav)
bin_4 = where((model_params.lambda ge wav4a) and (model_params.lambda lt wav4b),cntwav)

for j=0,k-1 do begin
  bin_fac_1[j] = total(ssifac[bin_1,j])
  bin_fac_2[j] = total(ssifac[bin_2,j])
  bin_fac_3[j] = total(ssifac[bin_3,j])
  bin_fac_4[j] = total(ssifac[bin_4,j])
  
  bin_fac_nocorr_1[j] = total(ssifac_nocorr[bin_1,j])
  bin_fac_nocorr_2[j] = total(ssifac_nocorr[bin_2,j])
  bin_fac_nocorr_3[j] = total(ssifac_nocorr[bin_3,j])
  bin_fac_nocorr_4[j] = total(ssifac_nocorr[bin_4,j])
  
  bin_spot_1[j] = total(ssispot[bin_1,j])
  bin_spot_2[j] = total(ssispot[bin_2,j])
  bin_spot_3[j] = total(ssispot[bin_3,j])
  bin_spot_4[j] = total(ssispot[bin_4,j])

  bin_spot_nocorr_1[j] = total(ssispot_nocorr[bin_1,j])
  bin_spot_nocorr_2[j] = total(ssispot_nocorr[bin_2,j])
  bin_spot_nocorr_3[j] = total(ssispot_nocorr[bin_3,j])
  bin_spot_nocorr_4[j] = total(ssispot_nocorr[bin_4,j])  
  
endfor

;facular contributions
p=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_1,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,1],color='deep pink')
p2=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_1 - bin_fac_nocorr_1,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,1],color='deep pink',linestyle=3,overplot=1)
p4=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_2,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,2],color='deep pink',/current)
p6=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_2 - bin_fac_nocorr_2,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,2],color='deep pink',linestyle=3,overplot=1)
p8=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_3,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,3],color='deep pink',/current)
p10=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_3 - bin_fac_nocorr_3,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,3],color='deep pink',linestyle=3,overplot=1)
p12=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_4,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,4],color='deep pink',/current)
p14=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_fac_4 - bin_fac_nocorr_4,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,4],color='deep pink',linestyle=3,overplot=1)

;spot contributions
p1=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_1,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,1],color='dodger blue')
p3=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_1 - bin_spot_nocorr_1,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,1],color='dodger blue',linestyle=3,overplot=1)
p5=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_2,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,2],color='dodger blue',/current)
p7=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_2 - bin_spot_nocorr_2,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,2],color='dodger blue',linestyle=3,overplot=1)
p9=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_3,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,3],color='dodger blue',/current)
p11=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_3 - bin_spot_nocorr_3,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,3],color='dodger blue',linestyle=3,overplot=1)
p13=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_4,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,4],color='dodger blue',/current)
p15=plot(jd2yf4(mjd2jd(data.contrast.mjd)),bin_spot_4 - bin_spot_nocorr_4,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,4],color='dodger blue',linestyle=3,overplot=1)

;facular contributions (in percentages)
p=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_fac_nocorr_1/bin_fac_1))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,1],color='deep pink',title='Contributions due to correction factor (%)')
p4=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_fac_nocorr_2/bin_fac_2))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,2],color='deep pink',/current)
p8=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_fac_nocorr_3/bin_fac_3))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,3],color='deep pink',/current)
p12=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_fac_nocorr_4/bin_fac_4))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,4],color='deep pink',/current)

;spot contributions (in percentages)
p1=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_spot_nocorr_1/bin_spot_1))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,1],color='dodger blue')
p5=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_spot_nocorr_2/bin_spot_2))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,2],color='dodger blue',/current)
p9=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_spot_nocorr_3/bin_spot_3))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,3],color='dodger blue',/current)
p13=plot(jd2yf4(mjd2jd(data.contrast.mjd)),(1-(bin_spot_nocorr_4/bin_spot_4))*100,margin=[.2,.15,.2,.15],font_size=16,axis_style=1,layout=[1,4,4],color='dodger blue',/current)

;p.save,'/Users/hofmann/git/nrlssi/docs/BAMS_figures/fig3.eps';, /TRANSPARENT
;end of Figure 3------------------------------


;p4=plot((1-result.contrast.ssifactot_nocorr/result.contrast.ssifactot)*100)
;p5=plot((1-result.contrast.ssispottot_nocorr/result.contrast.ssispottot)*100)

end ;pro  