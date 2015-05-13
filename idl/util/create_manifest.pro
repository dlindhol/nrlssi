function create_manifest,output_dir=output_dir,tsifile,ssifile

  ;Determine file sizes (in bytes)
  command = 'ls -l '+output_dir+tsifile+ " |awk '{print $5}'"
  spawn, command, tsi_bytes
  command = 'ls -l '+output_dir+ssifile+ " |awk '{print $5}'"
  spawn, command, ssi_bytes
  ;Perform MD5 checksum on files
  ;command = 'md5sum ' + output_dir+tsifile + " | awk '{print $4}'" ;for LINUX system
  command = 'md5 ' + output_dir+tsifile + " | awk '{print $4}'" ;for MAC system
  spawn,command,tsi_checksum
  ;command = 'md5sum ' + output_dir+ssifile + " | awk '{print $4}'" ;for LINUX system
  command = 'md5 ' + output_dir+ssifile + " | awk '{print $4}'" ;for MAC system
  spawn,command,ssi_checksum
  
  ;Create the resulting structure for manifest data.

    struct = {manifest,          $
      tsibytes:     tsi_bytes,   $
      ssibytes:     ssi_bytes,    $
      tsichecksum:  tsi_checksum, $
      ssichecksum:  ssi_checksum  $
    }   
  return,struct
end ; pro