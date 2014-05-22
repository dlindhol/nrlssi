function get_uv_model_params
  ;  retrieve the UARS UV model parameters
  ;
  psuvfactor=1.31284
  ; this converts from bolometric to UV sunspot blocking
  csecft=double([-1912.,7508.])
  ; this converts from MgSEC scale to FT scale
  ;
  ; restore model coefficients for calcuating UV spectrum from save files
  fn='data/MOD4_SOL_V0009_w1.sav'
  restore,filename=fn
  ;
  uvwl=wl   ; rename the UV wavelength grid to avoid confusion
;                  with longer wavelength array - established later
; in these save files have ...
;  wl,inst,instrument,ver,sdlim,weight,
;  cuvfpxps,cuvfpxpsd,scontrast,uvfregress,uvfregressd,
;  refuvf,refps,refpx,quvf,qps,qpx,coefres,coefresd
;
; NOTE that refpx in this sav file is on the MgSEC scale
;
; E.G.  uvfregress(10,311)      ; regression coeffs with px and ps
; in the above array the elements are for the following data from REGRESS:
; 0= a0
; 1= coef for px
; 2= coef for UVps
; 3= standard dev for pxindex coef
; 4= standard dev for ps coef
; 5= ftest
; 6= correlation coeff for pxindex
; 7= correlation coeff for UVps
; 8= multiple regression correlation coeff
; 9= chisq
;
; the reconstructed irradiances are determined from the
; detrended multiple regression analysis ...
;
; the UV spectrum reconsructed for given px and ps inpouts is..
; rcuv=dblarr(311)
; ee=1+uvfregressd(0,wl)+uvfregressd(1,wl)*(px-refpx)/refpx+$
;                 uvfregressd(2,wl)*(psuv-refps)/refps
; rcuv(wl)=refuvf(wl)*ee/100.
;
;NOTE: psuv=ps*psuvfactor
;

  params = {uv_model_params, $
    psuvfactor:  psuvfactor,  $
    csecft:      csecft,      $
    uvwl:        wl,          $
    uvfregressd: uvfregressd, $
    refuvf:      refuvf,      $
    refps:       refps,       $
    refpx:       refpx        $
  }
  
  return, params
  
end
