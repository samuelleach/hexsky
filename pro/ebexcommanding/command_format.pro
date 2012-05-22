FUNCTION COMMAND_FORMAT,command_name,$
                        nparameters=nparameters,syntax=syntax,$
                        azspeed_index=azspeed_index,$
                        numelestep_index=numelestep_index,$
                        azthrow_index=azthrow_index,$
                        numstarcam_index=numstarcam_index,$
                        RA_index=RA_index

;  AUTHOR: S. Leach
;  PURPOSE: This function returns the format string for printing
;          commands, and optionally the number of parameters for
;          the command and its syntax.
;!!  COMMENT: Maintain this function and get_command_list.pro with
;           new commands. !!

;   timeformat='(i3,1x,f6.3,1x,'
;   timeformat='(i4,1x,f6.3,1x,'
   timeformat='(i4,1x,f7.4,1x,'

   case strlowcase(command_name) of                            
       'cmb_scan': begin
           format           = timeformat+'5f8.3,i4,i4)'
           nparameters      = 9
           RA_index         = 2
           azspeed_index    = 4
	   azthrow_index    = 5 
           numelestep_index = 7 
           numstarcam_index = 8
           syntax='day hr centralRA centralDec azSpeed azWidth'+$
             ' targetDecRange noOfSteps numThrow+1'
       end
       'calibrator_scan': begin
           format           = timeformat+'4f8.3,1x,f7.3,i4,i4)'
           nparameters      = 9
           RA_index         = 2
           azspeed_index    = 4 
           azthrow_index    = 5 
           numelestep_index = 7 
           numstarcam_index = 8
           syntax='day hr centralRA centralDec azSpeed azWidth'+$
             ' elevationStep noOfSteps numThrow+1'
       end
       'cmb_dipole': begin
           format           = timeformat+'5f10.2,7x)'
           nparameters      = 7
           azspeed_index    = 5 
           RA_index         = -1
           azthrow_index    = -1 
           numelestep_index = -1
           numstarcam_index = -1
           syntax='day hr azSpeed elevation totalTime'+$
             ' finalAz finalEl'
       end
       else: begin
           format = timeformat+'20f8.2)'
           RA_index         = -1
           azspeed_index    = -1 
           azthrow_index    = -1 
           nparameters      = -1
           numelestep_index = -1
           numstarcam_index = -1
       end
   endcase
   
   return,format

end
