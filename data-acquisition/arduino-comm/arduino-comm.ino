
#include <SoftwareSerial.h>

// Analog read
int PPGADC = 2;
int anaValue = 0;

// State variable
bool availabilityEnabled = false;
bool sensorsEnabled = false;

// Received data
String receivedString;
String receivedParameters;

// Bluetooth commands out
static const String OAVA = "OAVA:";
static const String OGSS = "OGSS:";
static const String OGSD = "OGSD:";

// Bluetooth commands in
static const String IAVA = "IAVA:";
static const String IGSS = "IGSS:";
static const String IGSD = "IGSD:";
static const String IINV = "IINV:";

SoftwareSerial debugSerial(10, 11); // RX, TX

#include <Wire.h>
// I2Cdev and MPU6050 must be installed as libraries, or else the .cpp/.h files
// for both classes must be in the include path of your project
#include "I2Cdev.h"
#include "MPU6050.h"

// Arduino Wire library is required if I2Cdev I2CDEV_ARDUINO_WIRE implementation
// is used in I2Cdev.h
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    #include "Wire.h"
#endif

// class default I2C address is 0x68
// specific I2C addresses may be passed as a parameter here
// AD0 low = 0x68 (default for InvenSense evaluation board)
// AD0 high = 0x69
MPU6050 accelgyro;
//MPU6050 accelgyro(0x69); // <-- use for AD0 high

int16_t ax, ay, az;
int16_t gx, gy, gz;



// uncomment "OUTPUT_READABLE_ACCELGYRO" if you want to see a tab-separated
// list of the accel X/Y/Z and then gyro X/Y/Z values in decimal. Easy to read,
// not so easy to parse, and slow(er) over UART.
#define OUTPUT_READABLE_ACCELGYRO

// uncomment "OUTPUT_BINARY_ACCELGYRO" to send all 6 axes of data as 16-bit
// binary, one right after the other. This is very fast (as fast as possible
// without compression or data loss), and easy to parse, but impossible to read
// for a human.
//#define OUTPUT_BINARY_ACCELGYRO


#define LED_PIN 13
bool blinkState = false;


/////////////////////////////// SWITCHING //////////////////////////////////////////////////////////
#define INT_PIN 3
#define LED1 4 // Port D Pin 4
#define LED2 5 // Port D Pin 5
#define LED3 6 // Port D Pin 6

// PORTD :  76543210
// PORTD &= 10001111
// PORTD |= 01110000      
int switchingState = 0;




void setup() {


    // set the data rate for the SoftwareSerial port
  debugSerial.begin(9600);
  debugSerial.println("Debug Serial Ready!");

    /////////////////////// ACCELEROMETER /////////////////////////////////
    
    // join I2C bus (I2Cdev library doesn't do this automatically)
    #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
        Wire.begin();
    #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
        Fastwire::setup(400, true);
    #endif

    // initialize device
    debugSerial.println("Initializing I2C devices...");
    accelgyro.initialize();

    // verify connection
    debugSerial.println("Testing device connections...");
    debugSerial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");

    // use the code below to change accel/gyro offset values
    /*
    Serial.println("Updating internal sensor offsets...");
    // -76  -2359 1688  0 0 0
    Serial.print(accelgyro.getXAccelOffset()); Serial.print("\t"); // -76
    Serial.print(accelgyro.getYAccelOffset()); Serial.print("\t"); // -2359
    Serial.print(accelgyro.getZAccelOffset()); Serial.print("\t"); // 1688
    Serial.print(accelgyro.getXGyroOffset()); Serial.print("\t"); // 0
    Serial.print(accelgyro.getYGyroOffset()); Serial.print("\t"); // 0
    Serial.print(accelgyro.getZGyroOffset()); Serial.print("\t"); // 0
    Serial.print("\n");
    accelgyro.setXGyroOffset(220);
    accelgyro.setYGyroOffset(76);
    accelgyro.setZGyroOffset(-85);
    Serial.print(accelgyro.getXAccelOffset()); Serial.print("\t"); // -76
    Serial.print(accelgyro.getYAccelOffset()); Serial.print("\t"); // -2359
    Serial.print(accelgyro.getZAccelOffset()); Serial.print("\t"); // 1688
    Serial.print(accelgyro.getXGyroOffset()); Serial.print("\t"); // 0
    Serial.print(accelgyro.getYGyroOffset()); Serial.print("\t"); // 0
    Serial.print(accelgyro.getZGyroOffset()); Serial.print("\t"); // 0
    Serial.print("\n");
    */

    // configure Arduino LED for
    pinMode(LED_PIN, OUTPUT);



    /////////////////////// SWITCHING /////////////////////////////////
    pinMode(LED1, OUTPUT);
    pinMode(LED2, OUTPUT);
    pinMode(LED3, OUTPUT);
  
    //set the input interrupt
    pinMode(INT_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(INT_PIN), int_routine, CHANGE);
  
    DDRD = DDRD | B01110000;    
}

void loop() {

  if(debugSerial.available()) {
    receivedString = debugSerial.readString();

    receivedParameters = receivedString.substring(5);
    receivedString = receivedString.substring(0, 5);

    debugSerial.println("Data:");
    debugSerial.println(receivedString); 
    debugSerial.println(receivedParameters); 
    debugSerial.println(receivedParameters.substring(0)); 
    //receivedParameters.substring(0) 

    if(receivedString.equals(OAVA)) {
    debugSerial.print("Device enabled!"); 
    activateDevice();

    } else if (receivedString.equals(OGSS)) {
    debugSerial.print("Sensors enabled!");
    activateSensors();

    } else if (receivedString.equals(OGSD)) {
      debugSerial.print("Data requested!"); 

    } else { 
      debugSerial.print("IINV:1!");   

    }

 }
/*
    // read raw accel/gyro measurements from device
    accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

    // these methods (and a few others) are also available
    //accelgyro.getAcceleration(&ax, &ay, &az);
    //accelgyro.getRotation(&gx, &gy, &gz);

    #ifdef OUTPUT_READABLE_ACCELGYRO
        // display tab-separated accel/gyro x/y/z values
        //Serial.print("a/g:\t");
        debugSerial.print(ax); debugSerial.print("\t");
        debugSerial.print(ay); debugSerial.print("\t");
        debugSerial.print(az); debugSerial.print("\t");
        debugSerial.println(analogRead(PPGADC));


        char smogData[4];
        sprintf(smogData, "%d,", ax);
        debugSerial.print(smogData);

        sprintf(smogData, "%d,", ay);
        debugSerial.print(smogData);

        sprintf(smogData, "%d,", az);
        debugSerial.print(smogData);



//        Serial.print(az); Serial.print("\t");
//        Serial.print(gx); Serial.print("\t");
//        Serial.print(gy); Serial.print("\t");
//        Serial.println(gz);
    #endif

//    #ifdef OUTPUT_BINARY_ACCELGYRO
//        Serial.write((uint8_t)(ax >> 8)); Serial.write((uint8_t)(ax & 0xFF));
//        Serial.write((uint8_t)(ay >> 8)); Serial.write((uint8_t)(ay & 0xFF));
//        Serial.write((uint8_t)(az >> 8)); Serial.write((uint8_t)(az & 0xFF));
//        Serial.write((uint8_t)(gx >> 8)); Serial.write((uint8_t)(gx & 0xFF));
//        Serial.write((uint8_t)(gy >> 8)); Serial.write((uint8_t)(gy & 0xFF));
//        Serial.write((uint8_t)(gz >> 8)); Serial.write((uint8_t)(gz & 0xFF));
//    #endif

    // blink LED to indicate activity
//    blinkState = !blinkState;
//    digitalWrite(LED_PIN, blinkState);

        */
}


void activateDevice() {
  if (receivedParameters == "1!") {
    debugSerial.print("Device enabled!"); 
    availabilityEnabled = true;
    sensorsEnabled = true;


  } else if (receivedParameters == "0!") {
    debugSerial.print("Device disbaled!"); 
    availabilityEnabled = false;
    sensorsEnabled = false;

  }
}


void activateSensors() {
  if (receivedParameters.substring(0) == "1!") {
    debugSerial.print("Sensors enabled!"); 

  } else if (receivedParameters.substring(0) == "0!") {
    debugSerial.print("Sensors disbaled!"); 
    
  }
}


void sendData(int count) {
	if (availabilityEnabled())
}



void int_routine(){

  
//  Serial.print(millis());
//  Serial.print(",");
//  Serial.println(switchingState);
//  lastTime = millis();
  
  switch(switchingState)
    {
      case 0: 
        // LED1:LOW, LED2:HIGH, LED3:HIGH
        PORTD &= (0 << LED1) | (0 << LED2) | (0 << LED3);
        PORTD |= (0 << LED1) | (1 << LED2) | (1 << LED3); 
        switchingState++;
        break;
  
      case 1:
        // LED1:HIGH, LED2:HIGH, LED3:HIGH
        PORTD &= (0 << LED1) | (0 << LED2) | (0 << LED3);
        PORTD |= (1 << LED1) | (1 << LED2) | (1 << LED3);
        switchingState++;
        break;
  
      case 2: 
        // LED1:HIGH, LED2:LOW, LED3:HIGH
        PORTD &= (0 << LED1) | (0 << LED2) | (0 << LED3);
        PORTD |= (1 << LED1) | (0 << LED2) | (1 << LED3);
        switchingState++;
        break;
  
      case 3: 
        // LED1:HIGH, LED2:HIGH, LED3:HIGH
        PORTD &= (0 << LED1) | (0 << LED2) | (0 << LED3);
        PORTD |= (1 << LED1) | (1 << LED2) | (1 << LED3);
        switchingState++;
        break;
  
      case 4: 
        // LED1:HIGH, LED2:HIGH, LED3:LOW
        PORTD &= (0 << LED1) | (0 << LED2) | (0 << LED3);
        PORTD |= (1 << LED1) | (1 << LED2) | (0 << LED3);
        switchingState++;
        break;
  
      case 5: 
        // LED1:HIGH, LED2:HIGH, LED3:HIGH
        PORTD &= (0 << LED1) | (0 << LED2) | (0 << LED3);
        PORTD |= (1 << LED1) | (1 << LED2) | (1 << LED3);
        switchingState = 0;
        break;
    }
}
/*
#include <SoftwareSerial.h>

// Analog read
int PPGADC = 2;
int anaValue = 0;

// State variable
bool availabilityEnabled = false;
bool sensorsEnabled = false;

// Received data
char *receivedString;
char *receivedParameters;

// Bluetooth commands out
static const char* OAVA = "OAVA:";
static const char* OGSS = "OGSS:";
static const char* OGSD = "OGSD:";

// Bluetooth commands in
static const char* IAVA = "IAVA:";
static const char* IGSS = "IGSS:";
static const char* IGSD = "IGSD:";
static const char* IINV = "IINV:";


SoftwareSerial debugSerial(10, 11); // RX, TX

void setup() {
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial);
  Serial.println("BT Serial ready!");

  // set the data rate for the SoftwareSerial port
  debugSerial.begin(9600);
  debugSerial.println("Debug Serial Ready!");

  debugSerial.write(analogRead(PPGADC));
  debugSerial.write(analogRead(PPGADC));
  debugSerial.write(analogRead(PPGADC));
  debugSerial.write(analogRead(PPGADC));
  debugSerial.write(analogRead(PPGADC));
  debugSerial.write(analogRead(PPGADC));
}

void loop() { // run over and over
  if (Serial.available()) {
    //receivedString = Serial.read();
    //debugSerial.write(Serial.read());

  }

    int data = analogRead(PPGADC);
    char smogData[5];
    sprintf(smogData, "%d,", data);

  debugSerial.write(smogData);

  if (debugSerial.available()) {
    Serial.write(debugSerial.read());
  }
}

void reqData(int samples) {
  if(sensorsEnabled) {
    char smogData[3];
    int iSmogData = 0;
    
    for(int i = 0; i < samples; i++) {
      iSmogData += getSmogSensorValue();
    } 
    iSmogData /= 1000;
    
    sprintf(smogData, "%d", iSmogData);
           
    sendCommand(I_COM_SSG, smogData);
    
  } else {
    sendCommand(I_COM_NSG, "0");
    
  }
}

*/







