'''
------------------------------------------------------
Final project - LCD display shell interface
Authors:    Yoav Silberstein
File:	    LCD_shell_interface.py
Date:       19/11/2021  	
------------------------------------------------------
'''

import drivers
from time import sleep
# Load the driver and set it to "display"

from datetime import datetime
from subprocess import check_output

import sys
from colorama import Fore, Back, Style
import argparse

# If you use something from the driver library use the "display." prefix first
display = drivers.Lcd()

# this function get a text and line and print the text on the LCD display
def LCD_print(text_arr):
    text_arr_len = len(text_arr)
    display.lcd_clear()                     # Clear the display of any data
    sleep(2) 

    if(text_arr_len == 1):                          
        display.lcd_display_string(text_arr[0], 1)  # Write line of text to # line of display
    elif(text_arr_len == 2):            
        display.lcd_display_string(text_arr[0], 1)  # Write line of text to # line of display             
        display.lcd_display_string(text_arr[1], 2)  # Write line of text to # line of display
    else:
        for i in range(text_arr_len * 2):
            display.lcd_display_string(text_arr[i % text_arr_len], 1)        # Write line of text to # line of display      
            display.lcd_display_string(text_arr[(i + 1) % text_arr_len], 2)  # Write line of text to # line of display
            sleep(2)
            display.lcd_clear()

# lcd_backlight
def LCD_backlight(on_off):
    try:
        print("Press CTRL + C to quit program")
        while True:
            # Remember that your sentences can only be 16 characters long!
            print("Loop: Writing to display and toggle backlight...")
            display.lcd_backlight(on_off)                          # Make sure backlight is on / turn on
            sleep(2)                                               # Waiting for backlight toggle

    except KeyboardInterrupt:
        # If there is a KeyboardInterrupt (when you press CTRL + C), exit the program and cleanup
        print("Exit and cleaning up!")
        display.lcd_clear()
        # Make sure backlight is on / turn on by leaving
        display.lcd_backlight(1)
    

# get ip
def get_ip():
    IP = check_output(["hostname", "-I"]).split()[0]
    try:
        print("Writing to display")
        while True:
            display.lcd_display_string(str(datetime.now().time()), 1)
            display.lcd_display_string(str(IP), 2)
            # Uncomment the following line to loop with 1 sec delay
            # sleep(1)
    except KeyboardInterrupt:
        # If there is a KeyboardInterrupt (when you press ctrl+c), exit the program and cleanup
        print("Cleaning up!")
        display.lcd_clear()

def help():
    print(Fore.YELLOW + "--print " + Fore.WHITE + "\"text\" print \"text\" on LCD display")
    print(Fore.YELLOW + "--get_ip " + Fore.WHITE + "print Raspberry pi ip on LCD display")

if __name__ == "__main__":

    # consts
    LINE_WIDTH = 16 # number of letters per line

    comand = sys.argv[1]
    value = ""

    parser = argparse.ArgumentParser(description='LCD display shell intrerface')
    parser.add_argument('-p', '--print', type=str, metavar='', help='print text on LCD display')
    parser.add_argument('-i', '--ip', type=str, metavar='', help='print Rasbperrt pi ip address')
    args =  parser.parse_args

  #  if(len(sys.argv) > 2):
    value = args.print
    
    lines_arr = []
    string_len = len(args.print)

    if(string_len):
        # split value to lines
        buffer = 0
        while(string_len - LINE_WIDTH >= buffer):
            lines_arr.append(value[buffer: buffer + LINE_WIDTH])
            buffer += LINE_WIDTH

        if(string_len - buffer > 0):
            lines_arr.append(value[buffer:])  

        LCD_print(lines_arr)     

    if(comand == "--get_ip"):
        get_ip() 

    
    if(comand == "--backlight_on"):
        LCD_backlight(1)

    if(comand == "--backlight_off"):
        LCD_backlight(0)

    if(comand == "--help"):
        help() 