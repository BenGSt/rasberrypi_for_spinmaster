# cgi backend scripts
sudo cp ./dashboard/cgi-bin/* /usr/local/apache2/cgi-bin/
sudo chmod a+x /usr/local/apache2/cgi-bin/*

#control panel web page
sed "s/192\.[0-9]*\.[0-9]*\.[0-9]*/$(hostname -I |cut -f 1| tr -d [:blank:])/" ./dashboard/webpage_with_embedded_grafana_dashboard.html  > /tmp/dashboard.html
sudo cp /tmp/dashboard.html /var/www/html/index.html

# edit  /etc/apache2/sites-available/000-default.conf
sudo cp ./dashboard/apache_000-default.conf  /etc/apache2/sites-available/000-default.conf

#resart apache
sudo apachectl -k graceful

#spinmaster systemd services
sudo cp ./spinmaster_lcd/spinmaster_lcd_ip.service /lib/systemd/system/
sudo cp  ./run/spinmaster_main.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart spinmaster_lcd_ip.service