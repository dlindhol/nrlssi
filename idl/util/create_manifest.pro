;@***h* SOLAR_IRRADIANCE_FCDR/create_manifest.pro
;
; NAME
;   create_manifest
;
; PURPOSE
;   The create_manifest.pro function determines file sizes (in bytes) and the MD5 checksum value of 
;   a file and passes the values to write_to_manifest.pro
;
; DESCRIPTION
;   The create_manifest.pro function determines file sizes (in bytes) and the MD5 checksum value of 
;   a file and passes the values to write_to_manifest.pro
;   
; INPUTS
;   output_dir - Path of directory to the input files 
;   tsifile    - TSI file containing data for file size and MD5 checksum
;   ssifile    - SSI file containing data for file size and MD5 checksum
;
; OUTPUTS
;   struct     - A structure containing:
;     tsibytes    - File size (in bytes) of tsifile 
;     ssibytes    - File size (in bytes) of ssifile 
;     tsichecksum - MD5 checksum of tsifile
;     ssichecksum - MD5 checksum of ssifile
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
;   result=create_manifest(output_dir=output_dir,tsifile,ssifile)
;
;@*****
function create_manifest, file

  ;Determine file sizes (in bytes)
  bytes = (file_info(file)).size
  
  ;Perform MD5 checksum on file
  checksum = get_checksum(file)
  
  ;Create the resulting structure for manifest data.
  struct = {manifest,   $
    bytes: bytes,       $
    checksum: checksum  $
  }   
 
  return,struct
end ; pro