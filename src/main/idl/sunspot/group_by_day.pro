;Bin records by UTC day.
;Return a Hash where the key is the Julian Day Number 
;  and the value is a List of records for that day.
function group_by_day, structures
;Note Julian Day Number represents noon on a UTC day.
;Round JD to nearest JDN so data are binned by UTC day.

  ;Define Hash to contain the results.
  result = Hash()
  
  for i = 0, n_elements(structures)-1 do begin
    jdn = round(structures[i].jd)
    if result.hasKey(jdn) then result[jdn].add, structures[i]  $
    else result[jdn] = List(structures[i])
  endfor

  return, result
  
end
