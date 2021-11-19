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
  
  #To make sure Grafana starts up even if the Raspberry Pi is restarted,
  #we need to enable and start the Grafana Systemctl service:
  
    sudo /bin/systemctl enable grafana-server
    sudo /bin/systemctl start grafana-server
  
  #grafana should now be available on port 3000
  
  #allow embedding by changing the line allow_embedding = false to allow_embedding = true in /etc/grafana/grafana.ini 
  
    sudo sed 's/;allow_embedding = false/allow_embedding = true/' /etc/grafana/grafana.ini > ./grafana.ini
    sudo cp ./grafana.ini /etc/grafana/grafana.ini
    
    sudo cat << EOF >> /etc/grafana/grafana.ini
    
    ##############SPINMASTER####################
    allow_embedding = true
    auth.anonymous
    enabled = true
    org_name = SpinMaster
    org_role = Viewer
    ###########################################
    EOF
    
    rm ./grafana.ini
    sudo systemctl restart grafana-server.service

# 4. OPTIONAL: LCD SCREEN

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
  




