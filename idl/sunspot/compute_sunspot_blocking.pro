;@***h* SOLAR_IRRADIANCE_FCDR/compute_sunspot_blocking.pro
; 
; NAME
;   compute_sunspot_blocking.pro
;
; PURPOSE
;   The compute_sunspot_blocking.pro procedure computes the sunspot blocking function using a formula that weights the 
;   heliographic area of the sunspot group corrected by the solar latitude (corrected for ecliptic plane variation) and longitude.
;
; DESCRIPTION
;   The compute_sunspot_blocking.pro procedure computes the sunspot blocking function using a formula that weights the 
;   heliographic area of the sunspot group corrected by the solar latitude (corrected for ecliptic plane variation) and longitude.
;   The calculation effectively sums the projected area of sunspot regions on the solar hemisphere and multiplies this by the 
;   contrast of sunspots relative to the background (reference) Sun, taking into account variations with limb position on the solar disk.
;   [Lean, J.L., Cook, J., Marquette, W., and Johannesson, A.: 1998, Astrophys. J., 492, 390-401].
;   It also includes empirical corrections for the additional darkness of larger sunspot than smaller sunspots  
;   [Brandt, P, N., Stix, M., and Wdinhardt, H.: 1994, Solar Phys. 152 (119)]. 
;   
;   ;Formula (from Lean et al., 1998)
;   sunspot darkening = mu * (3*mu + 2)/2.0 * area * (0.2231 + 0.0244 * alog10(area)), where mu = cos(latitute) × cos(longitude) is the
;   cosine weighted area projection of sunspot area, and area = heliographic area of the sunspot group
;                                     
; INPUTS
;   area - heliographic area of the sunspot group
;   lat  - heliographic latitude of sunspot group, adjusted for the Bo angle of the Sun’s axis to the ecliptic plane
;   lon  - heliographic longitude of sunspot group
;   
; OUTPUTS
;   ssb - the sunspot darkening  
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
;   09/08/2014 Initial Version prepared for NCDC
; 
; USAGE
;   compute_sunspot_blocking,area,lat,lon
;
;@***** 
function compute_sunspot_blocking, area, lat, lon
  ;works with arrays
  
  mu = cos(lat*!pi/180.0) * cos(lon*!pi/180.0)
  
  ;Deal with zero area: blocking = 0
  ssb = dblarr(n_elements(area)) ;all 0s
  index = where(area ne 0.0, n)
  if n gt 0 then begin
    area = area[index]
    mu = mu[index]
  endif else index = dindgen(n_elements(area)) ;all indices
  
  ssb[index] =  mu * (3*mu + 2)/2.0 * area * (0.2231 + 0.0244 * alog10(area))
  
  return, ssb
  
end
