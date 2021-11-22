#! /usr/bin/env python

'''
------------------------------------------------------
Final project - LCD display shell interface
Authors:    Yoav Silberstein
File:	    lcd_ctrl.py
Date:       22/11/2021  	
------------------------------------------------------
'''
from colorama.ansi import clear_line
import drivers
from time import sleep
# Load the driver and set it to "display"

from datetime import datetime
from subprocess import check_output

import sys
from colorama import Fore, Back, Style
import argparse


# consts
LINE_WIDTH = 16 # number of letters per line

# If you use something from the driver library use the "display." prefix first
display = drivers.Lcd()


def LCD_plot_line(text='', line=1, delay=0):
    display.lcd_display_string(text, line)  # Write line of text to specific line in the display screen
    if(delay > 0):
        sleep(delay)
        display.lcd_display_string(' ' * LINE_WIDTH , line)



# this function get a text and line and print the text on the LCD display
def LCD_plot(text_lst, delay):
    text_lst_len = len(text_lst)
    lcd_clear()                     # Clear the display of any data
    sleep(1)                        # delay of 1 second

  #  if(text_lst_len == 1):    
   #     LCD_plot_line(text_lst[0], 1)       # Write line of text to 1 line of display                
   # elif(text_lst_len == 2):    
    #    LCD_plot_line(text_lst[0], 1)       # Write line of text to 1 line of display 
     #   LCD_plot_line(text_lst[1], 2)       # Write line of text to 2 line of display   
    
    for i in range(text_lst_len - 1):
        lcd_clear()
        
        LCD_plot_line(text_lst[i % text_lst_len], 1)
        LCD_plot_line(text_lst[(i + 1) % text_lst_len], 2)
        sleep(1)                        # delay of 1 second

    if(delay - 1 > 0):
        sleep(delay - 1)   
        lcd_clear()


    

def lcd_clear():
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

def read_lines(file_address):
    #open and read the file after the appending:
    file = open(file_address, "r")
    r = file.read()
    lst = r.split('\n')
    file.close()
    return lst[:]

def write_lines(file_address, lst):
    #open and read the file after the appending:
    file = open(file_address, "w")
    file_lines = "\n".join(lst)
    file.write(file_lines)
    file.close()


def write_line_to_file(file_address, line_num):
    lst = read_lines(file_address)  
    lst[line_num - 1] = args.plot
    write_lines(file_address, lst)
    return lst[:]

if __name__ == "__main__":

    file_address = "memory"
    parser = argparse.ArgumentParser(description='LCD display interface')
    parser.add_argument('-p', '--plot', type=str, default='', help='print text on LCD screen --plot \"text\"')
    parser.add_argument('-l', '--line', type=int, default=1, help='line number')
    parser.add_argument('-t', '--time', type=int, default=-1, help='display time [seconds]')
    args = parser.parse_args()


    if(args.plot != ''):
        lst = write_line_to_file(file_address, args.line)
        
    else:  # print file to LCD
        lst = read_lines(file_address)  

    LCD_plot(lst, args.time) 
    
         
