function get_spectral_bins

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; set up wavelength bands for summing 1 nm spectrum
; the wavelength grid is as follows:
; 1 nm from 115 to 750
; 5 nm from 750 to 5000
; 10 nm from 5000 to 10000
; 50 nm from 10000 to 100000

nband1=750-115
nband2=(5000-750)/5
nband3=(10000-5000)/10
nband4=(100000-10000)/50
nband=nband1+nband2+nband3+nband4
bandcenter=fltarr(nband)      ; midpint wavelength of band 
bandwidth=fltarr(nband)       ; delta wavelength band
;
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