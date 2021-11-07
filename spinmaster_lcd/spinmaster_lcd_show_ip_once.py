#! /usr/bin/env python

# using this and not changing structure so that lcd can be cloned 
# may want to do something else at some point
import sys
sys.path.append('/home/pi/spinmaster_lcd/lcd')

import drivers
from time import sleep
from datetime import datetime
from subprocess import check_output
display = drivers.Lcd()
IP = check_output(["hostname", "-I"]).split()[0]

display.lcd_display_string("   SpinMaster  ", 1)
display.lcd_display_string("IP:" + str(IP), 2)

#try:
#    print("Writing to display")
#    while True:
#        display.lcd_display_string(str(datetime.now().date()), 1)
#        display.lcd_display_string(str(IP), 2)
#        sleep(3)

#        display.lcd_display_string("   SpinMaster  ", 1)
#        display.lcd_display_string("IP:" + str(IP), 2)



#        sleep(60*5)
#except KeyboardInterrupt:
#    # If there is a KeyboardInterrupt (when you press ctrl+c), exit the program and cleanup
#    print("Cleaning up!")
#    display.lcd_clear()
