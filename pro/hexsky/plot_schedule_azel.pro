pro plot_schedule_azel,schedule,outputdir=outputdir

  ;AUTHOR: S. Leach
  ;PURPOSE: Make and az/el plot of a hexsky schedule.

  if n_elements(outputdir) eq 0    then outputdir    = './output'

  spawn,'mkdir -p '+outputdir+'/ps'

  ncommand       = schedule.ncommands

  commands       = get_command_list()
  ncommandtype   = n_elements(commands) 

  red = fsc_color('red')
  blue = fsc_color('navy')

  for tt = 0, ncommandtype-1 do begin
     psfile = outputdir+'/ps/schedule_azel_'+commands[tt]+'.ps'
     ps_start,filename=psfile
     
     plot,[0,360],[0,90],yrange=[25,65],ystyle=1,xrange=[0,360],xstyle=1,chars=1.5,$
          xtitle='Azimuth [deg]',ytitle='Elevation [deg]',title='Az/el repointings',/nodata
     for cc = 0, ncommand -1 do begin
        if schedule.command[cc].name eq commands[tt] then begin
           asc_read,outputdir+'/hexsky_outfiles/command'+strtrim(cc+1,2)+$
                    '_azel_repointings.dat',az_pointing,el_pointing,/silent
           oplot,az_pointing,el_pointing, psym=3
           oplot,[az_pointing[0],az_pointing[0]],[el_pointing[0],el_pointing[0]],color=red,psym=sym(1)
           np = n_elements(az_pointing)
           oplot,[az_pointing[np-1],az_pointing[np-1]],[el_pointing[np-1],el_pointing[np-1]],color=blue,psym=sym(1)
        endif
     endfor
     al_legend,box=0,/top,/right,commands[tt]
     al_legend,box=0,/bottom,/right,['First pointing','Last pointing'],psym=[sym(1),sym(1)],color=[red,blue]
     ps_end
  endfor

end
