#!/usr/bin/bash

main()
{
  begin_date_time=get_datetime

  #start telegraf (posts measurements to DB)
  sudo systemctl start telegraf_spinmaster.service

  #start TEC cooling
  #sart TEC heating
  #sart pump
  if [[use laser]]
    #start laser

  #issue report
  #save the run's data
}