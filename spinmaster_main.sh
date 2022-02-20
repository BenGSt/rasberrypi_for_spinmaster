#!/usr/bin/bash

main()
{
  #startup
    begin_date_time=get_datetime

    #start telegraf (posts measurements to DB)
    sudo systemctl start telegraf_spinmaster.service

    #start TEC cooling
      pid_tec.sh --thermistor_num 0 --averaging-time 5s --time_element_dt 5s --desired_temperature -Kp -Ki -Kd
      pid_tec.sh --thermistor_num 1 --averaging-time 5s --time_element_dt 5s --desired_temperature -Kp -Ki -Kd

    #sart TEC heating

    #sart pump
      dma_pwm.sh --frequency $PUMP_PWM_FREQUENCY --duty-cycle $PUMP_PWM_DUTYCYCLE --gpio $PUMP_PWM_GPIO

    if [[ use_laser ]]
      #start laser


  #shutdown
    while [[current time < end_time]]
      sleep 5m

    #stop all PWMs
    sudo killall pigpio

    #stop telegraf (posts measurements to DB)
    sudo systemctl stop telegraf_spinmaster.service


    # issue report
    #save the run's data
}
}