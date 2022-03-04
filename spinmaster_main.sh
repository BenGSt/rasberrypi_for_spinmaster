#!/usr/bin/bash

PUMP_PWM_GPIO=18
FM_LEFT_PWM_GPIO=17
FM_RIGHT_PWM_GPIO=27
RESERVOIR_HEATER_PWM_GPIO=22

FM_LEFT_THERMISTOR_NUM=0
FM_RIGHT_THERMISTOR_NUM=1
RESERVOIR_HEATER_THERMISTOR_NUM=3

PID_MEASURMENT_AVG_TIME=5s
PID_TIME_ELEMENT_DT=5s

PID_COOLING_Kp=10
PID_COOLING_Ki=0.2
PID_COOLING_Kd=0

PID_HEATING_Kp=
PID_HEATING_Ki=
PID_HEATING_Kd=

PUMP_PWM_FREQUENCY=20000

main()
{
  arg_parse "$@"
  trap shutdown EXIT #shutdown executed on exit from the shell
  startup
  sleep $RUN_TIME
#  shutdown
}


startup()
{
    export PATH="/home/pi/raspberrypi_for_SpinMaster/thermoelectric_cooler_control:$PATH"
    begin_date_time=$(date +%s)

    #start telegraf (posts measurements to DB)
    sudo systemctl start telegraf_spinmaster.service

    #start TEC cooling
      pid_tec.sh --gpio $FM_LEFT_PWM_GPIO --thermistor_num $FM_LEFT_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
                   --time_element_dt 5s --desired_temperature $FM_TEMP_LEFT -Kp $PID_COOLING_Kp -Ki $PID_COOLING_Ki -Kd $PID_COOLING_Kd

      pid_tec.sh --gpio $FM_RIGHT_PWM_GPIO --thermistor_num $FM_RIGHT_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
                   --time_element_dt 5s --desired_temperature $FM_TEMP_RIGHT -Kp $PID_COOLING_Kp -Ki $PID_COOLING_Ki -Kd $PID_COOLING_Kd

    #sart TEC heating
      pid_tec.sh --gpio $RESERVOIR_HEATER_PWM_GPIO --heating-mode --thermistor_num 1 --averaging-time $PID_MEASURMENT_AVG_TIME \
                  --time_element_dt 5s --desired_temperature $RESERVOIR_TARGET_TEMP -Kp $PID_HEATING_Kp -Ki $PID_HEATING_Ki -Kd $PID_HEATING_Kd

    #sart pump
#      TODO: PUMP_PWM_DUTYCYCLE = f($FLOW_RATE)
      PUMP_PWM_DUTYCYCLE=$FLOW_RATE
      dma_pwm.sh --frequency $PUMP_PWM_FREQUENCY --duty-cycle $PUMP_PWM_DUTYCYCLE --gpio $PUMP_PWM_GPIO

    #TODO: if [[ use_laser ]]
      #start laser

}


shutdown()
{
    end_date_time=$(date +%s)
    run_time=$(($end_date_time - $begin_date_time))
    echo finished spinmaster run. runtime: $run_time

    #stop all PWMs
    for pin in $PUMP_PWM_GPIO $FM_LEFT_PWM_GPIO $FM_RIGHT_PWM_GPIO $RESERVOIR_HEATER_PWM_GPIO
    do
      pigs w $pin 0 #write 0 to pin
    done

    #stop telegraf (posts measurements to DB)
    sudo systemctl stop telegraf_spinmaster.service


    # issue report
    time_grouping="2s"
    influx -execute "SELECT mean(*) FROM \"exe_thermistors_logfmt\" WHERE time >= now() - $run_time  and time <= now() GROUP BY time($time_grouping) fill(null)" -database="home"
    #save the run's data}
}


help()
{
  cat << EOF
    --fm_target_temperature
    --reservoir_target_temperature
    --flow_rate
    --run_time
    -h|--help
EOF
}


arg_parse()
{
  while [[ $# -gt 0 ]]; do
    case $1 in
      --fm_target_temperature)
        FM_TARGET_TEMP="$2"
        FM_TEMP_LEFT=$FM_TARGET_TEMP
        FM_TEMP_RIGHT=$FM_TARGET_TEMP
        shift # past argument
        shift # past value
        ;;
      --reservoir_target_temperature)
        RESERVOIR_TARGET_TEMP="$2"
        shift # past argument
        shift # past value
        ;;
      --flow_rate)
        FLOW_RATE="$2"
        shift # past argument
        shift # past value
        ;;
      --run_time)
        RUN_TIME="$2"
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

main "$@"