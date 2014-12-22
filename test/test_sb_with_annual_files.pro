pro test_sb_with_annual_files
;compares sunspot blocking function (and std. dev) for a year against Judiths annual files
ymd1='2014-01-01'
ymd2='2014-12-31'
year='2014'

;get sb 
sb=process_sunspot_blocking(ymd1,ymd2)

;read in annual file
afile = 'data/judith_annual_files/SSB_USAF_'+year+'_Dec14.txt'
atemplate = {version:1.0, $
    datastart:2L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:6l, $
    fieldtypes:[3l, 4l, 4l, 4l,4l, 3l], $ ; float
    fieldnames:['date', 'sb_dep', 'dsb_dep', 'sb_indep','dsb_indep','num'], $
    fieldlocations:[6L, 17L, 27L, 36L, 47L, 59L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L]}

result=read_ascii(afile,temp=atemplate) ;structure to hold the contents of ascii annual file

p=plot(result.date,sb.ssbt-result.sb_indep,title='Difference: LASP/NRL (annual file)')
for i=0,365 do begin 
  print,mjd2iso_date(sb[i].mjdn),float(sb[i].ssbt)-result.sb_indep[i]
endfor
end; pro