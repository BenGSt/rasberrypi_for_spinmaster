#! /usr/bin/env python

# using this and not changing structure so that lcd can be cloned 
# may want to do something else at some point
#import sys
#sys.path.append('/home/pi/rasberrypi_for_spinmaster/spinmaster_lcd/lcd/')

import drivers
from time import sleep
from datetime import datetime
from subprocess import check_output
display = drivers.Lcd()


#display.lcd_display_string("   SpinMaster  ", 1)
#display.lcd_display_string("IP:" + str(IP), 2)

try:
#    print("Writing to display")
    while True:
        print("Writing to display")
        display.lcd_display_extended_string(str(datetime.now()), 2)
        display.lcd_display_string("   SpinMaster  ", 1)
        sleep(5)

        if len(check_output(["hostname", "-I"]).split()):
                print("Got IP")
                IP = check_output(["hostname", "-I"]).split()[0].decode('UTF-8')
                display.lcd_display_string("                ", 2)
                display.lcd_display_string(str(IP), 2)

        else:
                print("No IP")
                display.lcd_display_string("  Offline  ", 2)

        sleep(5)


except KeyboardInterrupt:
    # If there is a KeyboardInterrupt (when you press ctrl+c), exit the program and cleanup
#    print("Cleaning up!")
    display.lcd_clear()
