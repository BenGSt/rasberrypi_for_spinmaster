'''
------------------------------------------------------
SpinMaster project - thermistor reading script
Authors:    Ben Steinberg
Date:       31/01/2022
------------------------------------------------------
'''

import sys
import time
import board
import busio
from math import log
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn


def calculate_temperature(channel):
    T_0 = 298.15  # 25C in kelvin - reference temp for R_0.
    R_0 = 100000  # the thermistor's resistance at T_0.
    Beta = 3950  # beta factor
    V_in = 5
    V_out = channel.voltage
    R_S = 100000  # the resistor between GND and Analog_in
    R_T = ((V_in / V_out) - 1) * R_S  # the thermistor's resistance
    T = 1 / ((1 / T_0) + (1 / Beta) * log(R_T / R_0))
    Tc = T - 273.15

    return Tc


def print_temperatures(temperatures):
    for i in range(len(temperatures) - 1):
        print('Tc_thermistor{}={:.1f}'.format(i, temperatures[i]), end='\t')

    i = len(temperatures) - 1
    print('Tc_thermistor{}={:.1f}'.format(i, temperatures[i]))
    sys.stdout.flush()


def print_temperatures_no_id(temperatures):
    # for i in range(len(temperatures) - 1):
    #     print('{:.1f}'.format(temperatures[i]), end='\t')

    i = len(temperatures) - 1
    print('{:.1f}'.format(temperatures[i]))
    sys.stdout.flush()


def main(loop_times=5, loop_forever=False, number_of_samples_to_average=5, sleep_time_between_sampling=0.5):
    # Create the I2C bus
    i2c = busio.I2C(board.SCL, board.SDA)

    # Create the ADS object
    # ads = ADS.ADS1015(i2c)
    # The ADS1015 and ADS1115 both have the same gain options.
    #
    # GAIN    RANGE (V)
    # ----    ---------
    # 2/3    +/- 6.144
    # 1    +/- 4.096
    # 2    +/- 2.048
    # 4    +/- 1.024
    # 8    +/- 0.512
    # 16    +/- 0.256
    #
    ads = ADS.ADS1115(i2c)
    ads.gain = 1

    # Create channels on Pins 0,1,2
    # Max counts for ADS1015 = 2047
    # ADS1115 = 32767
    channels = [AnalogIn(ads, ADS.P0), AnalogIn(ads, ADS.P1), AnalogIn(ads, ADS.P2)]

    average_temperatures = [0, 0, 0]
    while True:
        for _ in range(number_of_samples_to_average):
            temperatures = list(map(calculate_temperature, channels))

            for i in range(len(temperatures)):
                average_temperatures[i] += (temperatures[i] / number_of_samples_to_average)

        # print_temperatures(average_temperatures)
        print_temperatures_no_id(average_temperatures) #printing one value for debug
        average_temperatures = [0, 0, 0]

        time.sleep(sleep_time_between_sampling)
        loop_times -= 1
        if loop_times == 0 and not loop_forever:
            break

if __name__ == "__main__":
    main(loop_times=1, loop_forever=False, number_of_samples_to_average=50, sleep_time_between_sampling=0)
