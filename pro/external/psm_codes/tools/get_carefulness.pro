FUNCTION GET_CAREFULNESS

  DEFSYSV, '!carefulness', exists=exists
  IF exists THEN RETURN, !carefulness ELSE RETURN, 0

END
