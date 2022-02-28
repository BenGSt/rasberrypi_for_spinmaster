#!/usr/bin/perl
$url = "/index.html";
print "Location: $url\n\n";
exec("sudo systemctl stop telegraf_spinmaster.service");
exit;





