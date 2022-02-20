#!/usr/bin/bash

help()
{
  cat << EOF
  A PID control script for TECs in the SpinMaster project.
  Author: Ben Steinberg (2022).

  USAGE: $0 <options>

  options:
      -n|--thermistor_num)

      -dt|--time_element_dt)

      -avg|--averaging-time)

      -t|--desired_temperature)

      -Kp|--proportional_coefficient)

      -Ki|--integral_coefficient)

      -Kd|--derivative_coefficient)
EOF
}

main()
{
  arg_parse "$@"
  previous_error=0
  integral=0
  max_pwm_duty_cycle=100

  i=3
  while [[ i -gt 0 ]]
    do
      measured_temp=`influx -execute "SELECT mean(\"Tc_thermistor$THERMISTOR_NUM\") FROM \"exe_thermistors_logfmt\" WHERE time >= now() - $AVG_TIME and time <= now() GROUP BY time(1m) fill(null)" -database="home" |awk 'NR==4 {printf("%.1f", $2)}'`
      echo measured_temp=`influx -execute "SELECT mean(\"Tc_thermistor$THERMISTOR_NUM\") FROM \"exe_thermistors_logfmt\" WHERE time >= now() - $AVG_TIME and time <= now() GROUP BY time(1m) fill(null)" -database="home" |awk 'NR==4 {printf("%.1f", $2)}'`
      error=$(bc -l <<< "$measured_temp - $setpoint" )
      echo error=$(bc -l <<< "$setpoint - $measured_temp" )
      proportional=$error
      echo proportional=$error
      integral=$(bc -l <<< "($integral + $error) * $dt" )
      echo integral=$(bc -l <<< "($integral + $error) * $dt" )
      derivative=$( bc -l <<< "($error - $previous_error) / $dt" )
      echo derivative=$( bc -l <<< "($error - $previous_error) / $dt" )
      output=$(bc -l <<< "$Kp * $proportional + $Ki * $integral + $Kd * $derivative")
      echo output=$(bc -l <<< "$Kp * $proportional + $Ki * $integral + $Kd * $derivative")
      previous_error=$error
      echo previous_error=$error

      if bc -l <<< "output > max_pwm_duty_cycle"
        then
          echo max_pwm_duty_cycle: $max_pwm_duty_cycle
        output_pwm_duty_cycle=100
        echo output_pwm_duty_cycle: $output_output_pwm_duty_cycle
      else
        output_pwm_duty_cycle=$(bc -l <<< "scale=0; $output / 1")
      fi

      echo output_pwm_duty_cycle=$output_output_pwm_duty_cycle

      sleep $dt

    i=$(( i - 1 ))
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
