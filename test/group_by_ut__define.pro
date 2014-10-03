
function group_by_ut::test
  compile_opt strictarr
  
  struct = {a:0, b:0, c:0}
  structs = replicate(struct, 6)
  structs[0] = {a:1, b:1, c:6}
  structs[1] = {a:2, b:2, c:5}
  structs[2] = {a:3, b:3, c:4}
  structs[3] = {a:1, b:4, c:3}
  structs[4] = {a:2, b:5, c:2}
  structs[5] = {a:3, b:6, c:1}
  
  result = group_by(structs, 'a')
  
  ;get the value of b in the second structure (index=1) of the structures with a=3
  assert, (result[3])[1].b eq 6

  return, 1
end



pro group_by_ut__define
  compile_opt strictarr
  
  define = { group_by_ut, inherits MGutTestCase }
end