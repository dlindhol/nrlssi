;@***h* SOLAR_IRRADIANCE_FCDR/bin_ssi.pro
;
; NAME
;   bin_ssi.pro
;
; PURPOSE
;   The bin_ssi.pro function is called from the driver routine, nrl2_to_irradiance.pro.  It bins the Modeled
;   Solar Spectral Irradiance into the wavelength grid, defined in get_spectral_bins.pro.
;   The wavelength grid is as follows:
;   1 nm from 115 to 750
;   5 nm from 750 to 5000
;   10 nm from 5000 to 10000
;   50 nm from 10000 to 100000
;
; DESCRIPTION
;   The bin_ssi.pro function uses wavelength grid information (number of bands, bandcenters, and bandwidths),
;   and bins the Modeled Solar Spectral Irradiance onto the wavelength grid, defined by bandcenter and 
;   bandwidth. It outputs the binned irradiance to the main driver, nrl2_to_irradiance.pro.
;   
; INPUTS
;  
;   model_params  - a structure containing the wavelength information of the native modeled SSI:
;     lambda      - wavelength (nm; in 1-nm bins)
;   spectral_bins - a structure containing the wavelength grid information of the desired output SSI:
;     nband       - number of spectral bands, for a variable wavelength grid, that the NRL2 model bins 1 nm solar spectral irradiance onto.
;     bandcenter  - the bandcenters (nm) of the variable wavelength grid.
;     bandwidth   - the bandwidths (delta wavelength, nm)  of the variable wavelength grid. 
;   ssi           - a structure containing the modeled SSI:
;     nrl2        - the NRL2 modeled Solar Spectral Irradiance at 1 nm spectral resolution
;          
; OUTPUTS
;   ssi_bin      - a structure containing the following variables:
;     nrl2bin    - the binned NRL2 modeled Solar Spectral Irradiance, on a variable wavelength grid
;     nrl2binsum - the sum of the binned irradiance (equal to nrl2bin * bandwidth).  
;     
; AUTHOR
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Doug Lindholm, Laboratory for Atmospheric and Space Physics, Boulder, CO
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
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
;   01/14/2015 Initial Version prepared for NCDC
;
; USAGE
;   bin_ssi, model_params, spectral_bins, ssi
;
;@*****
function bin_ssi, model_params, spectral_bins, ssi

  lambda     = model_params.lambda
  nband      = spectral_bins.nband
  bandcenter = spectral_bins.bandcenter
  bandwidth  = spectral_bins.bandwidth
  nrl2spec   = ssi.nrl2
  nrl2unc    = ssi.nrl2unc

  nrl2bin    = dblarr(nband) ; Binned wavelength grid   
  nrl2binunc = dblarr(nband) ;Binned uncertainties

  ; Sum spectrum into wavelength bands
  for m=0,nband-1 do begin
    wav1=bandcenter(m)-bandwidth(m)/2.
    wav2=bandcenter(m)+bandwidth(m)/2.
    rwav=where((lambda ge wav1) and (lambda lt wav2),cntwav)
    nrl2bin(m)=total(nrl2spec(rwav), /double)/(wav2-wav1)
    nrl2binunc(m)=total(nrl2spec(rwav)*nrl2unc(rwav),/double)/total(nrl2spec(rwav),/double)
  endfor
    
  nrl2binsum=total(nrl2bin*bandwidth)

  ssi_bin = {nrl2_ssi_bin,    $
    nrl2bin:     nrl2bin,    $
    nrl2binunc:  nrl2binunc, $
    nrl2binsum:  nrl2binsum  $
  }
  
  return,ssi_bin
end