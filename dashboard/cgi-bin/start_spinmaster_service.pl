#!/usr/bin/perl
use CGI qw(:standard);

my $cgi=new CGI; #read in parameters
my $fm_target_temperature=$cgi->param('fm_target_temperature');
my $reservoir_target_temperature=$cgi->param('reservoir_target_temperature');
my $flow_rate=$cgi->param('flow_rate');
my $run_time=$cgi->param('run_time');

##write parameters to file for the service to use
#my $str = <<END;
#fm_target_temperature=$fm_target_temperature
#reservoir_target_temperature=$reservoir_target_temperature
#flow_rate=$flow_rate
#run_time=$run_time
#END



$url = "/index.html";
print "Location: $url\n\n";
system(`sudo bash -c "echo fm_target_temperature $fm_target_temperature reservoir_target_temperature $reservoir_target_temperature flow_rate $flow_rate run_time $run_time  > tmp/spinmaster_service_env_file"`);
#TODO: write spinmaster_main.service and pass params etc.
#exec("sudo spinmaster_main.sh --fm_target_temperature $fm_target_temperature --reservoir_target_temperature $reservoir_target_temperature --flow_rate $flow_rate --run_time $run_time");
#exec("sudo systemctl start telegraf_spinmaster.service");
exec(`sudo bash -c "echo fm_target_temperature: $fm_target_temperature  > /home/pi/cgi_test.txt"`);
exit;

