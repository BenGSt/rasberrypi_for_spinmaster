# polarimeter.py
# Last modified: 23.02.22 16:15


import pyvisa
import time
import math
# import matplotlib.pyplot as plt
from datetime import datetime
# import winsound


# plots labels
X_LABEL_TIME = 'Time [s]'
Y_LABEL_AZIMUTH = 'Azimuth angle [degrees]'
Y_LABEL_ELLIPSE = 'Ellipse angle[degrees]'
Y_LABEL_DOP = 'Degree of polarization [%]'

TITLE_LABEL_AZIMUTH = 'Azimuth angle VS. time'
TITLE_LABEL_ELLIPSE = 'Ellipse angle VS. time'
TITLE_LABEL_DOP = 'DOP VS. time'

# Plots design
LINE_WIDTH = '2'
TITLE_FONT = {'family': 'serif', 'color': 'black', 'size': 20}
LABEL_FONT = {'family': 'serif', 'color': 'black', 'size': 18}

date_object = str(datetime.now())
time_stump = str(date_object.replace(':', '.'))

MINUTE = 60  # 1 minute is 60 seconds


class PAX1000Controller:
    def __init__(self):
        rm = pyvisa.ResourceManager()
        dev = str(rm.list_resources())
        dev = dev.split("\'")
        print(dev[1], "DEVICE")
        self.PAX1000 = rm.open_resource(dev[1])

    def Meassmode(self):
        self.PAX1000.write('SENSe:CALCulate:MODe 5\n')
        time.sleep(5)
        MODEq = self.PAX1000.query('SENSe:CALCulate:MODe?\n')
        print('The Messmode is:', MODEq)

    def WaveLength(self):
        self.PAX1000.write('SENSe:CORRection:WAVelength 532e-9\n')
        Wavelength = self.PAX1000.query('SENSe:CORRection:WAVelength?\n')
        print('The Wavelength is:', Wavelength)

    def Powermode(self):
        self.PAX1000.write('SENSe:POWer:RANGe:AUTO 1\n')
        Powermode = self.PAX1000.query('SENSe:POWer:RANGe:AUTO?')
        print('The Powermode is:', Powermode)

    def Nomial(self):
        Nominal = self.PAX1000.query('SENSe:POWer:RANGe:NOMinal? MIN\n')
        print('Nominal is:', Nominal)

    def Rotationstate(self):
        self.PAX1000.write('INPut:ROTation:STATe 1\n')
        Rotation = self.PAX1000.query('INPut:ROTation:STATe?')
        print('The Rotationstate is:', Rotation)

    def RotationFrequenz(self):
        self.PAX1000.write('INPut:ROTation:VELocity 60\n')
        time.sleep(5)
        Velocity = self.PAX1000.query('INPut:ROTation:VELocity?')
        print('The Rotation Frequenz is:', Velocity)

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

time_lst = []
azimuth_lst = []
ellipse_lst = []
DOP_lst = []  # degree of polarization (how much (in percentage) of incident



def sample(sample_rate=0.5, sample_time=0.1):
    # the func is taking the total sample time in minutes and the
    # sample rate in seconds as arguments.
    #returning a tuple of (sample time vector, azimuth angle vec, ellipse
    # angle vec, DOP vec


    #  light)
    # is polarized
    sample_time = sample_time * MINUTE
    samples = int(sample_time / sample_rate)

    for sample in range(samples):
        temp = polarimeter.Data()
        data = temp[:len(temp) - 1].split(",")

        az = float(data[9]) * (180 / math.pi)
        azimuth_lst.append(az)

        pi = float(data[10]) * (180 / math.pi)
        ellipse_lst.append(pi)

        DOP_lst.append(round(float(data[11]), 2))

        time_lst.append(sample * sample_rate)
        time.sleep(sample_time)

    return time_lst, azimuth_lst, ellipse_lst, DOP_lst

polarimeter = PAX1000Controller()
setup(polarimeter)


time_l, azimuth_l, ellipse_l, DOP_l = sample(0.1, 0.02)

#def plots(time_lst, azimuth, ellipse, DOP):
# the func is ploting and saving the vectors that are given to it
# Graph of azimuth angle
# plot1 = plt.figure(1)
# plt.plot(time_l, azimuth_l, linewidth=LINE_WIDTH)
# file_name1 = 'azimuth angle' + time_stump + '.png'
# plt.savefig(file_name1)
# # naming the x axis
# plt.xlabel(X_LABEL_TIME, fontdict=LABEL_FONT)
# # naming the y axis
# plt.ylabel(Y_LABEL_AZIMUTH, fontdict=LABEL_FONT)
# # giving a title to my graph
# plt.title(TITLE_LABEL_AZIMUTH, fontdict=TITLE_FONT)
# plt.grid()
#
# # Graph of ellipse angle
# plot2 = plt.figure(2)
# plt.plot(time_l, ellipse_l, linewidth=LINE_WIDTH)
# file_name2 = 'ellipse angle' + time_stump + '.png'
# plt.savefig(file_name2)
# # giving a title to my graph
# plt.title(TITLE_LABEL_ELLIPSE, fontdict=TITLE_FONT)
# # naming the x axis
# plt.xlabel(X_LABEL_TIME, fontdict=LABEL_FONT)
# # naming the y axis
# plt.ylabel(Y_LABEL_ELLIPSE, fontdict=LABEL_FONT)
#
# # Graph of DOP angle
# plot3 = plt.figure(3)
# plt.plot(time_l, DOP_l, linewidth=LINE_WIDTH)
# file_name3 = 'DOP' + time_stump + '.png'
#
# plt.savefig(file_name3)
# # giving a title to my graph
# plt.title(TITLE_LABEL_DOP, fontdict=TITLE_FONT)
# # naming the x axis
# plt.xlabel(X_LABEL_TIME, fontdict=LABEL_FONT)
# # naming the y axis
# plt.ylabel(Y_LABEL_DOP, fontdict=LABEL_FONT)
#
#
# plt.show()
# plt.show()
# plt.show()
#
# print('Done')
# for i in range(200, 1200, 50):
#     winsound.Beep(i, 300)
#     time.sleep(0.3)
#
# winsound.Beep(1200, 2000)

# function to show the plot


print(azimuth_l)
polarimeter.Close()





