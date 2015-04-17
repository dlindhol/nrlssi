;PRO BB,TEMP,WBB,FBBW,FBBP
; alternative calling sequence
PRO BB,TEMP,WBB,FBBW,FBBP,XW,XP
;
; pro to evaluate and plot black body curves
; evaluated using PLANCK FUNCTION (see Astophys. Quant. p 104)
; temp is in deg K
; WBB is wavelength in nm
; FBB is flux in photons/cm**2/sec/nm at 1AU
; to conver to milliwatt/m**2/nm do the following to the flux
; ..divide 10**10 photons/cm**2/sec/nm by the wavelength in nm and
;   multiply by 19.8627
PRINT,'   WAVELENGTH ARRAY assumed to be in nm'
PRINT,'   FBBP IRRADIANCE is ph/cm**2/sec/A at 1AU' 
PRINT,'   FBBW IRRADIANCE is mwatt/m**2/nm at 1AU'  
R1=WHERE(WBB LT 400.)       ;violet spectrum
R2=WHERE(WBB GE 1000)       ;red spectrum
C2=1.43883  ;cm-K
C=3.0E10  ;speed of light in cm/sec
RSE=2.164487E-5 ;sun/earth distance squared
PII=3.14159265
W=WBB*1.E-7     ;WL in cm
XP=2*PII*C/W^4/(EXP(C2/W/TEMP)-1) ;ph/cm**2/sec/cm at sun
XW=2*PII*C/W^4/(EXP(C2/W/TEMP)-1)/1.e7/1.e10/wbb*19.8627
;         milliwatt/m**2/nm at sun
FBBP=XP/1.E7*RSE/10.      ;ph/cm**2/sec/A at 1AU
FBBW=FBBP*10/1.E10/WBB*19.8627    ;milliwatt/m**2/nm at 1AU
END