;@***h* SOLAR_IRRADIANCE_FCDR/write_to_manifest.pro
; 
; NAME
;   write_to_manifest.pro
;
; PURPOSE
;   The write_to_manifest.pro function outputs filename, MD5 checksum, and 
;   file size (in bytes) to a manifest file.
;
; DESCRIPTION
;   The write_to_manifest.pro function writes the filename, MD5 checksum, and 
;   file size (in bytes) to a manifest file.
; 
; INPUTS
;   filename  - name of data file, for which file size and checksum are reported
;   filesize  - filesize (in bytes)
;   checksum  - MD5 checksum for filename
;   fileout   - output filename for the manifest file
;      
; OUTPUTS
;   fileout   - Output manifest file, containing filename, file size, and checksum in a comma separated list
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
;   02/23/2015 Initial Version prepared for NCDC
; 
; USAGE
;   write_to_manifest, filename, filesize, checksum, fileout
;  
;@***** 
function write_to_manifest, output_dir=output_dir, filename, filesize, checksum, fileout

close,1
openw,1,output_dir+fileout
printf,1,filename + ',' + checksum + ',' + filesize
close,1

end