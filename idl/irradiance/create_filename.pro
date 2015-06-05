;@***h* SOLAR_IRRADIANCE_FCDR/create_filename.pro
;
; NAME
;   create_filename
;
; PURPOSE
;   The create_filename.pro function dynamically constructs a data product file name.
;
; DESCRIPTION
;   The create_filename.pro function dynamically constructs a data product file name.
;
; INPUTS
;   ymd1            - starting time range for the time range of the form 'yyyy-mm-dd'
;   ymd2            - ending time range for the time range of the form 'yyyy-mm-dd'
;   version         - version and revision number of the NRLTSI2 and NRLSSI2 models (e.g., v02r00)
;   time_bin        - A value of 'year', 'month', or 'day' that defines the time-averaging performed for the given data records.
;                     'day' is the default.
;   tsi             - Keyword parameter designating file name is to be constructed for TSI data.
;   ssi             - Keyword parameter designating file name is to be constructed for SSI data.
;
; OUTPUTS
; 
;   filename        - The data product file name
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
;   result=create_filename(ymd1, ymd2, version, time_bin, tsi=tsi, ssi=ssi)
;
;@*****
function create_filename, ymd1, ymd2, version, time_bin, tsi=tsi, ssi=ssi

  ;Make sure output_dir is defined. Default to current directory.
  if n_elements(output_dir) eq 0 then output_dir = ''

  ;Format times.
  ;Start date as yyyymmdd
  symd = remove_hyphens(ymd1)
  ;End datae as yyyymmdd
  eymd = remove_hyphens(ymd2)
  ;Creation date
  ;(TO DO: change to form DDMMMYY, ex., 09Sep14, but saved under alternative variable name as .nc4 metadata requires this info as well in ISO 8601 form..)
  creation_date = jd2iso_date(systime(/julian, /utc)) ;now as yyyy-mm-dd UTC
  cymd = remove_hyphens(creation_date) ;yyyymmdd
  
  ;Get the name of the paramter we are saving: ssi or tsi
  if keyword_set(ssi) then param = 'ssi'
  if keyword_set(tsi) then param = 'tsi'
  ;TODO: error if neither set

  ;Construct file name based on time bin
  if (time_bin eq 'day') then filename = param +'_'+ version +'_'+ 'daily_s' + symd +'_e'+ eymd +'_c'+ cymd +'.nc'
  if (time_bin eq 'month') then begin
    symd = strmid(symd,0,6);starting ym
    eymd = strmid(eymd,0,6) ;ending ym
    filename = param +'_'+ version +'_'+ 'monthly_s' + symd +'_e'+ eymd +'_c'+ cymd +'.nc'
  endif
  if (time_bin eq 'year') then begin
    symd = strmid(symd,0,4);starting ym
    eymd = strmid(eymd,0,4) ;ending ym
    filename = param +'_'+ version +'_'+ 'yearly_s' + symd +'_e'+ eymd +'_c'+ cymd +'.nc'
  endif
  ;TODO: else error

  return, filename

end
