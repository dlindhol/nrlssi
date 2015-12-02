function write_manifest, file

  ;Get the name of the file without the path
  ss = strsplit(file, PATH_SEP(), /extract)
  filename = ss[-1]

  ;Determine file sizes (in bytes)
  filesize = (file_info(file)).size

  ;Perform MD5 checksum on file
  checksum = get_checksum(file)
  
  manifest_file = file + '.mnf' 
  openw, lun, manifest_file, /get_lun
  printf, lun, filename + ',' + checksum + ',' + strtrim(filesize,2)
  close, lun

end
