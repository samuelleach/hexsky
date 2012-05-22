pro spawnfast,command

  ;AUTHOR: S. Leach
  ;PURPOSE: Intended to be a drop-in replacement for spawn, but faster.

  mycommand = str_sep(command,' ',/remove_all)
  index     = where(mycommand ne '')
  mycommand = mycommand[index]
  ;  print,mycommand

  spawn,mycommand,/noshell


end

