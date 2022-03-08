#! /bin/sh
i=0;
for sensor in `realpath  /sys/bus/w1/devices/28*/temperature`;
 do echo Tc_digital_temp_sensor_$i=`cat $sensor| sed 's/\([0-9][0-9]\)\(.*\)/\1\.\2/'`;
    i=$((i+1));
 done
