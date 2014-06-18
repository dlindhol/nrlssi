function get_tsi_model_functions, file

  ;template to read ascii file of multiple regression output from file
  temp = {version:1.0, $
    datastart:15L, $
    delimiter:32b, $
    missingvalue:!VALUES.F_NAN, $
    commentsymbol:'', $
    fieldcount:7l, $
    fieldtypes:[4l, 4l, 4l, 4l, 4l,4l, 4l], $ ; float
    fieldnames:['Year', 'DOY', 'Day_Number', $
    'TSI_data','TSI_model','PX','PS'], $
    fieldlocations:[1L, 12L, 20L, 28L, 42L,52L,69L], $
    fieldgroups:[0L, 1L, 2L, 3L, 4L, 5L, 6L]}
    
  data = read_ascii(file, template = temp)
  
  ;Replace missing values with NaN
  data.TSI_data = replace_missing_with_nan(data.TSI_data, -99.0)
  data.TSI_model = replace_missing_with_nan(data.TSI_model, -99.0)
  data.PX = replace_missing_with_nan(data.PX, -99.0)
  data.PS = replace_missing_with_nan(data.PS, -999.0)
  
  return, data
  
end
