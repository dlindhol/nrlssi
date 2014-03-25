
;Assumes all structures have the same elements.
function group_structures_by_tag, structures, tag
;TODO: require List of Hashes?


  ;Find the tag index
  tags = tag_names(structures[0])
  index = where(strcmp(tags, tag) eq 1, count)
  ;make sure we got just one
  if (count ne 1) then return, -1

  ;Define Hash to contain the results
  result = Hash()

  for i = 0, n_elements(structures)-1 do begin
      value = structures[i].(index)
      if result.hasKey(value) then result[value].add, structures[i]  $
      else result[value] = List(structures[i])
  endfor

  return, result
  
end
