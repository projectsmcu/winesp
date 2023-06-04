#include <Arduino.h>
#include <DHT.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "pitches.h"

#define LIGHT_SENSOR_PIN 36 // ESP32 pin GIOP36 (ADC0) - orange cable

#define DHT_SENSOR_PIN  21 // ESP32 pin GIOP21 connected to DHT11 sensor - white cable
#define DHT_SENSOR_TYPE DHT11

#define BUZZZER_PIN  13 // ESP32 pin GIOP15 connected to piezo buzzer - yellow cable

#define PIN_RED    22 // ESP32 pin GIOP22 connected to red LED - red cable
#define PIN_GREEN  18 // ESP32 pin GIOP18 connected to green LED - green cable
#define PIN_BLUE   19 // ESP32 pin GIOP19 connected to blue LED - blue cable

// Replace with your network credentials
const char* ssid = "ZON-AFC0";
const char* password = "f933af58161c";
const char* serverURL = "http://192.168.1.9:5000/exchange-data";

DHT dht_sensor(DHT_SENSOR_PIN, DHT_SENSOR_TYPE);

int melody[] = {
  NOTE_C4, NOTE_G3, NOTE_G3, NOTE_A3, NOTE_G3, 0, NOTE_B3, NOTE_C4
};
int noteDurations[] = {
  4, 8, 8, 4, 4, 4, 4, 4
};
const int JSON_BUFFER_SIZE = 256;


void setup() {
  Serial.begin(9600);

  // Initialize Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.print("Connected to WiFi! IP address:");
  Serial.println(WiFi.localIP());

  dht_sensor.begin(); // initialize the DHT sensor
  pinMode(PIN_RED, OUTPUT); // initialize the red LED
  pinMode(PIN_GREEN, OUTPUT); // initialize the green LED
  pinMode(PIN_BLUE, OUTPUT);  // initialize the blue LED

}


void printValues(float humi, float temp, int ligth) {
  // check whether the reading is successful or not
  if ( isnan(temp) || isnan(humi)) {
    Serial.println("Failed to read from DHT sensor!");
  } else {
    Serial.print("Measured values: Humidity =");
    Serial.print(humi);
    Serial.print("%");
    Serial.print("  |  ");
    Serial.print("Temperature = ");
    Serial.print(temp);
    Serial.print("°C |  ");
  }
  
  Serial.print("Light = ");
  Serial.print(ligth);  // the raw analog reading
  if (ligth < 40) {   // We'll have a few threshholds, qualitatively determined
    Serial.println(" => Dark");
  } else if (ligth < 800) {
    Serial.println(" => Dim");
  } else if (ligth < 2000) {
    Serial.println(" => Light");
  } else if (ligth < 3200) {
    Serial.println(" => Bright");
  } else {
    Serial.println(" => Very bright");
  }

}

void setColor(int R, int G, int B) {
  // turns on/off the LED as requested by the server
  digitalWrite(PIN_RED, R);
  digitalWrite(PIN_GREEN, G);
  digitalWrite(PIN_BLUE, B);
}

void playSound(bool alert) {
  if (alert) {
    for (int thisNote = 0; thisNote < 8; thisNote++) {
      int noteDuration = 1000 / noteDurations[thisNote];
      tone(BUZZZER_PIN, melody[thisNote], noteDuration);

      int pauseBetweenNotes = noteDuration * 1.30;
      delay(pauseBetweenNotes);
      noTone(BUZZZER_PIN);
    }
  }
}

void sendDataToServer(float temperature, float humidity, int light) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Not connected to WiFi. Cannot communicate data.");
  }

  // Create the form data to send
  String formData = "temperature=" + String(temperature) + "&humidity=" + String(humidity) + "&light=" + String(light);

  // Initialize the HTTPClient object
  HTTPClient http;

  // Set the target server and endpoint
  http.begin(serverURL);
  
  // Set the content type header
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  // Send the POST request with the form data
  int httpResponseCode = http.POST(formData);

  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("Server response: [" + String(httpResponseCode) + "] - " + response);
  } else {
    Serial.print("Error sending request. Error code: ");
    Serial.println(httpResponseCode);
    for (int i = 0; i < 5; i++) { // blink the LED if can't communicate
      setColor(1, 1, 1);
      delay(500);
      setColor(0, 0, 0);
      delay(500);
    }
  }
  // Clean up
  http.end();
}

void recieveData() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Not connected to WiFi. Cannot communicate data.");
  }

  // Initialize the HTTPClient object
  HTTPClient http;

  // Set the target server
  http.begin(serverURL);

  // Send the POST request with the form data
  int httpCode = http.GET();

  
  if (httpCode > 0) {
    String payload = http.getString();
    Serial.println("Server response: [" + String(httpCode) + "] - " + payload);
    DynamicJsonDocument jsonDoc(JSON_BUFFER_SIZE);
    DeserializationError error = deserializeJson(jsonDoc, payload);
    setColor(jsonDoc["red"], jsonDoc["green"], jsonDoc["blue"]); // set the LED color depending on the conditions
    playSound(jsonDoc["alert"]); // play the buzzer if needed
  } else {
    Serial.print("Error recieving data. Error code: ");
    Serial.println(httpCode);
        for (int i = 0; i < 5; i++) { // blink the LED if can't communicate
      setColor(1, 1, 1);
      delay(500);
      setColor(0, 0, 0);
      delay(500);
    }
  }
  // Clean up
  http.end();
}


void loop() {
  float humi  = dht_sensor.readHumidity();  // read humidity
  float temp = dht_sensor.readTemperature();  // read temperature in Celsius
  // float temp = dht_sensor.readTemperature(true);  // uncomment and comment above to read temperature in Fahrenheit
  int ligth = analogRead(LIGHT_SENSOR_PIN);  // read the light sensor value

  // print sensor values
  printValues(humi, temp, ligth);

  // comunicate data to server
  sendDataToServer(humi, temp, ligth);
  delay(2000);

  recieveData();
  delay(2000);
}
