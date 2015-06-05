;@***h* SOLAR_IRRADIANCE_FCDR/get_spectral_bins.pro
;
; NAME
;   get_spectral_bins.pro
;
; PURPOSE
;   The get_spectral_bins.pro function is called from the routine, process_irradiance.pro.  It sets up wavelength bands for 
;   the output solar spectral irradiance.  The wavelength grid is as follows:
;   1 nm from 115 to 750
;   5 nm from 750 to 5000
;   10 nm from 5000 to 10000
;   50 nm from 10000 to 100000
;   The routine defines the bandcenters and bandwidths for the wavelength grid, and passes the variables back to the driver routine
;   in a structure, 'bins'.

; DESCRIPTION
;   The get_spectral_bins.pro function passes wavelength grid information (number of bands, bandcenters, and bandwidths) to the 
;   driver routine for later use in binning spectral irradiance data.
;   
; INPUTS
;  
; OUTPUTS
;   bins - a structure containing the following variables:
;     nband      = number of spectral bands, for a variable wavelength grid, that the NRLSSI2 model bins 1 nm solar spectral irradiance onto.
;     bandcenter = the bandcenters (nm) of the variable wavelength grid.
;     bandwidth  = the bandwidths (delta wavelength, nm)  of the variable wavelength grid, centered on bandcenter. 
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
;   06/04/2015 Initial Version prepared for NCDC
;
; USAGE
;   result=get_spectral_bins()
;
;@*****
function get_spectral_bins

  nband1=750-115
  nband2=(5000-750)/5
  nband3=(10000-5000)/10
  nband4=(100000-10000)/50
  nband=nband1+nband2+nband3+nband4
  bandcenter=dblarr(nband) 
  bandwidth=dblarr(nband)

  ; set up the wavelength bins
  for m=0,nband1-1 do begin
    wav1=115.+m
    wav2=wav1+1.
    bandcenter(m)=(wav1+wav2)/2.
    bandwidth(m)=wav2-wav1
    endfor
  for m=0,nband2-1 do begin
    wav1=750.+m*5.
    wav2=wav1+5.
    bandcenter(nband1+m)=(wav1+wav2)/2.
    bandwidth(nband1+m)=wav2-wav1
  endfor
  for m=0,nband3-1 do begin
    wav1=5000.+m*10.
    wav2=wav1+10.
    bandcenter(nband1+nband2+m)=(wav1+wav2)/2.
    bandwidth(nband1+nband2+m)=wav2-wav1
  endfor
  for m=0,nband4-1 do begin
    wav1=10000.+m*50.
    wav2=wav1+50.
    bandcenter(nband1+nband2+nband3+m)=(wav1+wav2)/2.
    bandwidth(nband1+nband2+nband3+m)=wav2-wav1
  endfor

  bins = {spectral_bins,    $
    nband:           nband, $
    bandcenter: bandcenter, $
    bandwidth:  bandwidth   $
  }
  
  return, bins
  
end