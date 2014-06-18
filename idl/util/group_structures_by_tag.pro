;Given an array of structures and the name of one of its tags,
;create a Hash of Lists where the keys are the distinct values
;of the tag and the values are lists of all the structures with
;that given tag value.
;Assumes all structures have the same elements.
function group_structures_by_tag, structures, tag
  ;Find the tag index
  tags = tag_names(structures[0])
  index = where(strcmp(tags, strupcase(tag)) eq 1, count)
  ;make sure we got one
  if (count ne 1) then return, -1

  ;Define Hash to contain the results
  result = Hash()

  ;Put each structure into the appropriate list based on its value for the given tag.
  for i = 0, n_elements(structures)-1 do begin
      value = structures[i].(index)
      if result.hasKey(value) then result[value].add, structures[i]  $
      else result[value] = List(structures[i])
  endfor

  return, result
end
