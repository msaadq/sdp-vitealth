# MPU6050 lib


The MPU-60X0 has an embedded 3-axis MEMS gyroscope, a 3-axis MEMS accelerometer,
and a Digital Motion Processor (DMP) hardware accelerator engine with an
auxiliary I2C port that interfaces to 3rd party digital sensors such
as magnetometers.

Two attitude estimation mode are implemented:
 * Internal DMP processor
 * Mahony filter

Gyro calibration is suggested to get more accurate parameters. To calibrate the
device read the raw values using the get non calibrated mode then calculate
the offset.

Setup parameters are stored in file mpu6050.h


This library was developed on Eclipse, built with avr-gcc on Atmega168 @ 16MHz.
If you include <math.h> add libm library to linker.

# Processing Sketch
This repository also contains a processing sketch to visualize the mpu6050 data.