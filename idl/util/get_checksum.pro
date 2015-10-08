function get_checksum, file
  ;Perform MD5 checksum on the given file
  ;The system command depends on OS
  os = !Version.OS
  if (os eq 'linux')  then begin 
    command = 'md5sum ' + file + " | awk '{print $1}'" 
    spawn,command,checksum
  endif else if (os eq 'darwin') then begin
    command = 'md5 ' + file + " | awk '{print $4}'"
    spawn,command,checksum
  endif
 
  return, checksum[0]
end
