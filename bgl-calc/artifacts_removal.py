import scipy.io as sio
import matplotlib.pyplot as plt

training_data = sio.loadmat("ppg-data/training-data/DATA_01_TYPE01.mat")

ppg1 = training_data['sig'][1]
ppg2 = training_data['sig'][2]

acc_x = training_data['sig'][3]
acc_y = training_data['sig'][4]
acc_z = training_data['sig'][5]

plt.figure()
plt.plot(ppg1[0:400])

plt.figure()
plt.plot(ppg2[0:400])

plt.show()