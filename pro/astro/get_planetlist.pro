FUNCTION get_planetlist, dummy

    ;AUTHOR: S. Leach
    ;PURPOSE : Returns a list of planets, exlcuding the third
    ;          rock from the sun.

  planetlist = ['MERCURY','VENUS','MARS', $
                'JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']



  return,planetlist
   


END
