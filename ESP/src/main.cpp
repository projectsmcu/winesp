#include <Arduino.h>
#include <DHT.h>
#include <HTTPClient.h>

#define LIGHT_SENSOR_PIN 36 // ESP32 pin GIOP36 (ADC0)
#define DHT_SENSOR_PIN  21 // ESP32 pin GIOP21 connected to DHT11 sensor
#define DHT_SENSOR_TYPE DHT11

#define PIN_RED    25 // GIOP4
#define PIN_GREEN  26 // GIOP0
#define PIN_BLUE   27 // GIOP2

// Replace with your network credentials
const char* ssid = "ZON-AFC0";
const char* password = "f933af58161c";

DHT dht_sensor(DHT_SENSOR_PIN, DHT_SENSOR_TYPE);

void setup() {
  // Initialize Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.print("Connected to WiFi! IP address:");

  Serial.begin(9600);
  dht_sensor.begin(); // initialize the DHT sensor
  pinMode(PIN_RED, OUTPUT);
  pinMode(PIN_GREEN, OUTPUT);
  pinMode(PIN_BLUE, OUTPUT);
    // Configure PWM frequency for the RGB pins (values can be adjusted)
  ledcSetup(0, 12000, 8);   // Channel 0, 12 kHz PWM, 8-bit resolution
  ledcSetup(1, 12000, 8);   // Channel 1, 12 kHz PWM, 8-bit resolution
  ledcSetup(2, 12000, 8);   // Channel 2, 12 kHz PWM, 8-bit resolution

  // Attach PWM channels to the RGB pins
  ledcAttachPin(PIN_RED, 0);     // Channel 0 -> Red pin
  ledcAttachPin(PIN_GREEN, 1);   // Channel 1 -> Green pin
  ledcAttachPin(PIN_BLUE, 2);    // Channel 2 -> Blue pin
}

void sendDataToServer(float temperature, float humidity, int light) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Not connected to WiFi. Cannot communicate data.");
    return;
  }

  // Create the form data to send
  String formData = "temperature=" + String(temperature) + "&humidity=" + String(humidity) + "&light=" + String(light);

  // Initialize the HTTPClient object
  HTTPClient http;

  // Set the target server and endpoint
  http.begin("http://192.168.1.6:5000/receive-data");
  
  // Set the content type header
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  // Send the POST request with the form data
  int httpResponseCode = http.POST(formData);

  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("Server response: " + response);
  } else {
    Serial.print("Error sending request. Error code: ");
    Serial.println(httpResponseCode);
  }

  // Clean up
  http.end();
}

void recieveData() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Not connected to WiFi. Cannot communicate data.");
    return;
  }

  // Initialize the HTTPClient object
  HTTPClient http;

  // Set the target server
  http.begin("http://192.168.1.6:5000/send-data");

  // Send the POST request with the form data
  int httpCode = http.GET();

  
  if (httpCode > 0) {
    String payload = http.getString();
    Serial.println("Server response: [" + String(httpCode) + "] - " + payload);
  } else {
    Serial.print("Error sending request. Error code: ");
    Serial.println(httpCode);
  }

  // Clean up
  http.end();
}

void printValues(float humi, float tempC, float tempF, int ligth) {
  // check whether the reading is successful or not
  if ( isnan(tempC) || isnan(tempF) || isnan(humi)) {
    Serial.println("Failed to read from DHT sensor!");
  } else {
    Serial.print("Humidity: ");
    Serial.print(humi);
    Serial.print("%");
    Serial.print("  |  ");
    Serial.print("Temperature: ");
    Serial.print(tempC);
    Serial.print("°C  ~  ");
    Serial.print(tempF);
    Serial.print("°F  |  ");
  }
  
  Serial.print("Light = ");
  Serial.print(ligth);   // the raw analog reading
  // We'll have a few threshholds, qualitatively determined
  if (ligth < 40) {
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
  ledcWrite(0, R);
  ledcWrite(1, G);
  ledcWrite(2, B);
}

void loop() {
  // read humidity
  float humi  = dht_sensor.readHumidity();
  // read temperature in Celsius
  float tempC = dht_sensor.readTemperature();
  // read temperature in Fahrenheit
  float tempF = dht_sensor.readTemperature(true);
  // read the light sensor value
  int ligth = analogRead(LIGHT_SENSOR_PIN);

/*
  // print sensor values
  printValues(humi, tempC, tempF, ligth);

  // Send data to server
  sendDataToServer(humi, tempC, ligth);
  recieveData();
*/

  // set the LED color
  setColor(255, 0, 0);

  // wait a 2.5 seconds between readings
  delay(2500);
}
