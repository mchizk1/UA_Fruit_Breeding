#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

Adafruit_BNO055 bno = Adafruit_BNO055(55);

#define MILLISECONDS_PER_SECOND 1000.0
#define MILLIMETERS_PER_METER  1000.0
#define PI_SQUARED 9.8696

const byte photoDiodepin = A5;
volatile uint32_t Cycletime = 0;
float Frequency;
float Displacement;
bool NewCycletime = false;
bool FirstEdge = true;
uint32_t Tachtimer;

void setup() {
  // put your setup code here, to run once:

  pinMode(photoDiodepin, INPUT);  //Photodiode output on A5 used as digital input
  
  attachInterrupt(digitalPinToInterrupt(photoDiodepin), isrGetTime2, RISING);  //Each rising edge of the photodiode creates an interrupt
  delay(5000);

  Serial.begin(115200);

   if (!bno.begin())
  {
    // There was a problem detecting the BNO055 ... check your connections 
    Serial.println("No BNO055 detected");
    exit(1);
  }

  bno.setExtCrystalUse(true);

  uint8_t system, gyro, accel, mag = 0;
  bno.getCalibration(&system, &gyro, &accel, &mag);
    while(accel < 3){
      bno.getCalibration(&system, &gyro, &accel, &mag);
      Serial.println(accel, DEC);
      delay(100);
  }
  Serial.println("Accelerometer Calibrated.");
  Serial.println();
  Serial.println("Beginning Tachometer Measurements in 10 Seconds");
  Serial.println();
  delay(10000);
  Tachtimer = millis();
}

void loop() {
  // put your main code here, to run repeatedly:
  
  if (NewCycletime){
    Frequency =  MILLISECONDS_PER_SECOND / (float)Cycletime;      // Calculate the frequency
    NewCycletime = false;
    Serial.println();
    Serial.print(" Frequency of Motor = ");
    Serial.print(Frequency);  Serial.println(" Hz");
    imu::Vector<3> acc = bno.getVector(Adafruit_BNO055::VECTOR_ACCELEROMETER);   //get acceleration vectors from BNO chip.  Floating point type in m/s^2
    Displacement = (acc.y()* MILLIMETERS_PER_METER)/(float)( 4.0 * PI_SQUARED*Frequency*Frequency); //use acceleration in y or x because z tends to have more error.
    Serial.println();                                                                               //convert to mm for precision
    Serial.print(" Displacement of Table in Y = ");
    Serial.print(Displacement,4); Serial.println(" mm");     
  }
}

void isrGetTime(){                      //Keep the interrupt service routine brief as possible
                                        //The millis() timer function does not increment during an ISR
    Cycletime = millis() - Tachtimer;   //Capture elapsed time since last reset of the timer
    NewCycletime = true;                //Let the main loop know we have a new measurement
    Tachtimer = millis();               //Reset the timer
  }
  
void isrGetTime2(){                     //When the frequency reading comes twice per turn of the motor
  if (FirstEdge){                       //and comes as a pair with one number many times larger than the next, install this ISR
    FirstEdge = false;                  //If the photodiode sees two edges per rotation, skip the first one
  }
  else{                                 //And read the timer every other inerrupt
    Cycletime = millis() - Tachtimer;   //Capture elapsed time since last reset of the timer
    NewCycletime = true;                //Let the main loop know we have a new measurement
    FirstEdge = true;
    Tachtimer = millis();               //Reset the timer
  }
  
}
