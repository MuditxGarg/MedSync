#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>
#include <Hash.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebSrv.h>
#include <FS.h>
#include <LittleFS.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>

#include <SoftwareSerial.h>
SoftwareSerial mySerial(D1, D2);

// Replace with your network credentials
const char* ssid = "Lhbc_students";  // Enter SSID here
const char* password = "12345678";  // Enter Password here
const char* serverAddress = "http://192.168.32.29:80/esp8266_data"; // Change this to your server's IP

const unsigned long sendDataInterval = 5000;  // Send data every 5 seconds
const unsigned long accumulateDataInterval = 500; // Accumulate data every 500 ms

unsigned long lastSendTime = 0;
unsigned long lastAccumulateTime = 0;
int value = 0;
const int jsonArraySize = 10; // Change this to match your data size
std::vector<int> dataPoints(50); // Your data points
std::vector<float> sensor1List;
std::vector<float> sensor2List;
std::vector<float> sensor3List;
std::vector<float> sensor4List;
std::vector<float> sensor5List;
std::vector<float> sensor6List;
std::vector<float> sensor7List;
std::vector<float> sensor8List;
std::vector<float> sensor9List;
// Create AsyncWebServer object on port 80
AsyncWebServer server(80);

float sensor1Value = 0;
float sensor2Value = 0;
float sensor3Value = 0;
float sensor4Value = 0;
float sensor5Value = 0;
float sensor6Value = 0;
float sensor7Value = 0;
float sensor8Value = 0;
float sensor9Value = 0;

int counterr=0;
void setup() {
  // Serial port for debugging purposes
  Serial.begin(9600);
  mySerial.begin(115200);

  // Initialize SPIFFS
  if (!SPIFFS.begin()) {
    Serial.println("An Error has occurred while mounting SPIFFS");
    return;
  }

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }

  // Print ESP32 Local IP Address
  Serial.println(WiFi.localIP());

  // Route for root / web page
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    request->send(SPIFFS, "/index.html");
  });

  // Route to fetch sensor data
  server.on("/sensorData", HTTP_GET, [](AsyncWebServerRequest *request) {
  String json = "{\"sensor1\":" + String(sensor1Value) + ",";
  json += "\"sensor2\":" + String(sensor2Value) + ",";
  json += "\"sensor3\":" + String(sensor3Value) + ",";
  json += "\"sensor4\":" + String(sensor4Value) + ",";
  json += "\"sensor5\":" + String(sensor5Value) + ",";
  json += "\"sensor6\":" + String(sensor6Value) + ",";
  json += "\"sensor7\":" + String(sensor7Value) + ",";
  json += "\"sensor8\":" + String(sensor8Value) + ",";
  json += "\"sensor9\":" + String(sensor9Value) + "}";


    // Send the JSON response to the client
    request->send(200, "application/json", json);
  });

  // Start server
  server.begin();
}

void loop() {

  // Read data from the SoftwareSerial port (mySerial)
  if (mySerial.available()) {
    String sensorData = mySerial.readStringUntil('\n');
    // Split the sensor data into individual values based on the comma delimiter
    float sensorValues[9];
    int sensorIndex = 0;
    char *token = strtok(const_cast<char *>(sensorData.c_str()), ",");
    while (token != NULL && sensorIndex < 9) {  
      sensorValues[sensorIndex] = atof(token);
      token = strtok(NULL, ",");
      sensorIndex++;
    }
    // Now, sensorValues[] contains the individual sensor readings
    sensor1Value = sensorValues[0];
    sensor2Value = sensorValues[1];
    sensor3Value = sensorValues[2];
    sensor4Value = sensorValues[3];
    sensor5Value = sensorValues[4];
    sensor6Value = sensorValues[5];
    sensor7Value = sensorValues[6];
    sensor8Value = sensorValues[7];
    sensor9Value = sensorValues[8];
    Serial.println(sensorData);
    // Add the data to respective lists
    sensor1List.push_back(sensorValues[0]);
    sensor2List.push_back(sensorValues[1]);
    sensor3List.push_back(sensorValues[2]);
    sensor4List.push_back(sensorValues[3]);
    sensor5List.push_back(sensorValues[4]);
    sensor6List.push_back(sensorValues[5]);
    sensor7List.push_back(sensorValues[6]);
    sensor8List.push_back(sensorValues[7]);
    sensor9List.push_back(sensorValues[8]);
    if (counterr==10){
    //----------------------
    HTTPClient http;
    WiFiClient client;
    http.begin(client, serverAddress);
    http.addHeader("Content-Type", "application/json");
    // Construct the JSON string from the lists
      String aloo = "{";
      aloo += "\"xaxis\": [" + joinFloats(sensor1List) + "],";
      aloo += "\"yaxis\": [" + joinFloats(sensor2List) + "],";
      aloo += "\"zaxis\": [" + joinFloats(sensor3List) + "],";
      aloo += "\"heart\": [" + joinFloats(sensor4List) + "],";
      aloo += "\"spo\": [" + joinFloats(sensor5List) + "],";
      aloo += "\"mic\": [" + joinFloats(sensor6List) + "],";
      aloo += "\"temp\": [" + joinFloats(sensor7List) + "],";
      aloo += "\"pres\": [" + joinFloats(sensor8List) + "],";
      aloo += "\"presdiff\": [" + joinFloats(sensor9List) + "]";
      aloo += "}";
    int httpResponseCode = http.POST(aloo);
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println(httpResponseCode);
      Serial.println(response);
    } else {
      Serial.print("Error on sending data: ");
      Serial.println(httpResponseCode);
    }
    http.end();
    dataPoints.clear(); // Clear the data list after sending
    counterr=0;
    // Clear the data lists and reset the counter
      sensor1List.clear();
      sensor2List.clear();
      sensor3List.clear();
      sensor4List.clear();
      sensor5List.clear();
      sensor6List.clear();
      sensor7List.clear();
      sensor8List.clear();
      sensor9List.clear();
    }
    counterr+=1;
  delay(1000);
  }
  // Your loop code here
}
String joinFloats(const std::vector<float> &dataList) {
  // Helper function to join float values in a list into a comma-separated string
  String result = "";
  for (size_t i = 0; i < dataList.size(); i++) {
    result += String(dataList[i]);
    if (i < dataList.size() - 1) {
      result += ",";
    }
  }
  return result;
}
