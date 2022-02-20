#!/usr/bin/bash

main()
{
  arg_parse "$@"
  previous_error=0
  integral=0

  while 1
    do
      measured_temp=`influx -execute "SELECT mean(\"Tc_thermistor$THERMISTOR_NUM\") FROM \"exe_thermistors_logfmt\" WHERE time >= now() - $AVG_TIME and time <= now() GROUP BY time(1m) fill(null)" -database="home" |awk 'NR==4 {printf("%.1f", $2)}'`
      error=$(( setpoint − measured_value ))
      proportional=error
      integral=$(( (integral + error) * dt ))
      derivative$(( (error − previous_error) / dt ))
      output= $(( Kp * proportional + Ki * integral + Kd * derivative))
      previous_error=error
  #    sleep dt
    done
}


arg_parse()
{
  while [[ $# -gt 0 ]]; do
    case $1 in
      -n|--thermistor_num)
        THERMISTOR_NUM="$2"
        shift # past argument
        shift # past value
        ;;
      -dt|--time_element_dt)
        dt="$2"
        shift # past argument
        shift # past value
        ;;
      -avg|--averaging-time)
        AVG_TIME="$2"
        shift # past argument
        shift # past value
        ;;
      -t|--desired_temperature)
        setpoint="$2"
        shift # past argument
        shift # past value
        ;;
      -Kp|--proportional_coefficient)
        Kp="$2"
        shift # past argument
        shift # past value
        ;;
      -Ki|--integral_coefficient)
        Ki="$2"
        shift # past argument
        shift # past value
        ;;
      -Kd|--derivative_coefficient)
        Kd="$2"
        shift # past argument
        shift # past value
        ;;

    esac
  done
}

main "$@"
