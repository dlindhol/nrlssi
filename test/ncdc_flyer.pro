;open .nc file
cdfid = ncdf_open('tsi_v02r00_daily_s19800101_e20141231_c20150316.nc',/nowrite)
ivaridt = ncdf_varid(cdfid,'TSI')
ncdf_varget,cdfid,ivaridt,nrl_tsi
ivaridt = ncdf_varid(cdfid,'time')
ncdf_varget,cdfid,ivaridt,nrl_date
day_zero_mjd = iso_date2mjdn('1610-01-01')
nrl_date = nrl_date + day_zero_mjd
nrl_date = jd2yf4(mjd2jd(nrl_date))

;TSI plot with overlying TIM data
;.r '/Users/hofmann/Downloads/TSIS pics/read_lasp_ascii.pro'
tim=read_lasp_ascii_file('/Users/hofmann/Downloads/TSIS pics/sorce_tsi_L3_c24h_latest.webarchive')
tim_time=jd2yf4(tim.nominal_date_jdn)
tim_tsi = tim.tsi_1au
p=plot(nrl_date,nrl_tsi,ytitle='W m!U-2!N',font_size=20,axis_style=0,margin=[0.1,0.1,.2,.1],'.',color='navy',sym_size=3)
p1=plot(tim_time,tim_tsi,'.',color='light sky blue',overplot=1,axis_style=0,sym_size=3)
p.yrange=[1356,1364]
p.xrange=[1995,2015]
xaxis = axis('X',location=[0,1356])
yaxis = axis('Y',location=[2015,1356],title='W m!U-2!N',textpos=1)
p.font_size=20
p.xtickfont_style=1
p.ytickfont_style=1
;p.Save, '/Users/hofmann/Downloads/TSIS pics/mytsiplot.eps', /TRANSPARENT

;SSI plot
;open .nc file
cdfid = ncdf_open('ssi_v02r00_daily_s19950101_e20141231_c20150312.nc',/nowrite)
ivaridt = ncdf_varid(cdfid,'SSI')
ncdf_varget,cdfid,ivaridt,nrl_ssi
ivaridt = ncdf_varid(cdfid,'time')
ncdf_varget,cdfid,ivaridt,nrl_date
day_zero_mjd = iso_date2mjdn('1610-01-01')
nrl_date = nrl_date + day_zero_mjd
nrl_date = jd2yf4(mjd2jd(nrl_date))
ivaridt=ncdf_varid(cdfid,'wavelength')
ncdf_varget,cdfid,ivaridt,wavelength
ivaridt=ncdf_varid(cdfid,'Wavelength_Band_Width')
ncdf_varget,cdfid,ivaridt,bandwidth

p2=plot(wavelength,nrl_ssi[*,3200],xtitle='Wavelength (nm)',thick=2,xrange=[100,10000],font_size=18,margin=[.2,.15,.1,.1],axis_style=0)
xaxis=axis('X',location=[100,0],title='Wavelength (nm)')
yaxis=axis('Y',location=[100,0],target=p2,title='W m!U-2!N nm!U-1!N')
p2.xtickfont_style=1
p2.ytickfont_style=1
p2.xlog=1
p2.font_size=20
p2.fill_background=1
p2.fill_color='light steel blue' ;'light blue'
p2.save,'/Users/hofmann/Downloads/TSIS pics/myssiplot.eps';, /TRANSPARENT

;try a "spectrum" color fill
;p6 = plot(wavelength
;SSI time series
;Bin ssi into broad spectral bins
wav1a = 200 & wav1b = 400
wav2a = 400 & wav2b = 700
wav3a = 700 & wav3b = 1000
k=7305 ;number of elements in the extracted time periods 1995-2014
nrl_uv = dblarr(k) ;200-400 nm
nrl_vis = dblarr(k) ;400-700 nm
nrl_nir = dblarr(k) ;700-1000 nm

bin_uv =where((wavelength ge wav1a) and (wavelength lt wav1b),cntwav)
bin_vis= where((wavelength ge wav2a) and (wavelength lt wav2b),cntwav)
bin_nir = where((wavelength ge wav3a) and (wavelength lt wav3b),cntwav)

for j=0,k-1 do begin
 nrl_uv[j] = total(nrl_ssi[bin_uv,j]*bandwidth(bin_uv),/double)
 nrl_vis[j] = total(nrl_ssi(bin_vis,j)*bandwidth(bin_vis),/double)
 nrl_nir[j] = total(nrl_ssi(bin_nir,j)*bandwidth(bin_nir),/double)
endfor

p3=plot(nrl_date,nrl_uv,margin=[0.2,0.15,.1,.1],'.',color='dark_blue',layout=[1,3,1],name='Ultraviolet',font_size=18,axis_style=0)
;xaxis = axis('X',location=[0,106.8])
y3axis = axis('Y',location=[1995,106.8],textpos=0,tickinterval=0.5);title='W m!U-2!N'
;l=legend(target=[p3],/data)
p4=plot(nrl_date,nrl_vis,margin=[0.2,.15,.1,.1],'.',color='green',layout=[1,3,2],/current,name='Visible',font_size=18,axis_style=0)
;xaxis = axis('X',location=[0,528])
y4axis = axis('Y',location=[1995,528],textpos=0,tickinterval=1.5,title='W m!U-2!N',target=p4)
p5=plot(nrl_date,nrl_nir,margin=[0.2,.15,.1,.1],'.',color='red',layout=[1,3,3],/current,name='Near-infrared',font_size=18,axis_style=0)
xaxis = axis('X',location=[0,304.8],target=p5)
y5axis = axis('Y',location=[1995,304.8],textpos=0,tickinterval=0.5,target=p5)
;p3.save,'/Users/hofmann/Downloads/TSIS pics/myssitimeplot.png', /TRANSPARENT
;stop
end