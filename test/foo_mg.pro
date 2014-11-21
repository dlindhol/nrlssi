pro foo_mg

;first compare different dated versions of Univ Bremen Mg II composite
verJ = 'archive/data/GOME_MgII_composite_v4_19Mar14.dat' ;(Judith's file downloaded 20140319)
verO = 'archive/data/MgII_composite.dat' ;(Odele's file downloaded 20141023)

tempJ = {version:1.0, $
    datastart:21L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[5l, 3l, 3l, 4l, 3l], $ ; float
    fieldnames:['field1', 'field2', 'field3', $
    'field4','field5'], $
    fieldlocations:[2L, 13L, 16L, 20L, 29L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]} ;ascii template to read Judith's file
    
tempO = {version:1.0, $
    datastart:22L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[5l, 3l, 3l, 4l, 3l], $ ; float
    fieldnames:['field1', 'field2', 'field3', $
    'field4','field5'], $
    fieldlocations:[2L, 13L, 16L, 20L, 29L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]} ;ascii template to read Odele's file
    
;read the data    
Judith = read_ascii(verJ,temp=tempJ) ;shorter record
Odele = read_ascii(verO,temp=tempO) ;longer record

;subset to same record length
Odele_field1 = Odele.field1(0:12915)
Odele_field2 = Odele.field2(0:12915)
Odele_field3 = Odele.field3(0:12915)
Odele_field4 = Odele.field4(0:12915)
Odele_field5 = Odele.field5(0:12915)

;plot difference in time series from beginning of record
p1 = plot(Judith.field1,Judith.field4-Odele_field4,title='Difference in Mg II from different Univ. Bremen Files','+k')
p1.yrange=[-0.002,0.004]

;show differences by data source
d1 = where(Judith.field5 eq 1) ;same as in odele file
;d1O = where(odele_field5 eq 1)
p2=plot(Judith.field1[d1],Judith.field4[d1]-Odele_field4[d1],name='Noaa series',overplot=1,'oc')

d2 = where(Judith.field5 eq 2) ;same as in odele file
;d2O = where(odele_field5 eq 2)
p3=plot(Judith.field1[d2],Judith.field4[d2]-Odele_field4[d2],name='Noaa7 SBUV',overplot=1,symbol='o',color='powder blue',linestyle=6)

d3 =where(Judith.field5 eq 3) ;same as in odele file
;d3O = where(odele_field5 eq 3)
p4=plot(Judith.field1[d3],Judith.field4[d3]-Odele_field4[d3],name='Noaa9 SBUV',overplot=1,symbol='o',color='light blue',linestyle=6)

d4 =where(Judith.field5 eq 4) ;same as in odele file
;d4O = where(odele_field5 eq 4)
p5=plot(Judith.field1[d4],Judith.field4[d4]-Odele_field4[d4],name='Noaa11 SBUV',overplot=1,symbol='o',color='light sky blue',linestyle=6)

d5 =where(Judith.field5 eq 5) ;same as in odele file
;d5O = where(odele_field5 eq 5)
p6=plot(Judith.field1[d5],Judith.field4[d5]-Odele_field4[d5],name='Noaa16 SBUV',overplot=1,symbol='o',color='deep sky blue',linestyle=6)

d6 =where(Judith.field5 eq 6) ;same as in odele file
;d6O = where(odele_field5 eq 6)
p7=plot(Judith.field1[d6],Judith.field4[d6]-Odele_field4[d6],name='Noaa17 SBUV',overplot=1,symbol='o',color='dodger blue',linestyle=6)

d7 =where(Judith.field5 eq 7) ;same as in odele file
;d7O = where(odele_field5 eq 7)
p8=plot(Judith.field1[d7],Judith.field4[d7]-Odele_field4[d7],name='Noaa18 SBUV',overplot=1,symbol='o',color='royal blue',linestyle=6)


d9 = where(Judith.field5 eq 9) ;different in odele file
d9O = where(odele_field5 eq 9)
p10=plot(Judith.field1[d9o],Judith.field4[d9o]-Odele_field4[d9o],name=' uars solstice (classic)',overplot=1,symbol='o',color='forest green',linestyle=6)

d10 = where(Judith.field5 eq 10) ;same as in odele file
;d10O = where(odele_field5 eq 10)
p11=plot(Judith.field1[d10],Judith.field4[d10]-Odele_field4[d10],name='SUSIM',overplot=1,symbol='o',color='misty rose',linestyle=6)

d11 =where(Judith.field5 eq 11) ;same as in odele file
;d11O = where(odele_field5 eq 11)
p12=plot(Judith.field1[d11],Judith.field4[d11]-Odele_field4[d11],name='GOME',overplot=1,symbol='o',color='firebrick',linestyle=6)

d12 =where(Judith.field5 eq 12) ;different in odele file
;d12O = where(odele_field5 eq 12)
p13=plot(Judith.field1[d12],Judith.field4[d12]-Odele_field4[d12],name='SCIAMACHY',overplot=1,symbol='o',color='khaki',linestyle=6)

d13 =where(Judith.field5 eq 13) ;different in odele file
;d13O = where(odele_field5 eq 13)
p14=plot(Judith.field1[d13],Judith.field4[d13]-Odele_field4[d13],name='sorce solstice',overplot=1,symbol='o',color='spring green',linestyle=6)

d14 =where(Judith.field5 eq 14) ;same as in odele file
;d14O = where(odele_field5 eq 14)
p15=plot(Judith.field1[d14],Judith.field4[d14]-Odele_field4[d14],name='OMI',overplot=1,symbol='o',color='deep pink',linestyle=6)

d15 =where(Judith.field5 eq 15) ;different in odele file
;d15O = where(odele_field5 eq 15)
p16=plot(Judith.field1[d15],Judith.field4[d15]-Odele_field4[d15],name='GOME 2a',overplot=1,symbol='o',color='salmon',linestyle=6)

d16 =where(Judith.field5 eq 16) ;different in odele file
;d16O = where(odele_field5 eq 16)
p17=plot(Judith.field1[d16],Judith.field4[d16]-Odele_field4[d16],name='GOME 2b',overplot=1,symbol='o',color='coral',linestyle=6)

d17 =where(Judith.field5 eq 17) ;different in odele file
;d17O = where(odele_field5 eq 17)
p17=plot(Judith.field1[d17],Judith.field4[d17]-Odele_field4[d17],name='f10.7',overplot=1,symbol='o',color='plum',linestyle=6)

l=legend(target=[p2,p3,p4,p5,p6,p7,p8,p10,p11,p12,p13,p14,p15,p16,p17],/data)
p1.xtitle='Date'

;Compare to QA file provided by Judith
file='archive/data/judith_2014_08_21/NRLTSI2_1978_2014d_18Aug14.txt'

 ;template to read ascii file of mg II/facular brightening and sunspot darkening functions from file
  temp = {version:1.0, $
    datastart:1L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:7l, $
    fieldtypes:[3l, 3l, 3l, 3l, 4l,4l, 4l], $ ; float
    fieldnames:['field1', 'field2', 'field3', $
    'field4','field5','field6','field7'], $
    fieldlocations:[1L, 10L, 16L, 26L, 36L,49L,62L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L, 6L]}
    
  verQA = read_ascii(file, template = temp)
  verQA.field6 = replace_missing_with_nan(verqa.field6, -99.0) ;replace NaNs with -99
  
  ;truncate to time period that matches Judith and Odele files from Univ. of Bremen
  x1 = 310   ;1978-11-07
  x2 = 13225 ;2014-03-18
  p18=plot(Judith.field1,Judith.field4-verQA.field6[x1:x2],name='Archive',overplot=1,symbol='.',color='black',linestyle=6)
     
  ;compare Univ of Bremen file on LaTiS (same as "Odele file"); this checks LaTiS utility
  latis=get_mg_index('1978-11-07','2014-03-18') ;**LaTiS off by a day?
  p19=plot(Judith.field1[1:*],Judith.field4[1:*]-latis.index,overplot=1,name='LaTiS','.-r')
  p2b=plot(compJ.field4[c1:c2],overplot=1,'.g',name='Bremen-Judith')
  
  
  ;compare to MgII_composite.dat from Uni. Bremen
  ;http://www.iup.physik.uni-bremen.de/gome/gomemgii.html
  ;template to read ascii file of mb II/facular brightening and sunspot darkening functions from file
  file2 = 'archive/data/MgII_composite.dat'
  temp2 = {version:1.0, $
    datastart:22L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:5l, $
    fieldtypes:[4l, 3l, 3l, 4l, 3l], $ ; float
    fieldnames:['field1', 'field2', 'field3', $
    'field4','field5'], $
    fieldlocations:[2L, 13L, 16L, 20L, 29L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L]}
    
    comp = read_ascii(file2,temp=temp2)
   
    c1 =420 ;1980.00
    c2 =12839 ;2014.00

    p3 = plot(comp.field4[c1:c2],name='Bremen Composite','.b',overplot=1)
    p3b = plot(compJ.field4[c1:c2],name='Bremen Composite-Judith file','.g',overplot=1)
    l = legend(target=[p1,p2,p3,p3b],/data)
    
    p5 = plot(data.field6[x1:x2] - comp.field4[c1:c2],name='NRLTSI2-UniBremen_composite: Odele file','+r')
    p5b = plot(data.field6[x1:x2]-compJ.field4[c1:c2],name='NRLTSI2-UniBremen_composite: Judith file','+g',overplot=1)
    p4 = plot(data.field6[x1:x2] - result.index,name='NRLTSI2-LaTis','ok',overplot=1)
    ;p5 = plot(data.field6[x1:x2] - comp.field4[c1:c2],name='NRLTSI2-UniBremen_composite',overplot=1,'+r')
    l = legend(target=[p4,p5],/data)
    
    
end