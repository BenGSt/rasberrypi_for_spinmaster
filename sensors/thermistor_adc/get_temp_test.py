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
chan = AnalogIn(ads, ADS.P0)

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
        ads.gain = gains[0]
        print('volts={:5.3f}'.format(chan.voltage))
#        for gain in gains[1:]:
#            ads.gain = gain
#            print(' | {:5} {:5.3f}'.format(chan.value, chan.voltage), end='')
#        print()
        time.sleep(3)

        Vo = chan.value
        R2 = R1 * (27529 / Vo - 1.0)
#        R2 = chan.voltage
        logR2 = log(R2)
        T = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2))
        Tc = T - 273.15
        Tf = (Tc * 9.0)/ 5.0 + 32.0

#        print("Tf: " + str(Tf), end =' ')
#        print("Tc: " + str(Tc))
        sys.stdout.flush()
