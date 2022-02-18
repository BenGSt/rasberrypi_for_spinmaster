#dependency: http://abyz.me.uk/rpi/pigpio




main()
{
  arg_parse "$@"

  if ! ps aux | grep pigpiod
  then
    echo starting pigpiod deamon
    sudo pigpiod -s 2 # sample rate 2 [us]
  fi

  printf "Setting DMA PWM:\t"
  printf "GPIO Pin=%d\t" $GPIO
  printf "Frequency=%d[Hz]\t" $FREQUENCY
  printf "Duty Cycle=%d[%]\n" $DUTY_CYCLE


  set_duty_cycle_range 100 # set duty cycle range 0-100 (default is 0-255)
  set_frequency $FREQUENCY
  start_PWM $GPIO $DUTY_CYCLE # Start PWM on pin $GPIO with $DUTY_CYCLE % duty cycle.
}


help()
{
  cat << EOF
  A wrapper for controlling DMA PWM using pigpio pigs cli on raspberry pi.
  Author: Ben Steinberg (2022).

  USAGE: $0 <options>

  options:

    -f|--frequency)
      Each GPIO can be independently set to one of 18 different PWM frequencies.

      The selectable frequencies depend upon the sample rate which may be 1, 2, 4, 5, 8, or 10 microseconds (default 5).
      The sample rate is set when the pigpio daemon is started.
      The frequencies for each sample rate are:

                           Hertz

           1: 40000 20000 10000 8000 5000 4000 2500 2000 1600
               1250  1000   800  500  400  250  200  100   50

           2: 20000 10000  5000 4000 2500 2000 1250 1000  800
                625   500   400  250  200  125  100   50   25

           4: 10000  5000  2500 2000 1250 1000  625  500  400
                313   250   200  125  100   63   50   25   13
    sample
     rate
     (us)  5:  8000  4000  2000 1600 1000  800  500  400  320
                250   200   160  100   80   50   40   20   10

           8:  5000  2500  1250 1000  625  500  313  250  200
                156   125   100   63   50   31   25   13    6

          10:  4000  2000  1000  800  500  400  250  200  160
                125   100    80   50   40   25   20   10    5



    -dc|--duty-cycle)
      In % 0 - 100.

    -p|--gpio)
      the pin to set.

EOF
}

arg_parse()
{
  #defaults
  FREQUENCY=10000
  DUTY_CYCLE=50

  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--frequency)
        FREQUENCY="$2"
        shift # past argument
        shift # past value
        ;;
      -dc|--duty-cycle)
        DUTY_CYCLE="$2"
        shift # past argument
        shift # past value
        ;;
      -p|--gpio)
        GPIO="$2"
        shift # past argument
        shift # past value
        ;;
#      -op|--operation)
#         OPERATION="$2"
#         if [[ "$OPERATION" == "ENABLE" || "$OPERATION" == "DISABLE" || "$OPERATION" == 0 || "$OPERATION" == 1 ]]
#         then
#            shift # past argument
#            shift # past value
#         else
#            exit 1
#         fi
#        ;;
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


set_frequency()
{
#  while [[ get_freq != $1]]
#  do
#    pigs pfs $GPIO $1 # $1 is frequency
#  done
#
  pigs pfs $GPIO $1 # $1 is frequency

}


set_duty_cycle_range()
{
   pigs prs $GPIO $1 # set duty cycle range 0-$1 (default is 0-255)
}

start_PWM()
{
  pigs p $1 $2 # Start PWM on GPIO $1 with $2 dutycycle
}


main "$@"