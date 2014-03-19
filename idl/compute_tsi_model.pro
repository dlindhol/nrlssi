;Compute the Model Total Solar Irradiance from the given
;TSI model coefficients (c) and TSI model regression data (d).
function compute_tsi_model, c, d
  
  ; Evaluate the tsi model
  tsi = c.a0 + c.a1 * d.px + c.a2 * c.S0 * d.ps / 1.e6
  
  ; Create data structure with the results
  data = {tsi_model, year:d.year, doy:d.doy, day_number:d.day_number, tsi:tsi}

  return, data
  
end