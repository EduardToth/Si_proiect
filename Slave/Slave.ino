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
  
  lcd.setCursor(0, 1);
  lcd.print("Initializing...");
  
  while(!hc05.available()){
    hc05.write((char) ROOM_ID);
    delay(500);
  }
  
  int readMsg = 0;
  while(readMsg == 0){
    if (hc05.available()){
      char aux = hc05.read();
      if(aux != '\n' && RoomNameLength < 12){
        RoomName[RoomNameLength++] = aux;
      }else{
        RoomName[RoomNameLength++] = ':';
        RoomName[RoomNameLength++] = ' ';
        RoomName[RoomNameLength] = '\0';
        readMsg = 1;
      }
    }
  }
  
  lcd.setCursor(0, 1);
  lcd.print("               ");
}

void loop()
{
  if(hc05.available()){
    unsigned char temp = hc05.read();
    desired_temperature = temp & 0x3f;
    remoteControl = (temp >> 6) & 1;
  }

  if(remoteControl == 0){
    potentiometer = analogRead(potPin);
    potentiometer = map(potentiometer, 0, 1023, 35, 15);
    desired_temperature = potentiometer & 0x3f;
  }
  
  lcd.setCursor(0, 0);
  lcd.print("Temp. set: ");
  lcd.print(desired_temperature);
  
  //turn on/off solenoid and the pump
  if(Serial.available()) 
  {  
    x = Serial.read();
    
    lcd.setCursor(0, 1);
    lcd.print(RoomName);
    lcd.print(x);
    hc05.write(x);
    
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
