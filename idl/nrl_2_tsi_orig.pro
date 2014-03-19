;@***h* TSI_FCDR/nrl_2_tsi.pro
; 
; NAME
;   nrl_2_tsi.pro
;
; PURPOSE
;   The nrl_2_tsi.pro routine reads pre-tabulated output of facular brightening (PX) and photometric
;   sunspot blocking (PS) and computes daily TSI (TI) from these values according to a multi-regression
;   formula.  The formula and coefficients (a0, a1, a2, and S0) for the multi-regression are 
;   identified in the routine are computed by Judith Lean.  The routine writes the output 
;   to NetCDF4 format.
;
; DESCRIPTION
;   This routine reads a text file of multiple regression output and computes a daily TSI value. 
;   Missing values are replaced with NaN values. The output data are written to a NetCDF4 file named
;   nrl_tsi.nc
;   Reference describing the solar variability model using a linear combination of sunspot darkening
;   and facular brightening: Fröhlich, C., and J. Lean, The Sun’s total irradiance: Cycles, trends 
;   and climate change uncertainties since 1976, Geophys. Res. Lett., 25, 4377‐4380, 1998.
; 
; INPUTS
;   the input file 'infile' is an ascii text columnar file from which the following inputs and
;   2-component multiple regression output are obtained:
;   TSI measurements (TSI data)
;   sunspot blocking (PS): using area-dependent contrasts - Dec 05
;   facular brightening (PX): from Viereck, R. A., et al. (2004), Space Weather, 2, S100005 
;   and SORCE Mg index
;   quiet Sun (S0) =  1360.700 Watt/m**2
;   2-Component regression formula and coefficients: TI = a0 + a1*px + a2*S0*ps/1.e6
;                                                    a0 = 1327.371582
;                                                    a1 = 126.925819
;                                                    a2 = -1.351869
;
; OUTPUTS
;   in netCDF4 format (output filename will be named 'nrl_tsi.nc')
;   TSI        = daily Total Solar irradiance (units W/m2) derived from multi-regression formula 
;                (from 1 JAN 1978 to 31 DEC 2005)
;   Year       = Year (1978, 1979, etc.)
;   DOY        = Day of Year (from 1 to 365; then repeats for next year, etc.)
;   Day_Number = Day Number (cumulative from start of time series; Day number 1 is 1 JAN 1978)  
;
; AUTHOR
;   Judith Lean, Space Science Division, Naval Research Laboratory, Washington, DC
;   Odele Coddington, Laboratory for Atmospheric and Space Physics, Boulder, CO
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
;   02/04/2014 Initial Version prepared for NCDC
; 
; USAGE
;   nrl_2_tsi,infile
;
;@***** 


PRO nrl_2_tsi_orig,infile

;template to read ascii file of multiple regression output from file = 'infile'
temp = {version:1.0, $
    datastart:15L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:7l, $
    fieldtypes:[4l, 4l, 4l, 4l, 4l,4l, 4l], $ ; float
    fieldnames:['Year', 'DOY', 'Day_Number', $
                'TSI_data','TSI_model','PX','PS'], $
    fieldlocations:[1L, 12L, 20L, 28L, 42L,52L,69L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L, 6L]}            

    query = read_ascii(infile, template = temp)
;
;assign structure variables to arrays and replace missing data with NaN values
year = query.year
doy = query.DOY
day_number = query.Day_Number
TSI_data = query.TSI_data
tmp = where (TSI_data eq -99.0000,count) 
if count gt 0 then TSI_data[tmp]=!VALUES.F_NAN ; -99.0 = missing data
TSI_model = query.TSI_model
tmp = where (TSI_model eq -99.0000,count) 
if count gt 0 then TSI_model[tmp]=!VALUES.F_NAN ; -99.0 = missing data
PX = query.PX
tmp = where (PX eq -99.0000,count) 
if count gt 0 then PX[tmp]=!VALUES.F_NAN ;
PS = query.PS
tmp = where (PS eq -999.0000, count) 
if count gt 0 then PS[tmp]=!VALUES.F_NAN ; -999.0 = missing data

;Knowns, Coefficients, and multiregression formula (obtained from infile) **REMOVE??*
openr,1,infile
line=''
while not eof(1) do begin
    readf,1,line
    if strmid(line,5,5) eq 'quiet' then reads,strmid(line,21,10),S0, format = '(f16.6)'
    if strmid(line,1,2) eq 'a0' then reads,strmid(line,4,16),a0,format = '(f16.6)' 
    if strmid(line,1,2) eq 'a1' then reads,strmid(line,4,16),a1,format = '(f16.6)' 
    if strmid(line,1,2) eq 'a2' then reads,strmid(line,4,16),a2,format = '(f16.6)' 
endwhile
close,1

;compute daily TSI from multiple regression coefficients
TI = a0 + a1*px + a2*S0*ps/1.e6

;create NetCDF file for writing output
id = NCDF_CREATE('nrl_tsi.nc', /CLOBBER,/netCDF4_format) ;noclobber = don't overwrite existing file
; Fill the file with default values (? DO THIS?)
NCDF_CONTROL, id, FILL=4; pre-fill with default value 9.96921E+36 (type = float)
tid = NCDF_DIMDEF(id, 'T', /UNLIMITED) ; Make dimensions.
; Define variables:
xid = NCDF_VARDEF(id, 'TSI', [tid], /FLOAT)
pid = NCDF_VARDEF(id, 'Year', [tid], /FLOAT)
qid = NCDF_VARDEF(id, 'DOY', [tid], /FLOAT)
rid = NCDF_VARDEF(id, 'Day_Number', [tid], /FLOAT)

NCDF_ATTPUT, id, /GLOBAL, "Conventions", "CF-1.5"
NCDF_ATTPUT, id, /GLOBAL, "title", "Daily TSI calculated using NRL TSI 2-component model"
NCDF_ATTPUT, id, /GLOBAL, "institution", "Naval Research Laboratory Space Science Division and Laboratory for Atmospheric and Space Physics"


NCDF_ATTPUT, id, xid, 'long_name', 'Daily Total Solar Irradiance (Watt/ m**2)'
NCDF_ATTPUT, id, xid, 'standard_name', 'daily_TSI'
NCDF_ATTPUT, id, xid, 'units', 'W/m2'

NCDF_ATTPUT, id, pid, 'long_name', 'Year'
NCDF_ATTPUT, id, pid, 'standard_name', 'year'
NCDF_ATTPUT, id, pid, 'units','yr'

NCDF_ATTPUT, id, qid, 'long_name', 'Day of Year'
NCDF_ATTPUT, id, qid, 'standard_name', 'day_of_year'

NCDF_ATTPUT, id, rid, 'long_name', 'Cumulative Day Number From 1 Jan 1978'
NCDF_ATTPUT, id, rid, 'standard_name','cum_day_number_from_1_Jan_1978'
NCDF_ATTPUT, id, rid, 'units','days since 1978-1-1 0:0:0'

;TO DO: is year/time correct, how to do fill_value, missing_value, and/or valid_range
; Put file in data mode:
NCDF_CONTROL, id, /ENDEF
; Input data:
NCDF_VARPUT, id, pid, year
NCDF_VARPUT, id, qid, doy
NCDF_VARPUT, id, rid, day_number
NCDF_VARPUT, id, xid, TI
; Read the data back out:
NCDF_VARGET, id, xid, output_data
NCDF_VARGET, id, rid, time
NCDF_CLOSE, id ; Close the NetCDF file.
stop
end; pro