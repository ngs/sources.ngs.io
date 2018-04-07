```cpp
#include <SevSeg.h>

const int SENSOR_PIN = A0;
const int UPDATER_INTERVAL = 1000;
SevSeg sevseg;
unsigned long timer;

void setup() {
  Serial.begin(9600);
  sevseg.Begin(0, 13, 4, 3, 100, 6, 2, 9, 11, 12, 5, 8, 10);
  sevseg.Brightness(90);
  timer = millis();
}

void loop() {
  sevseg.PrintOutput();
  unsigned long mils = millis();
  if (mils - timer >= UPDATER_INTERVAL) {
    timer = mils;
    int value = analogRead(SENSOR_PIN);
    int templature = map(value, 0, 205, 0, 10000);
    Serial.println(templature);
    sevseg.NewNum(templature,(byte) 2);
  }
}
```
