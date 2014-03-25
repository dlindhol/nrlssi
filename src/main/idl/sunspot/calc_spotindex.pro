pro calc_spotindex, year
  ;TODO: time range args, not just years
  ;TODO: optional station arg to limit to one station, or array?
  ;stations = List('LEAR','CULG','SVTO','RAMY','BOUL','MWIL','HOLL','PALE','MANI','ATHN')
  ;if stations not defined, use whatever is in the data

  ver='Doug_v1'
  
  ;Get sunspot data from the NGCD data file.
  ;Array of structures, one element per line.
  ;  struct = {jd:0.0, lat:0.0, lon:0.0, area:0.0, station:''}
  ;  index -> (jd, lat, lon, area, station)
  sunspot_data = get_sunspot_data(year)
  
  ;Group by Julian Day number
  ; jdn -> (jd, lat, lon, area, station)
  daily_sunspot_data = group_by_day(sunspot_data)
  
  ;Define start and stop times.
  ;Use noon so JD will be a whole number and 'round' to make it so.
  ;TODO: test: handling leap year, .5 day offset, binning bu utc day
  jd_start = round(julday(1, 1, year, 12))
  jd_stop  = round(julday(12, 31, year, 12))
  
  ;Define Hash to hold results with JDN as key.
  sunspot_blocking_data = Hash()
  
  ;Define struct to hold daily ssb results
  ;TODO: put in define file?
  ssb_struct = {sunspot_blocking,  $
    jdn:0,                 $
    ssbt:0.0, dssbt:0.0,   $
    ssbuv:0.0, dssbuv:0.0  $
  }
  
  ;Iterate over days.
  for jdn = jd_start, jd_stop do begin
    if daily_sunspot_data.hasKey(jdn) then begin
      ;Get the sunspot data for this day
      ssdata = daily_sunspot_data[jdn]
      ; (jd, lat, lon, area, station)
      
      ;Compute the daily accumulated ssb for each station.
      ;  station -> ssb
      ;TODO: optional stations list
      ssbt_by_station = get_ssb_by_station(ssdata)
      ssbuv_by_station = get_ssb_by_station(ssdata, /uv)
      
      ;Average the results from each station
      ;TODO: consider missing data (NaN?), 0 or 1 sample      
      ssb_struct.jdn    = jdn
      ssb_struct.ssbt   = mean(ssbt_by_station.values)
      ssb_struct.dssbt  = stddev(ssbt_by_station.values)
      ssb_struct.ssbuv  = mean(ssbuv_by_station.values)
      ssb_struct.dssbuv = stddev(ssbuv_by_station.values)
      
      ;Add structure to result hash for this day.
      sunspot_blocking_data[jdn] = ssb_struct
  
    endif else begin
;TODO: no data for this day, fill value? final output has -999
    endelse
    
  endfor
  
  ;Write the results.
  write_sunspot_blocking_data(sunspot_blocking_data)
  
end
  

;--------------------------------------------------------------    
;    ;	*****  NOTES **************
;    ;	Calculates the sunspot blocking function for
;    ;	each of 8 individual stations
;    ;	area is in units of the solar hemisphere (not disc) -
;    ;	i.e., WDC area/1E6
;    ;
;    ; use variable contrast with area - cf Brandt et al
;    ;
;    ;	**** NOTE: B0 angle adjustment is included
;    ; this is a generic sun-earth distance with the value for 29 FEB equal
;    ; to the value for 28 FEB
;    ;
;
;
;
;    ;     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;    ;
;    ;     CALCULATE THE SUNSPOT BLOCKING FUNCTION FOR EACH OF THE EIGHT STATIONS
;    ;	ON EACH DAY, THEN AVERAGE
;    ;
;    for i=0,ndays-1 do begin
;      num=numobs(i)
;      if(num eq 0) then goto, cont611
;      ;
;      ; cycle through all the daily valid observations, sorting into the eight
;      ; stations
;      for n=0,num-1 do begin
;        ; print for checking e.e.g. duplicate record
;        ; if(idate(i) eq 861221) then $
;        ;    print,idate(i),n,istn(n,i),amu(n,i),area(n,i),group(n,i)
;        for k=0,9 do begin
;          if(istn(n,i) ne nserial(k)) then goto, cont601
;          ;	check for duplicate data from an individual station
;          idupl=0
;          for m=0,num-1 do begin
;            if(istn(m,i) ne nserial(k)) then goto, cont603
;            if(amu(m,i) ne amu(n,i)) then goto, cont603
;            if(area(m,i) ne area(n,i)) then goto, cont603
;            if(group(m,i) ne group(n,i)) then goto, cont603
;            idupl=idupl+1
;            ;	   set duplicate data to -888 (i.e., no data) IF M NE N
;            if(m ne n) then area(m,i)=-888.0
;            cont603:
;          endfor
;          if(idupl ge 2) then print,' idupl=',idupl
;          if(idupl ge 2) then print,idate(i),n,istn(n,i),amu(n,i),area(n,i),group(n,i)
;          ;
;          ;
;          ; *** CALCULATE SUNSPOT BLOCKING HERE ***
;          ; bypass duplicate record
;          if(area(n,i) eq -888.) then goto,cont601
;          ; bolometric:
;          sb=amu(n,i)*(3*amu(n,i)+2)/2.*area(n,i)*(0.2231+0.0244*alog10(area(n,i)))
;          ; print for checking ...861221 has duplicate record
;          ; if(idate(i) eq 861221) then print,i,n,amu(n,i),area(n,i),sb
;          ssblock(k,i)=ssblock(k,i)+sb
;          ; UV at 320 nm:
;          ctl=1.-cl320(0)-cl320(1)+cl320(0)*amu(n,i)+cl320(1)*amu(n,i)*amu(n,i)
;          sbuv=5.0*amu(n,i)*ctl/2.*area(n,i)*(0.2231+0.0244*alog10(area(n,i)))
;          ssbuv(k,i)=ssbuv(k,i)+sbuv*excess320/excess
;          cont601:
;        endfor ;k loop over stations
;      endfor ;n loop over obs
;      goto,cont612
;      ;
;      cont611:
;      ; set to -1 for no observations
;      ssblock(0:9,i)=-1
;      ssbuv(0:9,i)=-1
;      ;
;      cont612:
;      fmt677='(I8,10F10.2)'
;      ; NOTE: hemispheric data will be equal to -1 for no observation and zero for
;      ; no measured sunspots
;      ; print,format=fmt677,IDATE(I),SSBLOCK(0,I),SSBLOCK(1,I),SSBLOCK(2,I),$
;      ;     	SSBLOCK(3,I),SSBLOCK(4,I),SSBLOCK(5,I),SSBLOCK(6,I),SSBLOCK(7,I)$
;      ;     	,SSBLOCK(8,I),SSBLOCK(9,I)
;      ;
;      ;	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;      ;	calculate mean values for SSBLOCK, SSBUV for this day
;      ; sdlim = factor for rejecting data (> sdlim * stdev from avssb)
;      sdlim=4  ;not used, bypassed by goto,contt
;      ;
;      ; use total sunspot blocking data  - UV will follow proportionally
;      allt=ssblock(*,i)
;      allu=ssbuv(*,i)
;      r=where(allt gt 0,cnt)
;      if(cnt gt 1.) then resultt=moment(allt(r),sdev=stdt)
;      if(cnt gt 1.) then resultu=moment(allu(r),sdev=stdu)
;      ;
;      if(cnt le 1.) then stdevt(i)=-999 else stdevt(i)=stdt
;      
;      if(cnt eq 0.) then avssbt(i)=-999 $
;      else if(cnt eq 1) then avssbt(i)=allt(r) $
;      else if(cnt gt 1) then avssbt(i)=resultt(0)
;      
;      if(cnt le 1.) then stdevu(i)=-999 else stdevu(i)=stdu
;      
;      if(cnt eq 0.) then avssbu(i)=-999 $
;      else if(cnt eq 1) then avssbu(i)=allu(r) $
;      else if(cnt gt 1) then avssbu(i)=resultu(0)
;      ;
;      ;---------------------------------------------------------------------------
;      ; for the jan97.rev files bypass this bit here
;      ; had tried to include this is the jan96 version but made a mistake anyway---
;      ; and jan96 and jan97 versions are almost identical
;      goto,contt
;      ;
;      ; check for major outliers
;      ; recalculate average by throwing out outliers
;      if(cnt ge 4.) then $
;        ;  NOTE - error here was use of stdevt instead of stdevt(i) but not sure
;        ; what difference this made ... so reado without throwing out any data
;        ; ****   r=where((allt gt 0) and (abs(allt-avt) le stdevt*sdlim),cnt) ***
;        ;
;        r=where((allt gt 0) and (abs(allt-avt) le stdevt(i)*sdlim),cnt)
;      ; reset the average  and stdev according to the new count
;      if(cnt ge 3.) then begin
;        resultt=moment(allt(r),sdev=sdtt)
;        resultu=moment(allu(r),sdev=sdtu)
;        stdevt(i)=sdtt
;        avssbt(i)=resultt(0)
;        stdevu(i)=stdu
;        avssbu(i)=resultu(0)
;      end
;      ;
;      contt:
;      fmt678='(I12,4F10.2)'
;      printf,8,format=fmt678,IDATE(I),AVSSBT(i),STDEVT(i),AVSSBU(i),STDEVU(i)
;    ;print,format=fmt678,IDATE(I),AVSSBT(i),STDEVT(i),AVSSBU(i),STDEVU(i)
;    ;
;    ; end of all days for the year
;    endfor
;    print,'  Sunspot blocking function for YEAR=',iyear
;    ;
;    close,1,8
;  endfor
;  ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;  cont100:
;end


