#!/usr/bin/perl

use CGI qw(:standard);

my $cgi=new CGI; #read in parameters
my $fm_target_temperature=$cgi->param('fm_target_temperature');
my $reservoir_target_temperature=$cgi->param('reservoir_target_temperature');
my $flow_rate=$cgi->param('flow_rate');
my $run_time=$cgi->param('run_time');

$url = "/index.html";
print "Location: $url\n\n";

exec("sudo systemctl start telegraf.service");
exit;

#print "Content-type: text/html\n\n";
#print <<ENDHTML;
#<HTML>
#<HEAD>
#<TITLE>CGI Test</TITLE>
#</HEAD>
#<BODY>
#fm_target_temperature:  $fm_target_temperature
#<BR>
#reservoir_target_temperature:  $reservoir_target_temperature
#<BR>
#flow_rate:  $flow_rate
#<BR>
#run_time:  $run_time
#<BR>
#<A HREF="/index.html">Return to Control Panel</A>
#</BODY>
#</HTML>

#ENDHTML

