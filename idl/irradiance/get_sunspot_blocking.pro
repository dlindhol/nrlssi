;@***h* SOLAR_IRRADIANCE_FCDR/get_sunspot_blocking.pro
;
; NAME
;   get_sunspot_blocking.pro
;
; PURPOSE
;   The get_sunspot_blocking.pro is a utility function that iteratively invokes the function process_sunspot_blocking for a time period
;   defined by a starting and ending date. 
;   
; DESCRIPTION
;   The get_sunspot_blocking function is a utility function that iteratively invokes a second function, process_sunspot_blocking, 
;   which computes the sunspot darkening index for a time period defined by a starting and ending date that is passed to the routine from 
;   the main driver, nrl_2_irradiance.pro
;      
; INPUTS
;   ymd1       - starting time range respective to midnight GMT of the given day, in Modified Julian day (converted from 'yyyy-mm-dd' in main driver).
;   ymd2       - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), 
;                in Modified Julian day (converted from 'yyyy-mm-dd' in main driver).
;                  
; OUTPUTS
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
;   get_sunspot_blocking,ymd1,ymd2
;
;@*****
function get_sunspot_blocking_from_routine, ymd1, ymd2
  ;invoke the sunspot blocking routine
  data = process_sunspot_blocking(ymd1, ymd2)
  return, data
end


function get_sunspot_blocking, ymd1, ymd2
  return, get_sunspot_blocking_from_routine(ymd1, ymd2)
end
