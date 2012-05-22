function example_schedule,year_ref=year_ref,month_ref=month_ref,day_ref=day_ref

  ;AUTHOR: S. Leach
  ;PURPOSE: Return an example schedule struct.

  if n_elements(year_ref) eq 0 then  year_ref  = 2011
  if n_elements(month_ref) eq 0 then month_ref = 12
  if n_elements(day_ref) eq 0 then   day_ref   = 1


  schedule = {schedule}
  dummy    = get_lstschedulefile_firstline(day_ref,month_ref,year_ref,hour_utc=hour_utc)

  schedule.year     = year_ref
  schedule.month    = month_ref
  schedule.day      = day_ref
  schedule.hour_utc = hour_utc

  return,schedule

end
