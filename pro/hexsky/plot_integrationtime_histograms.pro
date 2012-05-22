pro plot_integrationtime_histograms,map_tint_bycommand,outputdir=outputdir,subdir=subdir,$
                                    net=net,ndet=ndet,nday=nday

  ;AUTHOR: S. Leach
  ;PURPOSE: Make integration time histograms for each command. This routine
  ;         assumes that map_tint_bycommand is a healpix map with the
  ;         same amount of columns as elements in the array
  ;         get_command_list().
  
  if(n_elements(outputdir) eq 0) then outputdir = './output/'
  if(n_elements(subdir) eq 0) then subdir = 'boresight/'
;  if(n_elements(ndet) eq 0)      then ndet = 0
;  if(n_elements(nday) eq 0)      then nday = 14
  
  commands  = get_command_list()
  ncommands = n_elements(commands)

  nside_hitmap   = npix2nside(n_elements(map_tint_bycommand[*,0])) 
  pixsize_arcmin = nside_to_pixsize(nside_hitmap)

  spawn,'mkdir -p '+outputdir+'/ps'
  spawn,'mkdir -p '+outputdir+'/data'+'/'+subdir

  for cc = 0, ncommands - 1 do begin
     ;-------------------------------------------------------------
     ;Make histograms of integration time and sqrt integration time
     ;-------------------------------------------------------------  
     command = commands[cc]
     if total(map_tint_bycommand[*,cc]) gt 0. then begin
        print,'Making histograms for command '+command
        psfile = outputdir+'/ps/schedule_histogram_'+command+'.ps'
        ps_start, filename=psfile
        index       = where(map_tint_bycommand[*,cc] gt 0.)
        minmax_tint = minmax(map_tint_bycommand[index,cc])
        median_tint = median(map_tint_bycommand[index,cc])
        mean_tint   = mean(map_tint_bycommand[index,cc],/double)
        histoplot,map_tint_bycommand[index,cc],histdata=histdata,locations=locations,$
                  xtitle='Integration time [sec]',ytitle='Number of '+$
                  number_formatter(pixsize_arcmin,dec=1)+"' pixels",thick=4.5,$
                  title=command+': Mean = '+number_formatter(mean_tint,dec=1)+$
                  ', Median = '+number_formatter(median_tint,dec=1)+$
                  ', Max = '+number_formatter(minmax_tint[1],dec=1)
        ps_end
        
        psfile = outputdir+'/ps/schedule_cumulhistogram_'+command+'.ps'
        ps_start,filename=psfile
        cumulative_dist = total(histdata,/cumulative,/double)
        plot,locations,(max(cumulative_dist)-cumulative_dist)*nside2solidangle(nside_hitmap,/sqdeg),$
             xtitle='Integration time per '+number_formatter(pixsize_arcmin,dec=1)+"' pixel [sec]",$
             thick=4.5,ytitle='Area [sq. deg]',xthick=5,ythick=5
        al_legend,command,box=0,/top,/right     
        ps_end
        
        psfile = outputdir+'/ps/schedule_histogram_sqrtsec_'+command+'.ps'
        ps_start,filename=psfile
        data        = sqrt(map_tint_bycommand[index,cc])
        minmax_tint = minmax(data)
        median_tint = median(data)
        mean_tint   = mean(data,/double)
        histoplot,data,histdata=histdata,locations=sqrt_tint,$
                  xtitle=textoidl('sqrt(Integration time) ')+'[sqrt(sec)]',ytitle='Number of '+$
                  number_formatter(pixsize_arcmin,dec=1)+"' pixels",thick=4.5,$
                  title=command+': Mean = '+number_formatter(mean_tint,dec=1)+$
                  ', Median = '+number_formatter(median_tint,dec=1)+$
                  ', Max = '+number_formatter(minmax_tint[1],dec=1)
        ps_end
        
        psfile = outputdir+'/ps/schedule_cumulhistogram_sqrtsec_'+command+'.ps'
        ps_start,filename=psfile
        ymargin   = !y.margin
        xmargin   = !x.margin
        !y.margin = [4,3]
        !x.margin = [10,8]
        cumulative_dist = total(histdata,/cumulative,/double)
        area            = (max(cumulative_dist)-cumulative_dist)*nside2solidangle(nside_hitmap,/sqdeg)
        plot, sqrt_tint, area,$
             xtitle='sqrt(Integration time) per '+number_formatter(pixsize_arcmin,dec=1)+"' pixel [s!U1/2!N]",$
             thick=6.5,ytitle='Area [sq. deg]',xthick=5,ythick=5,xstyle=8,ystyle=8
        AXIS, yAXIS=1, yRANGE=!y.crange/41253.*100, ytitle=textoidl('f_{sky} [%]'),ystyle=1
        
        netstring=''
        fsky_percent = area/41253.*100.
        if n_elements(net) ne 0 then begin
           AXIS, xAXIS=1, xRANGE=!x.crange/pixsize_arcmin/net, $
                 xtitle=textoidl('Temperature survey depth [(\muK arcmin)^{-1}]')+$
                 ' (NET = '+number_formatter(net,dec=1)+textoidl(' \muK s^{1/2})'),$
                 xstyle=1

           ;-------------------------------------------
           ;Get a homogeneous noise survey and overplot
           ;-------------------------------------------
           if n_elements(ndet) gt 0 then begin
              t_obs = nday * 24. * 3600.
              weight = get_homogeneous_survey_weight(fsky_percent,net,t_obs,ndet)
              oplot,weight*pixsize_arcmin*net,area,line=2,thick=4
              al_legend,box=0,line=2,number_formatter(nday)+$
                     ' day x '+number_formatter(ndet)+' det, uniform surveys',/bottom,/left,thick=4,chars=1.2
           endif

        endif
        al_legend,command,box=0,/top,/right
        !y.margin = ymargin
        !x.margin = xmargin


        ps_end

        ;--------------------------
        ; Write survey data to disk
        ;--------------------------
        outfile = outputdir+'/data/'+subdir+'/surveydata_'+command+'.dat'
        message,'Writing survey data to '+outfile,/continue
        asc_write,outfile,sqrt_tint,sqrt_tint/pixsize_arcmin/net,area,fsky_percent,$
                  header = '# Sqrt integration time per '+number_formatter(pixsize_arcmin,dec=1)+' arcmin pixel [s^1/2], '+$
                  'Survey depth [(uK.arcmin)^-1], area [sq. deg], f_sky [%]'

        delvarx,data
     endif
  endfor



end
