;QA sunspot data.
;look for missing days (identified by quality flag = 1) in sunspot_blocking data structure
;The quality flag is based on the MISSING_AREA_BITS AND DUPLOCATE BITS as: 
;sunspot_blocking_data[i].quality_flag = MISSING_AREA_BIT + 2 * DUPLICATE_BIT
;the missing area data will have a value of 0. by default

function interpolate_sunspot_blocking, sunspotblocking, missing, dev=dev
 
    print,'WARNING: Interpolating over missing sunspot area '
    INTERPOLATE_BIT = 1
    tmp = sunspotblocking.ssbt ;save data in 'tmp' variable
    tmp_missing=replace_missing_with_nan(tmp[missing], 0.) ;assign missing data (0) in 'tmp' with NaN in new variable'tmp_missing'
    tmp[missing] = tmp_missing ; replace missing data in 'tmp' varibale with the NaN from 'tmp_missing'
    
    interp_ssbt=interpol(tmp,sunspotblocking.mjdn,sunspotblocking.mjdn,/NaN) ;linear interpolate over missing days    
   
    tmp_qflag = sunspotblocking.quality_flag
    tmp_qflag[missing] = tmp_qflag[missing] + 3 * INTERPOLATE_BIT ;did I do this right for new qa flag?
    
    int_sunspot_blocking = {int_sunspot_blocking,  $
      mjdn: sunspotblocking.mjdn, $
      ssbt: interp_ssbt, $
      dssbt: sunspotblocking.dssbt, $
      quality_flag: tmp_qflag $
    }
    
    return, int_sunspot_blocking 

end 