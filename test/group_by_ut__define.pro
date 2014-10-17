
function group_by_ut::test_group_by_tag
  compile_opt strictarr
  
  struct = {a:0, b:0, c:0}
  structs = replicate(struct, 6)
  structs[0] = {a:1, b:1, c:6}
  structs[1] = {a:2, b:2, c:5}
  structs[2] = {a:3, b:3, c:4}
  structs[3] = {a:1, b:4, c:3}
  structs[4] = {a:2, b:5, c:2}
  structs[5] = {a:3, b:6, c:1}
  
  result = group_by_tag(structs, 'a')
  
  ;get the value of b in the second structure (index=1) of the structures with a=3
  assert, (result[3])[1].b eq 6

  return, 1
end

function test_hash_function, struct
  return, struct.a + struct.b
end

function group_by_ut::test_group_by_function
  compile_opt strictarr
  
  struct = {a:0, b:0.0, c:0.0}
  structs = replicate(struct, 6)
  structs[0] = {a:1, b:1.0, c:6.0}
  structs[1] = {a:2, b:2.0, c:5.0}
  structs[2] = {a:3, b:3.0, c:4.0}
  structs[3] = {a:12, b:-10.0, c:3.0}
  structs[4] = {a:14, b:-10.0, c:2.0}
  structs[5] = {a:16, b:-10.0, c:1.0}
  
  result = group_by_function(structs, 'test_hash_function')

  ;number of groups
  assert, n_elements(result.keys()) eq 3
  
  ;test the last value
  assert, (result[6])[1].c eq 1.0
  
  return, 1
end


pro group_by_ut__define
  compile_opt strictarr
  
  define = { group_by_ut, inherits MGutTestCase }
end