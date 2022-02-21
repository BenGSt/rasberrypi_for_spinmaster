# cgi backend scripts
sudo cp ./dashboard/cgi-bin/* /usr/local/apache2/cgi-bin/
sudo chmod a+x /usr/local/apache2/cgi-bin/*

#control panel web page

sudo cp ./dashboard/webpage_with_embedded_grafana_dashboard.html /var/www/html/index.html

# edit  /etc/apache2/sites-available/000-default.conf
sudo cp ./dashboard/apache_000-default.conf  /etc/apache2/sites-available/000-default.conf

#resart apache
sudo apachectl -k graceful