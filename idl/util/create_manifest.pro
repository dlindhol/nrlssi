function create_manifest,tsifile,ssifile

  ;Determine file sizes (in bytes)
  command = 'ls -l '+tsifile+ " |awk '{print $5}'"
  spawn, command, tsi_bytes
  command = 'ls -l '+ssifile+ " |awk '{print $5}'"
  spawn, command, ssi_bytes
  ;Perform MD5 checksum on files
  command = 'md5sum ' + tsifile + " | awk '{print $4}'"
  spawn,command,tsi_checksum
  command = 'md5sum ' + ssifile + " | awk '{print $4}'"
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