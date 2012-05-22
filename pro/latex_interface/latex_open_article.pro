pro latex_open_article,lun,filename

  ;AUTHOR: S. Leach
  ;PURPOSE: Open a latex article.

  openw,lun,filename
  
  printf,lun,'\documentclass[a4paper,10pt]{article}'
  printf,lun,'\usepackage{epsfig}'
  printf,lun,'\usepackage{latexsym}'
  printf,lun,'\usepackage{graphicx}'
  printf,lun,'\usepackage{amsfonts}'
  printf,lun,'\usepackage{amsmath}'
  printf,lun,'\usepackage{natbib}'
  printf,lun,'\usepackage{xcolor}'
  printf,lun,'\usepackage{verbatim}'
  printf,lun,'%'
  printf,lun,'\topmargin=-3cm'
  printf,lun,'\topmargin=-1cm'
  printf,lun,'\oddsidemargin=-1.5cm'
  printf,lun,'\evensidemargin=-1.5cm'
  printf,lun,'\textwidth=20cm'
  printf,lun,'%'
  printf,lun,'\textheight=27cm'
  printf,lun,'\textheight=25cm'
  printf,lun,'\raggedbottom'
  printf,lun,'\sloppy'

end
