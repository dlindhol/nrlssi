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
;   which computes the sunspot darkening index for a time period defined by a starting and ending date. Keyword parameters define
;   whether the sunspot darkening index is obtained from files identified as "final", or preliminary data ("dev") 
;   
; INPUTS
;   ymd1                - starting time range respective to midnight GMT of the given day, in 'yyyy-mm-dd' format
;   ymd2                - ending time range respective to midnight GMT of the given day (i.e. in NOT inclusive), in 'yyyy-mm-dd' format.
;   final               - delegate to the LaTiS server for final released data.
;   dev                 - delegate to processing routine for preliminary data.          
;                  
; OUTPUTS
;   data                - an IDL list containing modified Julian date and sunspot darkening index
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
;   result=get_sunspot_blocking(ymd1,ymd2,final=final,dev=dev)
;
;@*****
function get_sunspot_blocking_from_routine, ymd1, ymd2
  ;invoke the sunspot blocking routine
  data = process_sunspot_blocking(ymd1, ymd2)
  return, data
end

;Get data from LaTiS with option to get final vs prelim.
;Default to prelim - final released data plus the latest updates
function get_sunspot_blocking_from_latis, ymd1, ymd2, final=final, cycle=cycle
  ;add day to end time to make it inclusive
  end_date = mjd2iso_date(iso_date2mjdn(ymd2) + 1)

  ;get the dataset name 
  if keyword_set(final) then dataset = 'nrl2_sunspot_darkening_v02r00'  $
  else if keyword_set(cycle) then dataset = 'nrl2_sunspot_darkening_cycle'  $
  else dataset = 'nrl2_sunspot_darkening'
  
  ;add query parameters
  query = 'convert(time,days since 1858-11-17)' ;convert times to MJD
  query += '&rename(time,MJDN)&rename(ssd,ssbt)' ;rename parameters to match the structures we expect here.
  
  ;get the data as a list of structures
  data = read_latis_data(dataset, ymd1, end_date, query=query)
  return, data
end

;Main function. Delegate to the processing routine if dev is set.
;Otherwise delegate to LaTiS.
function get_sunspot_blocking, ymd1, ymd2, final=final, dev=dev, cycle=cycle
  if keyword_set(dev) then data = get_sunspot_blocking_from_routine(ymd1, ymd2)  $
  else data = get_sunspot_blocking_from_latis(ymd1, ymd2, final=final, cycle=cycle)
  return, data
end
