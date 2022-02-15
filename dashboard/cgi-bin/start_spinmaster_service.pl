#!/usr/bin/perl
$url = "/index.html";
print "Location: $url\n\n";
exec("sudo systemctl start telegraf.service");
exit;
