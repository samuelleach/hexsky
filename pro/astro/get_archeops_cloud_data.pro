pro get_archeops_cloud_data,index=index,Ival=Ival,Istat=Istat,Isys=Isys,$
                            Qval=Qval,Qstat=Qstat,Qsys=Qsys,$
                            Uval=Uval,Ustat=Ustat,Usys=Usys,$
                            gal_l=gal_l,gal_b=gal_b,$
                            area=area,polfrac=polfrac,polfrac_stat=polfrac_stat,polfrac_sys=polfrac_sys,$
                            theta=theta,thetastat=thetastat,thetasys=thetasys,$
                            ra=ra,dec=dec
  
  ;AUTHOR: S. Leach
  ;PURPOSE: Read in the Archeops data from Table 1 of Benoit et al 2004

;Cloud I(mKRJ)(stat)(sys)  Q       (stat)  (sys)  U    (stat)(sys)  l      b  A(deg^2)p(%)(stat)(sys)theta(deg)(stat)(sys) RA  DEC

  readcol,!HEXSKYROOT+'/data/ARCHEOPS_Benoit04_table1.dat',index,Ival,Istatt,Isys,$
                            Qval,Qstat,Qsys,Uval,Ustat,Usys,gal_l,gal_b,$
                            area,polfrac,polfrac_stat,polfrac_sys,$
                            theta,thetastat,thetasys,ra,dec


end
