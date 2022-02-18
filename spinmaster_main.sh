#!/usr/bin/bash

main()
{
  begin_date_time=get_datetime

  #start telegraf (posts measurements to DB)
  sudo systemctl start telegraf_spinmaster.service

  #start TEC cooling
  #sart TEC heating

  #sart pump
    dma_pwm.sh --frequency $PUMP_PWM_FREQUENCY --duty-cycle $PUMP_PWM_DUTYCYCLE --gpio $PUMP_PWM_GPIO
  if [[use laser]]
    #start laser

  while [[current time < end_time]]
    sleep 5m

  #stop all PWMs
  sudo killall pigpio

  # issue report
  #save the run's data
}