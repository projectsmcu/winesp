from flask import Flask, request
import requests

app = Flask(__name__)

@app.route('/exchange-data', methods=['POST'])
def receive_data():
    temperature = request.form.get('temperature')
    humidity = request.form.get('humidity')
    light = request.form.get('light')
    print (humidity, temperature, light)
    return 'Data received successfully!'


@app.route('/exchange-data', methods=['GET'])
def send_data_to_esp32():
    print('ESP connected to the server\n')
    payload = {'red': 0, 'green': 0, 'blue': 1, 'alert': 0}
    return payload


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
