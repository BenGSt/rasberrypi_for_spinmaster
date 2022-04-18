#!/usr/bin/bash

PUMP_PWM_GPIO=18
FM_LEFT_PWM_GPIO=27
FM_RIGHT_PWM_GPIO=17
RESERVOIR_HEATER_PWM_GPIO=22

shutdown_()
{
  #TODO:print output to some log
  sudo systemctl stop spinmaster_main.service
  echo  ps aux \| grep spinmaster_main.sh :
  ps aux | grep spinmaster_main.sh

  if [[ $(ps aux | grep spinmaster_main.sh | grep -v grep | awk '{print $2}') ]]
      then
        echo killing spinmaster_main.sh instances
        kill $(ps aux | grep spinmaster_main.sh | grep -v grep | awk '{print $2}')
    fi

    echo  ps aux \| grep pid_tec.sh :
    ps aux | grep pid_tec.sh

    if [[ $(ps aux | grep pid_tec.sh | grep -v grep | awk '{print $2}') ]]
      then
        echo killing pid_tec.sh instances
        kill $(ps aux | grep pid_tec.sh | grep -v grep | awk '{print $2}')
    fi

# #dont need this block because pwm can be killed by writing 0 to pin once
#    if [[ $(ps aux | grep dma_pwm.sh | grep -v grep | awk '{print $2}') ]]
#          then
#            echo killing dma_pwm.sh instances
#            kill $(ps aux | grep dma_pwm.sh | grep -v grep | awk '{print $2}')
#    fi

    echo writing 0 to pins
    for pin in $PUMP_PWM_GPIO $FM_LEFT_PWM_GPIO $FM_RIGHT_PWM_GPIO $RESERVOIR_HEATER_PWM_GPIO
    do
      while ! pigs w $pin 0 ; do #write 0 to pin
          sudo pigpiod -s 2
          echo pigpiod failed - restarting it
      done

      echo pigs w $pin 0 #write 0 to pin
    done

    echo stop telegraf \(posts measurements to DB\)
    sudo systemctl stop telegraf_spinmaster.service
    sudo systemctl stop telegraf_polarimeter.service


    echo SPINMASTER_RUNNING=0 > /home/pi/raspberrypi_for_SpinMaster/spinmaster_lcd/enviroment_variables_for_lcd_service

    echo
    echo \################################################
         date
    echo This is spinmaster emergency fail-safe shutdown
    echo Thank you for flying SpinMaster, have a nice day!
    echo \################################################

}

shutdown_