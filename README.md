# rasberrypi_for_spinmaster
raspberry pi setup for SpinMaster project


# 1.**connect to network**
for now I just used GUI 

# 2. **setup ssh**
    sudo raspi-config

#under interface options enable ssh

# 3. **install grafana**
  #Add the APT key used to authenticate packages:
  
     wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

  #Add the Grafana APT repository:
  
     echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

  #Install Grafana:
  
    sudo apt-get update
    sudo apt-get install -y grafana
  
    # To make sure Grafana starts up even if the Raspberry Pi is restarted,
    # we need to enable and start the Grafana Systemctl service:
    sudo /bin/systemctl enable grafana-server
    sudo /bin/systemctl start grafana-server
  
    # grafana should now be available on port 3000 with username: admin, password: admin.
   
    # allow embedding by editing /etc/grafana/grafana.ini
    sudo cp ./dashboard/grafana.ini /etc/grafana/grafana.ini
    sudo systemctl restart grafana-server.service
    
  #Add the built dashboards (raspi monitoring, spinmaster) using GUI to import json
    #TODO: automate this step
# 4. Set up apache2 webserver to serve the SpinMaster web interface.

    
    sudo apt install -y apache2
    sudo cp ./dashboard/webpage_with_embedded_grafana_dashboard.html /var/www/html/index.html
    
    # Note you have to change the ip address in webpage_with_embedded_grafana_dashboard.html to machines ip.
    # TODO: automate using generic, enviormental variable, or sed. 
  

# 5. Install influxdb DB 
   #add Influx repositories to apt:
   
    wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
    source /etc/os-release
    echo "deb https://repos.influxdata.com/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
    
   #Update apt with the new repos, & install.
   
    sudo apt update && sudo apt install -y influxdb
    
   #start the influxdb service and set it to run at boot:
   
    sudo systemctl unmask influxdb.service
    sudo systemctl start influxdb
    sudo systemctl enable influxdb.service
    
   #run the influx client and create a user
   
    influx
    create database home
    use home
    create user grafana with password '' with all privileges
    grant all privileges on home to grafana
    exit
    
   
   
# 6. telegraf - posts data to DB
	curl -sL https://repos.influxdata.com/influxdb.key |sudo apt-key add -
	DISTRIB_ID=$(lsb_release -c -s)
	echo "deb https://repos.influxdata.com/debian ${DISTRIB_ID} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
	
	sudo apt-get update
	sudo apt-get install -y telegraf
	
	#Add the user telegraf to the video group to allow telegraf to recollect info of the GPU temperature
	sudo usermod -aG video telegraf
	
	#Add capabilities to the “ping” binary to allow telegraf to execute ping checks
	sudo setcap 'cap_net_admin,cap_net_raw+ep' $(which ping)
	
	sudo cp ./dashboard/telegraf.conf /etc/telegraf/telegraf.conf
	sudo systemctl restart telegraf
	
   #add inluxdb data source via grafana web interface:
   
   #url: http://localhost:8086 , Database: home, User: grafana
   
   #example usage with [input.tail] set up in telegraf.conf :  
   
  	 python3 sensors/thermistor_adc/get_temp_test.py > /home/pi/thermistor_adc/thermistor_0.log &
	
	

# 7. shellinabox - web based SSH emulator

	sudo apt-get install shellinabox
   
# 8. set up ADC


# 9. set up digital temperature sensors (DS18B20)
  #enable one-wire interface 
    # sudo raspi-config
    #choose interface options -> 1-wire

    # load modules to the kernel
    sudo modprobe w1_therm
    sudo modprobe w1_gpio

    # cat /boot/overlays/README  # documentation about the 'dtoverlay' feature and its syntax
    dtoverlay=w1-gpio,gpiopin=4
    
    # make sure internal pull up resistor is up (can also be done on python code) 
    sudo raspi-gpio set 4 pu

    # at this point machine may need to be rebooted

  #read temperatures (once for each sensor, assuming no other 1-w devices on machine)
    #  i=0; for sensor in `realpath  /sys/bus/w1/devices/28*/temperature`; do echo Tc_digital_temp_sensor_$i `cat $sensor| sed 's/\([0-9][0-9]\)\(.*\)/\1\.\2/'`; i=$((i+1)); done


# 5. OPTIONAL: LCD SCREEN

#TODO make the python script accept command line args for more flexibility 

  #first run setup as explained in:

	# https://github.com/the-raspberry-pi-guy/lcd.git
	# https://www.youtube.com/watch?v=3XLjVChVgec
  #the /the-raspberry-pi-guy/lcd repository is already in ./spinmaster_lcd/lcd



  #add systemd unit file
  
     sudo cp /home/pi/rasberrypi_for_spinmaster/spinmaster_lcd/spinmaster_lcd_ip.service /lib/systemd/system/
  #note: should use relative path here for better portability  
  
  
  #enable 
  
    sudo systemctl daemon-reload
    sudo systemctl enable spinmaster_lcd_ip.service
  
  #to see the text on lcd start now or rebbot
  
    #sudo systemctl start spinmaster_lcd_ip.service
    
    #sudo reboot
  
# Useful tools:

	sudo apt install i2c-tools



