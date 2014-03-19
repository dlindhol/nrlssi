
function get_tsi_model_coeffs_ut::test
  compile_opt strictarr
  
  result = get_tsi_model_coeffs()
  assert, result.a0 eq 1327.371582
  assert, result.a1 eq 126.925819
  assert, result.a2 eq -1.351869
  assert, result.S0 eq 1360.7

  return, 1
end


pro get_tsi_model_coeffs_ut__define
  compile_opt strictarr
  
  define = { get_tsi_model_coeffs_ut, inherits MGutTestCase }
end
