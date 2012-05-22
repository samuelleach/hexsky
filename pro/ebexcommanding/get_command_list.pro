FUNCTION GET_COMMAND_LIST,dummy
    
   ;AUTHOR: S. Leach.
   ;PURPOSE: Return a list of the possible commands.
   ;COMMENT: Maintain this function and command_format.pro with new commands.

   return,['cmb_scan','calibrator_scan','cmb_dipole']

END
