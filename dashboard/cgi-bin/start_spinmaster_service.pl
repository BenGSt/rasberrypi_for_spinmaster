#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);

my $cgi=new CGI; #read in parameters
my $fm_target_temperature=$cgi->param('fm_target_temperature');
my $reservoir_target_temperature=$cgi->param('reservoir_target_temperature');
my $flow_rate=$cgi->param('flow_rate');
my $run_time=$cgi->param('run_time');

#write parameters to file for the service to use
#my $str = <<END;
#fm_target_temperature=$fm_target_temperature
#reservoir_target_temperature=$reservoir_target_temperature
#flow_rate=$flow_rate
#run_time=$run_time
#END
#
#my $filename = '/tmp/spin_master_service_environment_file';
#open(FH, '>', $filename) or die $! , "died";
#print FH $str;
#close(FH);


my $url = "/index.html";
print "Location: $url\n\n";

#system("echo fm_target_temperature=$fm_target_temperature > /tmp/spin_master_service_environment_file");
#system("printf ""fm_target_temperature="$fm_target_temperature", \nreservoir_target_temperature="$reservoir_target_temperature", \nflow_rate="$flow_rate", \nrun_time="$run_time" > /tmp/spin_master_service_environment_file2");
#TODO: write spinmaster_main.service and pass params etc.
#exec("sudo spinmaster_main.sh --fm_target_temperature $fm_target_temperature --reservoir_target_temperature $reservoir_target_temperature --flow_rate $flow_rate --run_time $run_time");
exec("sudo systemctl start telegraf_spinmaster.service");
exec(`sudo bash -c "echo fm_target_temperature: $fm_target_temperature  > /home/pi/cgi_test.txt"`);
exit;

