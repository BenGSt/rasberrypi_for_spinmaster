#!/usr/bin/perl
#$url = "/index.html";
#print "Location: $url\n\n";
#exec("sudo systemctl stop telegraf_spinmaster.service");

print "Content-type: text/html\n\n";
print "<HTML><HEAD>\n";
print "<TITLE>CGI Test</TITLE>\n";
print "</HEAD>\n";
print "<BODY><A HREF=\"http://someplace.com\">Click Here</A>\n";
print "</BODY></HTML>";

exit;





