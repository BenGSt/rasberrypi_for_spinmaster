#!/usr/bin/bash

main()
{
  mkdir TEC_test_results
  OUT_FILE=TEC_test_results/TEC_test_results_`date +"%m-%d-%Y"`.csv
  FREQUENCY=20000

  printf Frequency"\t"Duty_Cycle"\t"Temp"\t"Room_Temp"\n" | tee -a $OUT_FILE  # header


  for DUTY_CYCLE in `seq 5 5 100`
  do
    ./hardware_pwm_via_sysfs.sh --channel 0 --operation ENABLE --frequency $FREQUENCY --duty-cycle $DUTY_CYCLE
    sleep 5m

    #using the python script messed up readings
#    TEMP=`sudo -u pi python /home/pi/raspberrypi_for_SpinMaster/sensors/thermistor_adc/read_thermistors.py | cut -f 2 | awk -F"=" '{print $2}'`
#    ROOM_TEMP=`sudo -u pi python /home/pi/raspberrypi_for_SpinMaster/sensors/thermistor_adc/read_thermistors.py | cut -f 3 | awk -F"=" '{print $2}'`

    #get readings from DB (mean of last 1m)
    TEMP=`sudo influx -execute "SELECT mean("Tc_thermistor1") FROM "exe_thermistors_logfmt" WHERE time >= now() - 1m and time <= now() GROUP BY time(1m) fill(null)" -database="home" |awk 'NR==4 {printf("%.1f", $2)}'`
    ROOM_TEMP=`sudo influx -execute "SELECT mean("Tc_thermistor0") FROM "exe_thermistors_logfmt" WHERE time >= now() - 1m and time <= now() GROUP BY time(1m) fill(null)" -database="home" |awk 'NR==4 {printf("%.1f", $2)}'`

    printf $FREQUENCY"\t"$DUTY_CYCLE"\t"$TEMP"\t"$ROOM_TEMP"\n" | tee -a $OUT_FILE
  done
}

main