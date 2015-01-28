/*
  LiquidCrystal Library - Hello World
 
 Demonstrates the use a 16x2 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the 
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.
 
 This sketch prints "Hello World!" to the LCD
 and shows the time.
 
 The circuit:
 * LCD RS pin to digital pin 12
 * LCD Enable pin to digital pin 11
 * LCD D4 pin to digital pin 5
 * LCD D5 pin to digital pin 4
 * LCD D6 pin to digital pin 3
 * LCD D7 pin to digital pin 2
 * LCD R/W pin to ground
 * LCD VSS pin to ground
 * LCD VCC pin to 5V
 * 10K resistor:
 * ends to +5V and ground
 * wiper to LCD VO pin (pin 3)
 
 Library originally added 18 Apr 2008
 by David A. Mellis
 library modified 5 Jul 2009
 by Limor Fried (http://www.ladyada.net)
 example added 9 Jul 2009
 by Tom Igoe
 modified 22 Nov 2010
 by Tom Igoe
 
 This example code is in the public domain.
 
 http://www.arduino.cc/en/Tutorial/LiquidCrystal
 */

// include the library code:
#include <LiquidCrystal.h>
#include <OneWire.h>

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(7, 8, 9, 10, 11, 12);

unsigned long time;

int rPin = A0;    // select the input pin for the potentiometer
int ledPin = 13;      // select the pin for the LED
int fanPin = 6;
int rValue = 0;  // variable to store the value coming from the sensor
int fanValue = 0;
const int fanV = 255; // a value between 0 - 255 the fan stops working smaller than 25
boolean control_method = false;

//Varibles used for calculations
int NbTopsFan; 
int Calc;
int time_tt;

//The pin location of the sensor
int hallsensor = 2;


typedef struct{                  //Defines the structure for multiple fans and their dividers
  char fantype;
  unsigned int fandiv;
}
fanspec;

//Definitions of the fans
fanspec fanspace[3]={
  {
    0,1    }
  ,{
    1,2    }
  ,{
    2,8    }
};

char fan = 1;   //This is the varible used to select the fan and it's divider, set 1 for unipole hall effect sensor 
//and 2 for bipole hall effect sensor 


void rpm ()      //This is the function that the interupt calls 
{ 
  NbTopsFan++; 
} 

#define MAX_DS1820_SENSORS 2            //Anzahl der angeschlossenen Temperatursensoren angeben
char* Sensorname[]={
  "AUSSEN", "INNEN "}; //Namen für die Orte an denen sich die Sensoren befinden

//Temperatur Sensoren
OneWire  ds(4);                        //Pin an dem die Datenleitung des ds18s20 hängt
byte addr[MAX_DS1820_SENSORS][8];

#define DEBUG_MODE true  

void setup() {
  Serial.begin(9600);
  byte i;
  pinMode(ledPin, OUTPUT);  
  pinMode(hallsensor, INPUT); 
  //  digitalWrite(hallsensor, LOW);
  // start the fan
  analogWrite(fanPin, 255);
  attachInterrupt(0, rpm, RISING); 
  // set up the LCD's number of columns and rows: 
  lcd.begin(16, 2);

  //Anzahl der angeschlossenen Sensoren durchgehen
  for ( i = 0; i < MAX_DS1820_SENSORS; i++) 
  { 
    if (!ds.search(addr[i]))
    {
      lcd.setCursor(0,0);
      lcd.print("No more sensors.");
      ds.reset_search();
      delay(250);
      return;
    }
  }

  Serial.print("Timestamp");
  Serial.print(",\t");
  Serial.print ("rValue"); 
  Serial.print(",\t");
  Serial.print ("fanValue"); 
  Serial.print(",\t");
  Serial.print ("rpm"); 
  Serial.print(",\t");
  Serial.print ("Temp_1"); 
  Serial.print(",\t");
  Serial.print ("Temp_2"); 

  Serial.println();
}

void loop() {
  // set the cursor to column 0, line 1
  // (note: line 1 is the second row, since counting begins with 0):
  NbTopsFan = 0;	//Set NbTops to 0 ready for calculations
  sei();		//Enables interrupts
  delay (2000);	//Wait 1 second
  cli();		//Disable interrupts
  Calc = ((NbTopsFan * 30)/fanspace[fan].fandiv); //Times NbTopsFan (which is apprioxiamately the fequency the fan is spinning at) by 60 seconds before dividing by the fan's divider
  time = millis();
  //prints time since program started

  rValue = analogRead(rPin);  
  fanValue = rValue/4;
  //  fanValue = 0;
  if (control_method == true){
    fanValue = rValue/4;
  }
  else{
    fanValue = fanV;
  }
  analogWrite(fanPin, fanValue);

  Serial.print(time);
  Serial.print(",\t");
  Serial.print (rValue);
  Serial.print(",\t");
  Serial.print (100 * fanValue / 255);
  Serial.print(",\t");
  Serial.print (Calc, DEC); //Prints the number calculated above
  Serial.print(",\t");


  readTemperature();

  Serial.println();

  lcd.clear();  
  lcd.setCursor(0, 0);
  lcd.print("Voltage:");
  lcd.setCursor(9, 0);
  lcd.print(100*fanValue/255);
  lcd.setCursor(12, 0);
  lcd.print("% of 5V");
  lcd.setCursor(0, 1);
  // print the number of seconds since reset:
  lcd.print("RPM:");
  lcd.setCursor(6, 1);
  lcd.print(Calc);
}



void readTemperature()
{
  int HighByte, LowByte, TReading, SignBit, Tc_100, Temp, Fract;
  char buf[20];

  byte i, sensor;
  byte present = 0;
  byte data[12];

  for (sensor=0; sensor<MAX_DS1820_SENSORS; sensor++)
  {
    if (OneWire::crc8( addr[sensor], 7) != addr[sensor][7])
    {
      lcd.setCursor(0,0);
      lcd.print("CRC is not valid");
      return;
    }

    if ( addr[sensor][0] != 0x10)
    {
      lcd.setCursor(0,0);
      lcd.print("Device is not a DS18S20 family device.");
      return;
    }

    ds.reset();
    ds.select(addr[sensor]);
    ds.write(0x44,1);         // start conversion, with parasite power on at the end

    delay(1000);

    present = ds.reset();
    ds.select(addr[sensor]);    
    ds.write(0xBE);         // Read Scratchpad

    for (i = 0; i < 9; i++)
    {
      data[i] = ds.read();
    }

    LowByte = data[0];
    HighByte = data[1];
    TReading = (HighByte << 8) + LowByte;
    SignBit = TReading & 0x8000;
    if (SignBit) // negative
    {
      TReading = (TReading ^ 0xffff) + 1;
    }
    Tc_100 = (TReading*100/2);    

    Temp = Tc_100 / 100;
    Fract = Tc_100 % 100;

    sprintf(buf, "%c%d.%d\260C ",SignBit ? '-' : '+', Temp, Fract < 10 ? 0 : Fract);

    lcd.clear();  
    lcd.setCursor(0,0);    
    lcd.print(Sensorname[sensor]);
    lcd.setCursor(0,1);
    lcd.print(buf);

    if(DEBUG_MODE == true) {
      Serial.print(buf);
      if(sensor<MAX_DS1820_SENSORS-1){
        Serial.print(",\t");
      }
    }
  }
}


