FUNCTION COMMAND_TO_STRING,command

 ;AUTHOR: C. Bao and S. Leach
 ;PURPOSE: Extract information from a command struct a convert to a
 ;         command string.

; commandline=command.name+'  '

 commandline = '                '
 strput,commandline,command.name,0

 if command.nparameters gt 0 then begin
    cmd_format  = command_format(command.name)
    commandline = commandline+$
                  strtrim(string(command.parameters[0:command.nparameters-1],$
                                 format=cmd_format),2)
 endif
 

 if command.comment ne '' then commandline = commandline+' #'+command.comment
 
 return,commandline
 
END
