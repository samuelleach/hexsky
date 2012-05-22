pro data_to_color,data,color,range=range

  ;AUTHOR: S. Leach, based on a recipe from David Fanning.
  ;PURPOSE: Given an array of data, return a scaled array of correspon
  ;         IDL colors i.e. integers in the range 0 to 255.

  nn      = n_elements(data)
  mindata = min(data)
  maxdata = max(data)
  
  color = Round(Scale_Vector(Findgen(nn),mindata,maxdata))
  color = Value_Locate(color,data)
  color = Scale_Vector(color, 0, 255)

  range = [mindata,maxdata]

end
