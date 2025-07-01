const int temt6000Pin = A5;
const int ledPins[] = { 5, 6, 9, 10, 11, A2, A3, A4};
const int ledSize = 8;
const int threshold = 20;
const int ledDelay = 500;
int ledCursor;
void setup() {
  ledCursor = 0;
  pinMode(temt6000Pin, INPUT);
  for(int i = 0; i < ledSize; i++) {
    pinMode(ledPins[i], OUTPUT);
  }
}
boolean isDark() {
  int value = analogRead(temt6000Pin);
  return value < threshold;
}
void allOff() {
  for(int i = 0; i < ledSize; i++) {
    digitalWrite(ledPins[i], LOW);
    analogWrite(ledPins[i], 0);
  }
}
void allOn() {
  for(int i = 0; i < ledSize; i++) {
    digitalWrite(ledPins[i], HIGH);
    analogWrite(ledPins[i], 0xff);
  }
}
void loop() {
  if(isDark()) {
    digitalWrite(ledPins[ledCursor], HIGH);
    analogWrite(ledPins[ledCursor], 0xff);
    delay(ledDelay);
    digitalWrite(ledPins[ledCursor], LOW);
    analogWrite(ledPins[ledCursor], 0);
    if(++ledCursor == ledSize) {
      ledCursor = 0;
    }
  }
  else {
    allOff();
  }
}
