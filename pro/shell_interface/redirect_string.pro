FUNCTION redirect_string

  ;AUTHOR: S. Leach based on code provided by B. Gold.
  ;PURPOSE: Provide a redirect string (&> or >&) depending
  ;         on the shell being used.

  redirect_string = ' &> '
  if (strmatch(getenv('SHELL'),'*csh')) then redirect_string = ' >& '

  return,redirect_string

end
