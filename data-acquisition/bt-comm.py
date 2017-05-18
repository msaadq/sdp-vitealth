import serial
import time

# # Serial port parameters

serial_speed = 9600
serial_port = '/dev/tty.HC-05-DevB'

# Device state
DEV_ENABLED = False
SENSORS_ENABLED = False

# Bluetooth commands out
OAVA = "OAVA:"
OGSS = "OGSS:"
OGSD = "OGSD:"

# Bluetooth commands in
IAVA = "IAVA:"
IGSS = "IGSS:"
IGSD = "IGSD:"
IINV = "IINV:"

def write_to_bt(message):
	ser.write(bytes(message + '\r\n', encoding='utf-8'))

def read_from_bt():
	return ser.readline().decode("utf-8") 

def set_device_status(on=True):
	if on:
		write_to_bt(OAVA + '1')
		if read_from_bt() == IAVA + '1':
			return True
		else:
			return False
	else:
		write_to_bt(OAVA + '0')
		if read_from_bt() == IAVA + '0':
			return False
		else:
			return True 

def set_sensors_status(on=True):
	if on and DEV_ENABLED:
		write_to_bt(OGSS + '1')
		if read_from_bt() == IGSS + '1':
			return True
		else:
			return False
	elif DEV_ENABLED:
		write_to_bt(OGSS + '0')
		if read_from_bt() == IGSS + '0':
			return False
		else:
			return True 

def get_sensor_data(samples):
	pass

if __name__ == '__main__':

	print("Connecting to serial port ...")

	ser = serial.Serial(serial_port, serial_speed, bytesize=8, parity='N', stopbits=1, timeout=None)  # open first serial port

	while True:
		reading = read_from_bt()

		if reading == "":
			continue

		num1 = ord(reading) * 100
		num2 = ord(read_from_bt()) 

		print(num1 + num2)        
	#DEV_ENABLED = set_device_status(True)
	#SENSORS_ENABLED = set_sensors_status(True)
	
	#ser.write(b"Hello")
