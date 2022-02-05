#!/usr/bin/env bash

exit 1
main()
{
  arg_parse "$@"
}

help()
{
  cat << EOF
  A utility for controlling hardware PWM on raspberry pi.
  Author: Ben Steinberg (2022).

  USAGE: $0 <options>

  options:

    -f|--frequency)
      In Hz.
      The kernel module technically allows to set max frequency =~ 67 [Mhz] (T = 15 [ns] ), and no minimum.
      In practice I could not get a frequency lower than 1 Hz, And I haven't tested the max yet (as of 5.02.2022).
      Theoretically this frequency is derived from the "oscillator" (some cristal oscillator?) which runs at 19.2 Mhz
      and uses a 12 bit devisor (probably implemented as a FF counter) with max value 4095. This means that we should
      be able to generated frequencies between 4688 Hz and 19.2 Mhz. Some sources state unexpected behaviour
      with frequencies below 4688Hz and above 9.6Mhz (19.2 / 2).

      See:
      https://youngkin.github.io/post/pulsewidthmodulationraspberrypi/#overview-of-pwm-on-a-raspberry-pi-3b


    -dc|--duty-cycle)
      In % 0 - 100.

    -c|--channel)
      0 or 1.
      The bcm 2837b0 offers 2 PWM channels availabe on 2 pins each, chan 0: 18/12, chan 1: 19/13
      (actually this was true for bcm 2835 and 2837 may offer a few more pins, I'm not sure.)

    -op||--operation)
      one of:
        export - creates the system files e.g. /sys/class/pwm/pwmchip0/pwm0/*
        enable - turns channel on
        disable - turns channel off.
EOF
}

arg_parse()
{
  #defaults
  FREQUENCY = 10000
  DUTY_CYCLE = 50
  CHANNEL = 0
  OPERATION = "enable"

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
      -c|--channel)
        CHANNEL="$2"
        shift # past argument
        shift # past value
        ;;
      -op|--operation)
        OPERATION="$2"
        shift # past argument
        shift # past value
        ;;
      -*|--*)
        help();
        exit
        ;;
      -h|--help)
        help();
        exit
        ;;
    esac
  done
}
