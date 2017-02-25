const byte ledPin = 13;
const byte ir1 = 5;
const byte ir2 = 6;


const byte interruptPin = 2;
volatile byte state = LOW;
int count = 0;

void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(ir1, OUTPUT);
  pinMode(ir2, OUTPUT);
  
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), blink, CHANGE);

  Serial.begin(9600);
}

void loop() {
  //digitalWrite(ledPin, state);
}

void blink() {
  //state = !state;
  
  count = (count+1)%2;
  Serial.print(millis());
  Serial.print(", ");
  Serial.println(count);

  if(count == 0)
  {
    digitalWrite(ir1, HIGH);
    digitalWrite(ir2, LOW);
  }
  else
  {
    digitalWrite(ir1, LOW);
    digitalWrite(ir2, HIGH);
  }
    
//  if(state == LOW)
//    Serial.println("State: 0");
//  else
//    Serial.println("State: 1");
}

