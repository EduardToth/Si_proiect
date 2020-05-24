#include <SoftwareSerial.h>
#include <LiquidCrystal.h>
#include <SoftwareSerial.h>

#define ROOM_ID 0
char RoomName[20] = "Room name:";
int RoomNameLength = 0;
unsigned char remoteControl;

SoftwareSerial hc05(11, 10); //Tx,Rx from the bluetooth module

const int motorA1 = 6;
const int motorA2 = 7;
const int motorB1 = 8;
const int motorB2 = 9;

LiquidCrystal lcd(13, 12, 5, 4, 3, 2);

int potPin = 0;
unsigned char x;
int desired_temperature;
int potentiometer;

void setup()
{
  Serial.begin(38400);
  hc05.begin(38400);  // baud rate for the bluetooth module
  lcd.begin(16, 2);
  pinMode(motorA1, OUTPUT);
  pinMode(motorA2, OUTPUT);
  pinMode(motorB1, OUTPUT);
  pinMode(motorB2, OUTPUT);

  // give feedback to user that something is happening
  lcd.setCursor(0, 1);
  lcd.print("Initializing...");

  // the first information shared between arduino and the mobile app: the room's ID
  // until the mobile app is available, arduino tries to send it's room ID
  while(!hc05.available()){
    hc05.write((char) ROOM_ID);
    delay(500);
  }

  // the second information shared between arduino and the mobile app: the room's name
  // the mobile app sends the room name as a string and arduino saves it to a char array byte by byte
  int readMsg = 0;
  while(readMsg == 0){
    if (hc05.available()){                      // when a byte from the room's name is available on bluetooth
      char aux = hc05.read();                   // arduino reads that byte (char)
      if(aux != '\n' && RoomNameLength < 12){   // if it doesn't read the marker of the end of the string and there is still room on the lcd
        RoomName[RoomNameLength++] = aux;       // it saves that byte (char)
      }else{                                    // else
        RoomName[RoomNameLength++] = ':';       // it finishes the char array
        RoomName[RoomNameLength++] = ' ';
        RoomName[RoomNameLength] = '\0';
        readMsg = 1;                            // and moves on
      }
    }
  }

  // clear the lcd
  lcd.setCursor(0, 1);
  lcd.print("               ");
}

void loop()
{
  if(hc05.available()){                 // if there is information available on bluetooth
    unsigned char temp = hc05.read();   // read it
    
                                        // the format of the byte received from the mobile app is:
    desired_temperature = temp & 0x3f;  // 6 most LSB are the desired temperature
    remoteControl = (temp >> 6) & 1;    // byte 7 is a toggle between mobile app and manual on board potentiometer
  }

  // if mobile app toggle is off, read the temperature from the on board potentiometer
  if(remoteControl == 0){
    potentiometer = analogRead(potPin);
    potentiometer = map(potentiometer, 0, 1023, 35, 15);
    desired_temperature = potentiometer & 0x3f;
  }

  // feedback for the user on the lcd
  lcd.setCursor(0, 0);
  lcd.print("Temp. set: ");
  lcd.print(desired_temperature);
  
  //turn on/off solenoid and the pump
  if(Serial.available()) 
  {  
    x = Serial.read(); // read current temperature from sensor

    // feedback for the user on the lcd
    lcd.setCursor(0, 1);
    lcd.print(RoomName);
    lcd.print(x);
    hc05.write(x); // send current temperature to mobile app

    if(x < desired_temperature)
    {
      digitalWrite(motorA1, LOW); //open the solenoid
      digitalWrite(motorA2, LOW);
      digitalWrite(motorB1, HIGH);
      digitalWrite(motorB2, LOW); //start the pump
    }
    else
    {
      digitalWrite(motorA1, HIGH); //close the solenoid
      digitalWrite(motorA2, LOW);
      digitalWrite(motorB1, LOW); //stop the pump
      digitalWrite(motorB2, LOW);
    }
  }
  
  delay(10);
}
