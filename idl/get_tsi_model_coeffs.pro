function get_tsi_model_coeffs

  openr,1,'data/tsi_mod_mr2_13Feb13.txt'
  line=''
  while not eof(1) do begin
    readf,1,line
    if strmid(line,5,5) eq 'quiet' then reads,strmid(line,21,10),S0, format = '(f16.6)'
    if strmid(line,1,2) eq 'a0' then reads,strmid(line,4,16),a0,format = '(f16.6)'
    if strmid(line,1,2) eq 'a1' then reads,strmid(line,4,16),a1,format = '(f16.6)'
    if strmid(line,1,2) eq 'a2' then reads,strmid(line,4,16),a2,format = '(f16.6)'
  endwhile
  close,1
  
  struct = {tsi_model_coeffs, a0:a0, a1:a1, a2:a2, S0:S0}
  return, struct
  
end
