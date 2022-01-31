import sys
import time
import board
import busio
from math import log
#import adafruit_ads1x15.ads1015 as ADS
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn

#Create the I2C bus
i2c = busio.I2C(board.SCL, board.SDA)

#Create the ADS object
#ads = ADS.ADS1015(i2c)
ads = ADS.ADS1115(i2c)

#Create a sinlge ended channel on Pin 0
#Max counts for ADS1015 = 2047
#ADS1115 = 32767
chan = AnalogIn(ads, ADS.P3)

#The ADS1015 and ADS1115 both have the same gain options.
#
#GAIN    RANGE (V)
#----    ---------
#2/3    +/- 6.144
#1    +/- 4.096
#2    +/- 2.048
#4    +/- 1.024
#8    +/- 0.512
#16    +/- 0.256
#
gains = (2/3, 1, 2, 4, 8, 16)

R1 = 10000
c1 = 1.009249522e-03
c2 = 2.378405444e-04
c3 = 2.019202697e-07


while True:
	ads.gain = 1
#        print('volts={:5.3f}'.format(chan.voltage))
#        for gain in gains[1:]:
#            ads.gain = gain
#            print(' | {:5} {:5.3f}'.format(chan.value, chan.voltage), end='')
#        print()
#        time.sleep(1)
	
	T_0 = 298.15 #25C in kelvin - refrence temp for R_0.
	R_0 = 100000 # the thermistors resistance at T_0.
	Beta = 3950 #beta factor
	V_in = 5
	V_out = chan.voltage
	R_S = 100000 #the resistor between GND and Analog_in
	R_T = (( V_in  / V_out) - 1) * R_S #the thermistor's resistance
	T = 1 / ((1 / T_0) + (1/Beta) * log(R_T / R_0))
	Tc = T - 273.15
	print('Tc={:5.3f}'.format(Tc))
	time.sleep(0.5)

#        Vo = chan.value
#        R2 = R1 * (27529 / Vo - 1.0)
#        R2 = chan.voltage
#        logR2 = log(R2)
#        T = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2))
#        Tc = T - 273.15
#        Tf = (Tc * 9.0)/ 5.0 + 32.0

#        print("Tf: " + str(Tf), end =' ')
#        print("Tc: " + str(Tc))
	sys.stdout.flush()
