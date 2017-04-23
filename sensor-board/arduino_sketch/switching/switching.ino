// Switches between the three LEDs in the following sequence
// LED1 -> OFF -> LED2 -> OFF -> LED3 -> OFF -> ...
// The change is triggered on both the rising and falling edges
// of the interrupt signal

#define INT_PIN 2
#define LED1 5 // Port D Pin 5
#define LED2 4 // Port D Pin 4
#define LED3 3 // Port D Pin 3

// PORTD :  76543210
// PORTD &= 11000111
// PORTD |= 00111000      


//see switching_timing.pdf in order to understand the switchingState
int switchingState = 0;

long lastTime = 0;

void setup(){
  
  //set pins as outputs
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);

  //set the input interrupt
  pinMode(INT_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(INT_PIN), int_routine, CHANGE);

  DDRD = DDRD | B00111000;
  
  Serial.begin(9600);

}//end setups



void int_routine(){

  
//  Serial.print(millis());
//  Serial.print(",");
//  Serial.println(switchingState);
  //lastTime = millis();
  
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



void loop(){
  //do other things here
  //Serial.print(lastTime);
  //Serial.print(",");
  //Serial.println(switchingState);
}
