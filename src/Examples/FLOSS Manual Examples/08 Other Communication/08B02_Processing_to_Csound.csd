// Example written by Matt Ingalls
// ARDUINO CODE:

void setup()  {
  // enable serial communication
  Serial.begin(9600);

  // declare pin 9 to be an output:
  pinMode(9, OUTPUT);
}

void loop()
{
  // only do something if we received something
  // (this should be at csound's k-rate)
  if (Serial.available())
  {

     // set the brightness of LED (connected to pin 9) to our input value
     int brightness = Serial.read();
     analogWrite(9, brightness);

     // while we are here, get our knob value and send it to csound
     int sensorValue = analogRead(A0);
     Serial.write(sensorValue/4); // scale to 1-byte range (0-255)
  }
}