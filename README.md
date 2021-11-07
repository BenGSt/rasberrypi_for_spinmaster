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


# 4. OPTIONAL: LCD SCREEN

#make lcd display IP on startup

  #add systemd unit file
  
  sudo cp /home/pi/spinmaster_lcd/spinmaster_lcd_show_ip_once.service /lib/systemd/system/
  
  
  
  #enable 
  
  sudo systemctl daemon-reload
  sudo systemctl enable spinmaster_lcd_show_ip_once.service
  
  #to see the text on lcd start now or rebbot
  
    #sudo systemctl start spinmaster_lcd_show_ip_once.service
    
    #sudo reboot
  




#git clone https://github.com/the-raspberry-pi-guy/lcd.git

#see https://www.youtube.com/watch?v=3XLjVChVgec
