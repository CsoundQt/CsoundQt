// Example written by Sigurd Saue
// ARDUINO CODE:

// Analog pins
int potPin = 0;
int lightPin = 1;

// Digital pin
int buttonPin = 2;

// Value IDs (must be between 128 and 255)
byte potID = 128;
byte lightID = 129;
byte buttonID = 130;

// Value to toggle between inputs
int select;

/*
** Two functions that handles serial send of numbers of varying length
*/

// Recursive function that sends the bytes in the right order
void serial_send_recursive(int number, int bytePart)
{
  if (number < 128) {        // End of recursion
    Serial.write(bytePart);  // Send the number of bytes first
  }
  else {
    serial_send_recursive((number >> 7), (bytePart + 1));
  }
  Serial.write(number % 128);  // Sends one byte
}

void serial_send(byte id, int number)
{
  Serial.write(id);
  serial_send_recursive(number, 1);
}

void setup()  {
  // enable serial communication
  Serial.begin(9600);
  pinMode(buttonPin, INPUT);
}

void loop()
{
  // Only do something if we received something (at csound's k-rate)
  if (Serial.available())
  {
      // Read the value (to empty the buffer)
       int csound_val = Serial.read();

       // Read one value at the time (determined by the select variable)
       switch (select) {
         case 0: {
           int potVal = analogRead(potPin);
           serial_send(potID, potVal);
         }
         break;
         case 1: {
           int lightVal = analogRead(lightPin);
           serial_send(lightID, lightVal);
         }
         break;
         case 2: {
           int buttonVal = digitalRead(buttonPin);
           serial_send(buttonID, buttonVal);
         }
         break;
       }

       // Update the select (0, 1 and 2)
       select = (select+1)%3;
  }
}