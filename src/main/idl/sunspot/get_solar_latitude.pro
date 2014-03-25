function get_solar_latitude, jd
;TODO: compute using JEAN MEEUS, ASTRONOMICAL ALGORITHMS
;/data_systems/tools/knapp/idl/astronomy/helios.pro
  helios, jd, carr, lat, lon, p, diam, dist
  return, lat

end

;  ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;;     READ IN THE (generic) SOLAR ORIENTATION
;; NOTE *** this is for a nominal year -  with 29 FEB = 28 FEB
;;
;close,5
;openr,5,'data/betasun.dat'
;beta=fltarr(366)
;betad=fltarr(366)
;;
;dumi='    '
;readf,5,dumi
;kl=0
;for ki=1,12 do begin
;readf,5,io,no
;;print,io,no
;  for kj=1,no do begin
;  readf,5,dumi
;  beta[kl]=dumi
;  betad[kl]=io+kj
;;
;; print here if required
; ; fmt2='("  KL=",I3,"  KI=",I3,"  KJ=",I3,"  BETAD=",F8.2,"  BETA=",F8.4)'
;;  print,format=fmt2,kl,ki,kj,betad(kl),beta(kl)
;  kl=kl+1
;  endfor
;endfor
;close,5
;;print,' Finished reading BETASUN with ',kl,' data points'
;
;
;
;
;; adjust for B0 
;; determine bsun for data from betad and beta arrays
;;
;; For a leap year, 29 Feb set equal to 28 Feb
;        LB=-1
;        IY=fix(date/10.^4)
;        DD=date-IY*10000.
;        cont30:
;      LB=LB+1
;        if(betad[lb] ne dd) then goto, cont30
;        bsun=beta[lb]
;
;  return, bsun
;
;end
