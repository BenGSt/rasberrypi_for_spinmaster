# polarimeter.py
# Last modified: 10.03.22 11:00
import pyvisa
import time
import math
import matplotlib.pyplot as plt
from datetime import datetime
#import winsound
import os
#import pandas as pd


MEASUREMENT_TITLE = "water_"

# plots labels
X_LABEL_TIME = 'Time [s]'
Y_LABEL_AZIMUTH = 'Azimuth angle [degrees]'
Y_LABEL_ELLIPSE = 'Ellipse angle [degrees]'
Y_LABEL_DOP = 'Degree of polarization [%]'

TITLE_LABEL_AZIMUTH = 'Azimuth angle VS. time'
TITLE_LABEL_ELLIPSE = 'Ellipse angle VS. time'
TITLE_LABEL_DOP = 'DOP VS. time'

# Plots design
LINE_WIDTH = '2'
TITLE_FONT = {'family': 'serif', 'color': 'black', 'size': 20}
LABEL_FONT = {'family': 'serif', 'color': 'black', 'size': 18}

date_object = str(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
time_stump = str(date_object.replace(':', '.'))

SECONDS = 10  # running time


class PAX1000Controller:
    def __init__(self):
        rm = pyvisa.ResourceManager('@py')
        dev = str(rm.list_resources())
        dev = dev.split("\'")
#        print(dev[1], "DEVICE")
        # self.PAX1000 = rm.open_resource(dev[1])
        self.PAX1000 = rm.open_resource('USB0::4883::32817::M00559793::0::INSTR')

    def Meassmode(self):
        self.PAX1000.write('SENSe:CALCulate:MODe 5\n')
        time.sleep(5)
        MODEq = self.PAX1000.query('SENSe:CALCulate:MODe?\n')
#        print('The Messmode is:', MODEq)

    def WaveLength(self):
        self.PAX1000.write('SENSe:CORRection:WAVelength 532e-9\n')
        Wavelength = self.PAX1000.query('SENSe:CORRection:WAVelength?\n')
#        print('The Wavelength is:', Wavelength)

    def Powermode(self):
        self.PAX1000.write('SENSe:POWer:RANGe:AUTO 1\n')
        Powermode = self.PAX1000.query('SENSe:POWer:RANGe:AUTO?')
#        print('The Powermode is:', Powermode)

    def Nomial(self):
        Nominal = self.PAX1000.query('SENSe:POWer:RANGe:NOMinal? MIN\n')
#        print('Nominal is:', Nominal)

    def Rotationstate(self):
        self.PAX1000.write('INPut:ROTation:STATe 1\n')
        Rotation = self.PAX1000.query('INPut:ROTation:STATe?')
#        print('The Rotationstate is:', Rotation)

    def RotationFrequenz(self):
        self.PAX1000.write('INPut:ROTation:VELocity 60\n')
        time.sleep(5)
        Velocity = self.PAX1000.query('INPut:ROTation:VELocity?')
#        print('The Rotation Frequenz is:', Velocity)

    def Quer(self):
        self.PAX1000.write('SENSe:DATA:PRIMary')

    def Data(self):
        Data = self.PAX1000.query('SENSe:DATA:PRIMary:LATest?')
        return (Data)

    def Close(self):
        self.PAX1000.close()


def setup(polarimeter):
    polarimeter.Meassmode()
    polarimeter.WaveLength()
    polarimeter.Powermode()
    polarimeter.Nomial()
    polarimeter.Rotationstate()
    polarimeter.Quer()
    polarimeter.RotationFrequenz()


def sample(polarimeter, time_lst, azimuth_lst, ellipticity_lst, DOP_lst,
           sample_time=10, sample_rate=1):
    # the func is taking the total sample time in minutes and the
    # sample rate in seconds as arguments.
    # returning a tuple of (sample time vector, azimuth angle vec, ellipse
    # angle vec, DOP vec
    #  light)
    # is polarized
#    samples = int(sample_time / sample_rate)
    sample = 0
    while(True):
        temp = polarimeter.Data()
        data = temp[:len(temp) - 1].split(",")

        azimuth = float(data[9]) * (180 / math.pi)
        azimuth_lst.append(azimuth)

        ellipticity = float(data[10]) * (180 / math.pi)
        ellipticity_lst.append(ellipticity)

        dop = round(float(data[11]), 5)
        DOP_lst.append(dop)

        current_time = sample * sample_rate

        st = "time=" + str(current_time) + " azimuth=" + str(azimuth) +\
             " ellipticity=" + str(ellipticity) + " DOP=" + str(dop)

        print(st)
        time_lst.append(current_time)
        time.sleep(sample_rate)
        sample += 1

    return time_lst, azimuth_lst, ellipticity_lst, DOP_lst


def plots(time_lst, azimuth_lst, ellipse_lst, DOP_lst):
    folder = './measurements/' + time_stump
    os.mkdir(folder)

    # the func is ploting and saving the vectors that are given to it
    # Graph of azimuth angle
    plot_temp = plt.figure(1, figsize=(7, 5), dpi=400)

    plt.plot(time_lst, azimuth_lst, linewidth=LINE_WIDTH)
    # naming the x axis
    plt.xlabel(X_LABEL_TIME, fontdict=LABEL_FONT)
    # naming the y axis
    plt.ylabel(Y_LABEL_AZIMUTH, fontdict=LABEL_FONT)
    # giving a title to my graph
    plt.title(TITLE_LABEL_AZIMUTH, fontdict=TITLE_FONT)
    # plt.grid()
    file_name1 = 'azimuth angle_' + MEASUREMENT_TITLE + time_stump
    plt.savefig(folder + '/' + file_name1 + '.png', dpi=400)
    plt.savefig(folder + '/' + file_name1 + '.svg', dpi=400)
    plt.close()

    # Graph of ellipse angle
    plot2 = plt.figure(2, figsize=(7, 5), dpi=400)
    plt.plot(time_lst, ellipse_lst, linewidth=LINE_WIDTH)
    # giving a title to my graph
    plt.title(TITLE_LABEL_ELLIPSE, fontdict=TITLE_FONT)
    # naming the x axis
    plt.xlabel(X_LABEL_TIME, fontdict=LABEL_FONT)
    # naming the y axis
    plt.ylabel(Y_LABEL_ELLIPSE, fontdict=LABEL_FONT)
    file_name2 = 'ellipse angle_' + MEASUREMENT_TITLE + time_stump
    plt.savefig(folder + '/' + file_name2 + '.png', dpi=400)
    plt.savefig(folder + '/' + file_name2 + '.svg', dpi=400)
    plt.close()

    # Graph of DOP angle
    plot3 = plt.figure(3, figsize=(7, 5), dpi=400)
    plt.plot(time_lst, DOP_lst, linewidth=LINE_WIDTH)
    # giving a title to my graph
    plt.title(TITLE_LABEL_DOP, fontdict=TITLE_FONT)
    # naming the x axis
    plt.xlabel(X_LABEL_TIME, fontdict=LABEL_FONT)
    # naming the y axis
    plt.ylabel(Y_LABEL_DOP, fontdict=LABEL_FONT)
    file_name3 = 'DOP_' + MEASUREMENT_TITLE + time_stump
    plt.savefig(folder + '/' + file_name3 + '.png', dpi=400)
    plt.savefig(folder + '/' + file_name3 + '.svg', dpi=400)
    plt.close()
    # plt.show()


def done_sound():
    for i in range(200, 1200, 50):
        winsound.Beep(i, 300)
        time.sleep(0.3)

    winsound.Beep(1200, 2000)


polarimeter = PAX1000Controller()
setup(polarimeter)


#print("start")
time_lst = []
azimuth_lst = []
ellipticity_lst = []
DOP_lst = []

sample(polarimeter, time_lst, azimuth_lst, ellipticity_lst, DOP_lst, SECONDS, 1)

#plots(time_lst, azimuth_lst, ellipticity_lst, DOP_lst)


#done_sound()

# create matrix (table) of the lists

#dict_lists = \
#    {
#        "time_list": time_lst,
#        "azimuth_list": azimuth_lst,
#        "ellipse_list": ellipticity_lst,
#        "DOP_list": DOP_lst
#    }

#df = pd.DataFrame.from_dict(dict_lists, orient='index').transpose()
#df.to_csv("./measurements/" + time_stump + "/" + time_stump + ".csv")

polarimeter.Close()

