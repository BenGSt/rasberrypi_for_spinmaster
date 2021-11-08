#! /usr/bin/env python

import drivers
from time import sleep
from datetime import datetime
from subprocess import check_output
display = drivers.Lcd()
IP = check_output(["hostname", "-I"]).split()[0]
try:
    print("Writing to display")
    while True:
#        display.lcd_display_string(str(datetime.now().date()), 1)
#        display.lcd_display_string(str(IP), 2)
#        sleep(3)

        display.lcd_display_string("   SpinMaster  ", 1)
        display.lcd_display_string("IP:" + str(IP), 2)
        sleep(60*5)
except KeyboardInterrupt:
    # If there is a KeyboardInterrupt (when you press ctrl+c), exit the program and cleanup
    print("Cleaning up!")
    display.lcd_clear()
