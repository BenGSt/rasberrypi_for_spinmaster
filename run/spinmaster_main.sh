#!/usr/bin/bash

PUMP_PWM_GPIO=18
FM_LEFT_PWM_GPIO=17
FM_RIGHT_PWM_GPIO=27
RESERVOIR_HEATER_PWM_GPIO=22

FM_LEFT_THERMISTOR_NUM=0
FM_RIGHT_THERMISTOR_NUM=1
RESERVOIR_HEATER_THERMISTOR_NUM=3

PID_MEASURMENT_AVG_TIME=5s
PID_TIME_ELEMENT_DT=4

PID_COOLING_Kp=120
PID_COOLING_Ki=0.03
PID_COOLING_Kd=25

PID_HEATING_Kp=120
PID_HEATING_Ki=0.03
PID_HEATING_Kd=25

PUMP_PWM_FREQUENCY=20000
#TEC_PWM_FREQUENCY=20000 # this is set in pid_tec.sh

GROUP_BY_TIME_FINAL_REPORT_DATA="2s"


main()
{
  set -eE # exit on any command failure
  arg_parse "$@"
  print_start_message
  trap shutdown_ EXIT #shutdown executed on exit from the shell
  startup
  sleep $RUN_TIME
#  shutdown
}


startup()
{
    log_dir=$(date | sed 's/ /_/g' | awk '{print "SpinMaster_run_logs_"$0}')
    mkdir /home/pi/$log_dir
    log_dir=/home/pi/$log_dir

    export PATH="/home/pi/raspberrypi_for_SpinMaster/thermoelectric_cooler_control:$PATH"
    begin_date_time=$(date +%s)

    #start telegraf (posts measurements to DB)
    sudo systemctl start telegraf_spinmaster.service
    sleep 5

    if [ ! -e /home/pi/polarimeter.log ]
    then
      mkfifo /home/pi/polarimeter.log #named pipe
    fi

    python3 /home/pi/raspberrypi_for_SpinMaster/sensors/polarimeter/polarimeter.py > /home/pi/polarimeter.log &
    sudo systemctl start telegraf_polarimeter.service
    sleep 5


    #start TEC cooling
     # echo pid_tec.sh --gpio $FM_LEFT_PWM_GPIO --thermistor_num $FM_LEFT_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
      #             --time_element_dt $PID_TIME_ELEMENT_DT --desired_temperature $FM_TEMP_LEFT -Kp $PID_COOLING_Kp -Ki $PID_COOLING_Ki -Kd $PID_COOLING_Kd

      pid_tec.sh --gpio $FM_LEFT_PWM_GPIO --thermistor_num $FM_LEFT_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
                   --time_element_dt $PID_TIME_ELEMENT_DT --desired_temperature $FM_TEMP_LEFT -Kp $PID_COOLING_Kp -Ki $PID_COOLING_Ki -Kd $PID_COOLING_Kd > $log_dir/fm_left_pid.log 2>&1 &

      pid_tec.sh --gpio $FM_RIGHT_PWM_GPIO --thermistor_num $FM_RIGHT_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
                  --time_element_dt $PID_TIME_ELEMENT_DT --desired_temperature $FM_TEMP_RIGHT -Kp $PID_COOLING_Kp -Ki $PID_COOLING_Ki -Kd $PID_COOLING_Kd > $log_dir/fm_right_pid.log 2>&1 &

#    start TEC heating
      pid_tec.sh --gpio $RESERVOIR_HEATER_PWM_GPIO --heating-mode --thermistor_num $RESERVOIR_HEATER_THERMISTOR_NUM --averaging-time $PID_MEASURMENT_AVG_TIME \
                  --time_element_dt $PID_TIME_ELEMENT_DT --desired_temperature $RESERVOIR_TARGET_TEMP -Kp $PID_HEATING_Kp -Ki $PID_HEATING_Ki -Kd $PID_HEATING_Kd > $log_dir/heater_pid.log 2>&1 &

    #start pump
      #TODO: PUMP_PWM_DUTYCYCLE = f($FLOW_RATE)
      #PUMP_PWM_DUTYCYCLE=$FLOW_RATE
      #dma_pwm.sh --frequency $PUMP_PWM_FREQUENCY --duty-cycle $PUMP_PWM_DUTYCYCLE --gpio $PUMP_PWM_GPIO &



}


shutdown_()
{
    end_date_time=$(date +%s)
    ran_time=$(($end_date_time - $begin_date_time))
    cp /home/pi/spinmaster_service_env_file $log_dir/run_params.log


    echo  ps aux \| grep pid_tec.sh :
    ps aux | grep pid_tec.sh

    if [[ $(ps aux | grep pid_tec.sh | grep -v grep | awk '{print $2}') ]]
      then
        echo killing pid_tec.sh instances
        kill $(ps aux | grep pid_tec.sh | grep -v grep | awk '{print $2}')
    fi

    echo writing 0 to pins
    for pin in $PUMP_PWM_GPIO $FM_LEFT_PWM_GPIO $FM_RIGHT_PWM_GPIO $RESERVOIR_HEATER_PWM_GPIO
    do
      pigs w $pin 0 #write 0 to pin
      echo pigs w $pin 0 #write 0 to pin
    done

    echo stop telegraf \(posts measurements to DB\)
    sudo systemctl stop telegraf_spinmaster.service
    sudo systemctl stop telegraf_polarimeter.service

    echo getting thermistor logs now - $ran_time
    influx -execute "SELECT mean(*) FROM \"exe_thermistors_logfmt\" WHERE time >= now() - $ran_time  and time <= now() GROUP BY time($GROUP_BY_TIME_FINAL_REPORT_DATA) fill(null)" -database="home" > $log_dir/thermistors.log
    #TODO: save the run's data}

    echo
    echo \################################################
    echo Finished spinmaster run. Ran for: $ran_time sec
    echo Thank you for flying SpinMaster, have a nice day!
    echo \################################################

}

print_start_message()
{
  echo \################################################
  echo Starting SpinMaster run with the following parameters:
  echo
  echo   \#command line args
  echo   FM_TARGET_TEMP=$FM_TARGET_TEMP
  echo   RESERVOIR_TARGET_TEMP=$RESERVOIR_TARGET_TEMP
  echo   FLOW_RATE=$FLOW_RATE
  echo   RUN_TIME=$RUN_TIME
  echo
  echo   \#set in script
  echo   PUMP_PWM_GPIO=$PUMP_PWM_GPIO
  echo   FM_LEFT_PWM_GPIO=$FM_LEFT_PWM_GPIO
  echo   FM_RIGHT_PWM_GPIO=$FM_RIGHT_PWM_GPIO
  echo   RESERVOIR_HEATER_PWM_GPIO=$RESERVOIR_HEATER_PWM_GPIO
  echo
  echo   FM_LEFT_THERMISTOR_NUM=$FM_LEFT_THERMISTOR_NUM
  echo   FM_RIGHT_THERMISTOR_NUM=$FM_RIGHT_THERMISTOR_NUM
  echo   RESERVOIR_HEATER_THERMISTOR_NUM=$RESERVOIR_HEATER_THERMISTOR_NUM
  echo
  echo   PID_MEASURMENT_AVG_TIME=$PID_MEASURMENT_AVG_TIME
  echo   PID_TIME_ELEMENT_DT=$PID_TIME_ELEMENT_DT
  echo
  echo   PID_COOLING_Kp=$PID_COOLING_Kp
  echo   PID_COOLING_Ki=$PID_COOLING_Ki
  echo   PID_COOLING_Kd=$PID_COOLING_Kd
  echo
  echo   PID_HEATING_Kp=$PID_HEATING_Kp
  echo   PID_HEATING_Ki=$PID_HEATING_Ki
  echo   PID_HEATING_Kd=$PID_HEATING_Kd
  echo
  echo   PUMP_PWM_FREQUENCY=$PUMP_PWM_FREQUENCY
  echo   GROUP_BY_TIME_FINAL_REPORT_DATA=$GROUP_BY_TIME_FINAL_REPORT_DATA
  echo
  echo Good luck...
  echo \################################################
  echo
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
