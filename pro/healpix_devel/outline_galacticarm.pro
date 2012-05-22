function outline_galacticarm,name,galactic=galactic

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct containing a circle around the Galactic
  ;         spiral arms (as indentified in Rotation measure surveys) in and Galactic loops
  ;         RM sprial arm data from Frick et al 2001, Table 1.
  ;         Radio loop data from Berkhuijsen, Haslam, Salter 1971

  
  
  case(strlowcase(name)) of
      'sagittarius': begin
	n = 1
	l = 33.
	b = 0.
	r = 35.
      end
      'carina': begin 
	n = 1
	l = 330.
	b = 0.
	r = 35.
      end
      'orion': begin 
	n = 2
	l = [98.,276]
	b = [-13.,-17.]
	r = [76.,76.]
      end
      'perseus': begin 
	n = 2
	l = [130.,190.]
	b = [0.,0.] 
	r = [30.,30.]
      end
      'loop i': begin 
	n = 1
	l = 329.
	b = 17.5
	r = 58.
      end
      'loop ii': begin 
	n = 1
	l = 100.
	b = -32.5
	r = 45.5
      end
      'loop iii': begin 
	n = 1
	l = 124.
	b = 15.5
	r = 32.5
      end
      'loop iv': begin 
	n = 1
	l = 315
	b = 48.5
	r = 19.75
      end
      else: message,'Arm/loop not recognised: ',arm
  endcase

  outline = outline_circle(l[0],b[0],2*r[0])
  if (not keyword_set(galactic)) then outline = coordchange_outline(outline,2)
  for ff = 1,n-1 do begin
    outline_temp = outline_circle(l[ff],b[ff],2*r[ff])
    if (not keyword_set(galactic)) then outline_temp = coordchange_outline(outline_temp,2)
    outline = [outline,outline_temp]
  endfor

  
  return, outline
  
END
