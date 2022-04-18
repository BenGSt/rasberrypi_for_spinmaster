#!/usr/bin/perl

$url = "/index.html";
print "Location: $url\n\n";
#exec("sudo systemctl stop telegraf_spinmaster.service");
exec("sudo systemctl stop spinmaster_main.service");
exec("sudo /home/pi/raspberrypi_for_SpinMaster/run/shutdown_spinmaster_failsafe.sh > /home/pi/spinmaster_failsafe_last_run.log 2>&1 ");
exit;





