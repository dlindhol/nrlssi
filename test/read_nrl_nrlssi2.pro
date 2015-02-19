function read_nrl_nrlssi2
;reader for Judith's NRLSSI2 results (MEGA download, stored at /Users/hofmann/Documents/FCDR_Solar/NRLSSI2_1978_2014d_S21_28Jan15.txt)

  nrlfile = '/Users/hofmann/Documents/FCDR_Solar/NRLSSI2_1978_2014d_S21_28Jan15.txt'
  ;parameters and arrays to read NRL download
  ;nver = n_elements(nrlfile)
  startyear = 1978
  endyear = 2014
  ndy=julday(1,1,endyear+1)-julday(1,1,startyear)
  yr=fltarr(ndy)
  mn=fltarr(ndy)
  dd=fltarr(ndy)
  dn=fltarr(ndy)
  dy=findgen(ndy)+1
  ti=fltarr(ndy)
  spec=fltarr(3785,ndy)
  tspec=fltarr(ndy)
  wave=fltarr(3785)
  dat0=fltarr(4)
 

    ;for this version of Judith's data:
    nband = 3785
    fln = nrlfile
    arr0=3785-nband
    
    ;read header
    print,'Reading ....',fln
    close,1
    openr,1,fln
    dumi='   '
    for k=1,4 do begin
    readf,1,dumi
    ; print,dumi
    endfor
    
    ;read wavelength information
    dat=fltarr(nband)
    readf,1,dat 
    wldat=fltarr(nband,2)
    wldat(*,0)=dat          ; wavelength band center
    readf,1,dumi ; &print,dumi
    readf,1,dat
    wldat(*,1)=dat          ; wavelength band width
    ;
    readf,1,dumi &print,dumi
    readf,1,dumi &print,dumi
    
   
    ;read spectrum from startyear to endyear, inclusive
    ndy=julday(1,1,endyear+1)-julday(1,1,startyear)
    for n=0,ndy-1 do begin
    readf,1,dat0
    yr(n)=dat0(0)
    mn(n)=dat0(1)
    dd(n)=dat0(2)
    dn(n)=julday(dat0(1),dat0(2),dat0(0))-julday(1,1,startyear)+1
    ti(n)=dat0(3)     ; calculated directly from TSI model
    readf,1,dat
    ;if(nv eq 0) then dat=dat/1000.
    spec(arr0:*,n)=dat
    ; add up spec and check that it matches ti
    tspec(n)=total(dat*wldat(*,1))
    ; print,yr(n),mn(n),dy(n),tspec(n,nv),ti(n,nv)
    endfor
    close,1

    ; define structure to hold results
    nrl = {spec:    spec,  $
    tsi:     ti,    $
    totspec: tspec, $
    year:    yr,    $
    month:   mn,    $
    day:     dd     $
    }
  
    return,nrl    
end; pro