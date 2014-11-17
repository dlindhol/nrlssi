;@***h* SOLAR_IRRADIANCE_FCDR/nrl2_to_irradiance.pro
;
; NAME
;   nrl2_to_irradiance.pro
;
; PURPOSE
;   The nrl2_to_irradiance.pro procedure is the driver routine to compute daily Model Total Solar Irradiance and 
;   Solar Spectral Irradiance using the Judith Lean (Naval Research Laboratory) NRL2 model and write the output to NetCDF4 format.
;
; DESCRIPTION
;   The nrl2_to_irradiance.pro procedure is the main driver routine that computes the Model Total Solar Irradiance (TSI)
;   and Solar Spectral Irradiance (SSI) using the 2-component regression formulas described below and the variables as defined. Required 
;   input data is the time-dependent facular brightening and sunspot darkening functions that are derived from independent solar
;   observations made approximately daily, respectively, the Mg II index of global facular emission and the areas and locations of 
;   sunspot active regions on the solar disk.
; 
;   Variable Definitions:
;   T(t) is the time-dependency (t) of TSI,
;   I(k,t) it the spectral (k) and time-dependency (t) of SSI.
;   delta_T_F(t) is the time dependency of the delta change to TSI from the facular brightening index, F(t)
;   delta_I_F(k,t) is similarly described, but for SSI, and is also spectrally dependent 
;   delta_T_S(t) is the time dependency of the delta change to TSI from the sunspot darkening index, S(t)
;   delta_I_S(t) is similarly described, but for SSI, and is also spectrally dependent
;   
;   2-Component Regression formulas: 
;   T(t) = T_Q + delta_T_F(t) + delta_T_S(t)
;   I(k,t) = I_Q + delta_I_F(t) + delta_I_S(t)
;
;   Quantifying time-dependent TSI (T) Irradiance Variations from Faculae (F) and Sunspots (S):
;   delta_T_F(t) = a_F + b_F * [F(t) - F_Q]
;   delta_T_S(t) = a_S + b_S * [S(t) - S_Q]
;   F_Q and S_Q (=0) are the values of the facular brightening and sunspot darkening indices corresponding to T_Q 
;   (i.e. for the quiet Sun). 
;   
;   Quantifying time and spectrally-dependent SSI (I) Irradiance variation from Faculae (F) and Sunspot (S):
;   delta_I_F(k,t) = c_F(k) + d_F(k) * [F(t) - F_Q] + e_F * [F(t) - F_Q]
;   delta_I_S(k,t) = c_S(k) + d_S(k) * [S(t) - S_Q] + e_S * [S(t) - S_Q]
;   
;   Coefficients for faculae and sunspots:
;   The a, b, c(k), and d(k) coefficients for faculae and sunspots are specified (determined using multiple linear regression) 
;   and supplied with the algorithm. These coefficients best reproduce the TSI irradiance variability  measured directly by 
;   SORCE TIM from 2003 to 2014 and detrended SSI irradiance variability (removal of 81-day running mean) measured by SORCE SIM. 
;   Note, the a and c coefficients are nominally zero so that when F=F_Q and S=S_Q, then T=T_Q and I=I_Q.
;   The additional wavelength-dependent terms in the spectral irradiance facular and sunspot components evaluated with the 
;   e coefficients provide small adjustments to ensure that 1) the numerical integral over wavelength of the solar spectral irradiance is 
;   equal to the total solar irradiance, 2) the numerical integral over wavelength of the time-dependent SSI irradiance variations from
;   faculae and sunspots is equal to the time-dependent TSI irradiance variations from the faculae and sunspots. 
;   
;   Additional explanation of coefficients used to model solar spectral irradiance: 
;   A relationship of solar spectral irradiance variability to sunspot darkening and facular brightening determined using observations of 
;   solar rotational modulation: instrumental trends are smaller over the (much) shorter rotational times scales than during the solar cycle. 
;   For each 1 nm bin, the observed spectral irradiance and the facular brightening and sunspot darkening indices are detrended by 
;   subtracting 81-day running means. Multiple linear regression is then used to determine the relationships of the detrended time series:
;   
;   I_detrend_mod(k,t) = I_mod(k,t) - I_smooth(k,t)
;                      = c(k) + d_F_detrend(k) * [F(t) - F_smooth(t)] + d_S_detrend(k) * [S(t) - S_smooth(t)]
;                      
;   Variable Definitions:
;   I_mod(k,t) = the spectral (k) and time (t) dependecies of the modeled spectral irradiance, I_mod.
;   I_smooth(k,t) = the spectral and time dependences of the smoothed (i.e. after subtracting 81-day running mean) from observed spectral irradiance.
;   F_smooth(t) = the time dependency of the smoothed (i.e. after subtracting 81-day running mean) from observed facular brightening index, F(t).
;   S_smooth(t) = as above, but for the observed sunspot darkening index, S(t).
;   
;   The range of facular variability in the detrended time series is smaller than during the solar cycle which causes the coefficients
;   of models developed from detrended time series to differ from those developed from non-detrended observations. To address this, total
;   solar irradiance observations are used to numerically determine ratios of coefficients obtained from multiple regression using direct observations,
;   with those obtained from multiple regression of detrended observations. Using a second model of TIM observations (using detrended observations) 
;   was determined and the ratios of the coefficients for the two approaches were used to adjust the coefficients for spectral irradiance variations.
;   
;   For wavelengths > 295 nm, where both sunspots and faculae modulate spectral and total irradiance, 
;   the d coefficients, d_F and d_S are estimated as:
;   d_F(k) = d_F_detrend(k) * [b_F / b_F_detrend]
;   d_S(k) = d_S_detrend(k) * [b_S / b_S_detrend]
;   
;   For wavelengths < 295 nm, where faculae dominate irradiance variability (d_S(k) ~ 0), the adjustments for 
;   the coefficients are estimated using the Ca K time series, a facular index independent of Mg II index, and a proxy for UV
;   spectral irradiance variability.
;   
;   Reference(s):
;   Reference describing the solar irradiance variability due to linear combinations of sunspot darkening
;   and facular brightening: 
;      Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends
;      and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998.
;   References describing the original NRLTSI and NRLSSI models are:
;      Lean, J., Evolution of the Sun's Spectral Irradiance Since the Maunder Minimum, Geophys. Res. Lett., 27, 2425-2428, 2000.
;      Lean, J., G. Rottman, J. Harder, and G. Kopp, SORCE Contributions to New Understanding of Global Change and Solar Variability,
;      Solar. Phys., 230, 27-53, 2005.
;      Lean, J. L., and T.N. Woods, Solar Total and Spectral Irradiance Measurements and Models: A Users Guide,
;      in Evolving Solar Physics and the Climates of Earth and Space, Karel Schrijver and George Siscoe (Eds), Cambridge Univ. Press, 2010.
;   Reference describing the extension of the model to include the extreme ultraviolet spectrum and the empirical capability to specify 
;   entire solar spectral irradiance and its variability from 1 to 100,000 nm:
;      Lean, J. L., T. N. Woods, F. G. Eparvier, R. R. Meier, D. J. Strickland, J. T. Correira, and J. S. Evans,
;      Solar Extreme Ultraviolet Irradiance: Present, Past, and Future, J. Geophys. Res., 116, A001102, 
;      doi:10.1029/2010JA015901, 2011.
;      
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, of the form 'yyyy-mm-dd'
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), of the form 'yyyy-mm-dd'.
;   output_dir - path to desired output directory. If left blank, the output file is placed in the current working directory with the 
;                default title of 'nrl2_YMD1_YMD2_VER.sav'; using the time ranges above and a hard-coded "version" number.
;
; OUTPUTS
;   outfile - user provided output filename (default filename is 'nrl_tsi.nc') that contains a data structure of
;   Modeled Total Solar Irradiance ('tsi'), 'year', day of year ('doy'), and 'day_number'
;   (cumulative day number since Jan. 1, 1978) in netCDF4 format.
;
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
;
; COPYRIGHT
;   THIS SOFTWARE AND ITS DOCUMENTATION ARE CONSIDERED TO BE IN THE PUBLIC
;   DOMAIN AND THUS ARE AVAILABLE FOR UNRESTRICTED PUBLIC USE. THEY ARE
;   FURNISHED "AS IS." THE AUTHORS, THE UNITED STATES GOVERNMENT, ITS
;   INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO WARRANTY,
;   EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE AND
;   DOCUMENTATION FOR ANY PURPOSE. THEY ASSUME NO RESPONSIBILITY (1) FOR
;   THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL
;   SUPPORT TO USERS.
;
; REVISION HISTORY
;   08/22/2014 Initial Version prepared for NCDC
;
; USAGE
;   nrl2_to_irradiance, ymd1, ymd2,output_dir=output_dir
;
;@*****

function nrl2_to_irradiance, ymd1, ymd2, output_dir=output_dir

  algver = 'V001' ; get from function parameter?
  algrev = 'R00' ; get from function parameter?
  modver='8Sep14'
  fn='~/git/nrlssi/data/judith_2014_09_08/NRL2_model_parameters20_'+modver+'.sav'
  ;TODO: get this from function parameter?
 
  ;Creation date, used for output files (TO DO: change to form DDMMMYY, ex., 09Sep14, but saved under alternative variable name as .nc4 metadata requires this info as well in ISO 8601 form..) 
  ymd3 = jd2iso_date(systime(/julian, /utc)) 
   
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
  sunspot_blocking = get_sunspot_blocking(ymd1, ymd2) ;sunspot blocking data
  mg_index = get_mg_index(ymd1, ymd2) ;MgII index data
  
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
    mg = mg_index_by_day[mjd].index
    
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
    struct = {nrl2,                $
      mjd:    mjd,                 $
      iso:    iso_time,            $
      tsi:    nrl2_tsi.totirrad,   $
      ssi:    nrl2_ssi.nrl2bin,    $
      ssitot: nrl2_ssi.nrl2binsum  $
    }
    
    data_list.add, struct
  endfor
  
  ;Convert data List to array
  data = data_list.toArray()
  
  ;Make output file name(s), dynamically
  creation_date = iso_date2ddMonyy(ymd3)
  ;ToDO, create monthly and annually averaged filenames, for monthly file, ymd1, ymd2 ->ym1, and ym2, and for annual file, ymd1 and ymd2 ->y1,y2
  ;ToDo, use an optional keyword parameter to define whether daily, monthly-averaged, or yearly-averaged output is desired?
  tsifile_daily = 'tsi_' + algver +'_'+ algrev +'_'+'day_'+ymd1 +'_'+ ymd2 +'_'+ creation_date +'.nc' 
  ssifile_daily = 'ssi_' + algver +'_'+ algrev +'_'+'day_'+ymd1 +'_'+ ymd2 +'_'+ creation_date +'.nc' 
  
  ;Write the results to output in netCDF4 format; To Do: include an output file directory
  result = write_tsi_model_to_netcdf2(ymd1,ymd2,ymd3,algver,data,tsifile_daily)
  result = write_ssi_model_to_netcdf2(ymd1,ymd2,ymd3,algver,data,spectral_bins,ssifile_daily)
 
  ;Example, convert modified julian date to iso string
  ;print, mjd2iso_date(data[0].mjd)
  
  ;Example, plot spectral irradiance
  ;plot,spectral_bins[0].bandcenter,data[0].ssi,/xlog
  
  ;QA output
  ;print,data[0].tsi,data[0].ssitot
  
  ;Write the results if output_dir is specified
  ;TODO: Consider writing each time sample as we compute it. Data may be too large for memory?
  ;if n_elements(output_dir) eq 1 then begin
  ;  file = output_dir + '/nrl2_' + ymd1 +'_'+ ymd2 +'_'+ modver +'.sav'
  ;  save, file=file, data
  ;  ;TODO: status = write_nrl2_data(data, file)
  ;endif
  
  return, data
end

