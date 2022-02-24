#!/usr/bin/bash

PUMP_PWM_GPIO=
FM_LEFT_THERMISTOR_NUM=0
FM_LEFT_PWM_GPIO=
FM_RIGHT_THERMISTOR_NUM=1
FM_RIGHT_PWM_GPIO=
RESERVOIR_HEATER_THERMISTOR_NUM=2
RESERVOIR_HEATER_PWM_GPIO=

PID_MEASURMENT_AVG_TIME=5s
PID_TIME_ELEMENT_DT=5s

PID_COOLING_Kp=
PID_COOLING_Ki=
PID_COOLING_Kd=

PID_HEATING_Kp=
PID_HEATING_Ki=
PID_HEATING_Kd=

main()
{
  #startup
    begin_date_time=get_datetime

    #start telegraf (posts measurements to DB)
    sudo systemctl start telegraf_spinmaster.service

    #start TEC cooling
      pid_tec.sh --gpio $FM_LEFT_PWM_GPIO --thermistor_num $FM_LEFT_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
                   --time_element_dt 5s --desired_temperature $FM_TEMP_LEFT -Kp $PID_COOLING_Kp -Ki $PID_COOLING_Ki -Kd $PID_COOLING_Kd

      pid_tec.sh --gpio $FM_RIGHT_PWM_GPIO --thermistor_num $FM_RIGHT_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
                   --time_element_dt 5s --desired_temperature $FM_TEMP_RIGHT -Kp $PID_COOLING_Kp -Ki $PID_COOLING_Ki -Kd $PID_COOLING_Kd

    #sart TEC heating
      pid_tec.sh --gpio $RESERVOIR_HEATER_PWM_GPIO --heating-mode --thermistor_num 1 --averaging-time $PID_MEASURMENT_AVG_TIME \
                  --time_element_dt 5s --desired_temperature -Kp $PID_HEATING_Kp -Ki $PID_HEATING_Ki -Kd $PID_HEATING_Kd

    #sart pump
      dma_pwm.sh --frequency $PUMP_PWM_FREQUENCY --duty-cycle $PUMP_PWM_DUTYCYCLE --gpio $PUMP_PWM_GPIO

    if [[ use_laser ]]
      #start laser

}



shutdown()
{
    while [[current time < end_time]]
      sleep 5m

    #stop all PWMs
    sudo killall pigpio

    #stop telegraf (posts measurements to DB)
    sudo systemctl stop telegraf_spinmaster.service


    # issue report
    #save the run's data}
}


arg_parse()
{
  while [[ $# -gt 0 ]]; do
    case $1 in
      --fm_target_temperature)
        FM_TARGET_TEMP="$2"
        FM_TEMP_LEFT=$FM_TARGET_TEMP
        FM_TEMP_RIGHT$FM_TARGET_TEMP
        shift # past argument
        shift # past value
        ;;

      -*|--*)
        help
        exit 1
        ;;
      -h|--help)
        help
        exit 1
        ;;
    esac
  done
}