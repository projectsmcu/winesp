import time
import os
from flask import Flask, render_template, request
from flask_socketio import SocketIO
import sqlite3
import base64


app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)


global caveIdToAssign
caveIdToAssign = 0


@app.route('/exchange-data', methods=['POST'])
def receive_data():
    # get the json data
    data = request.get_json()
    temperature = data['temperature']
    humidity = data['humidity']
    light = data['light']
    if light > 3500:
        light = 100
    else:
        light = light/3500*100
    caveId = data['caveId']
    # print (humidity, temperature, light, caveId)
    # insert the data into the database
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    c.execute("INSERT INTO cave_data (cave_id, temperature, humidity, light, time) VALUES (?, ?, ?, ?, ?)", (caveId, temperature, humidity,light , time.strftime('%Y-%m-%d %H:%M:%S')))
    # print(time.strftime('%Y-%m-%d %H:%M:%S'))
    conn.commit()
    # get the warning and critical values for the cave
    c.execute("SELECT temperatureWarning, temperatureCritical, humidityWarning, humidityCritical, lightWarning, lightCritical FROM cave_value WHERE cave_id = ?", (caveId,))
    values = c.fetchone()
    if values == None:
        values = (10000., 1000., 10000., 10000., 10000., 100000.)
    temperatureAlert, humidityAlert, lightAlert, criticalAlert = 0, 0, 0, 0
    if temperature > values[0]:
        # print("temperature alert with value " + str(values[0]) + " and temperature " + str(temperature))
        temperatureAlert = 1
    if humidity > values[2] :
        # print("humidity alert with value " + str(values[2]) + " and humidity " + str(humidity))
        humidityAlert = 1
    if light > values[4]:
        # print("light alert with value " + str(values[4]) + " and light " + str(light))
        lightAlert = 1
    if temperature > values[1] or humidity > values[3] or light > values[5]:
        # print("critical alert")
        criticalAlert = 1
    conn.close()
    payload = {'red': temperatureAlert, 'green': lightAlert, 'blue': humidityAlert, 'alert': criticalAlert}
    return payload
    

@app.route('/get-id', methods=['GET'])
def get_id():
    payload = {'id': caveIdToAssign}
    return payload

@socketio.on('connect')
def connect():
    print("a client connected")

@socketio.on('disconnect')
def disconnect():
    print('Client disconnected')

@socketio.on('connectCave')
def connectCave(data):
    global caveIdToAssign
    caveIdToAssign = int(data['caveID'])
    # print('Cave ready to be connected to the server' + str(caveIdToAssign))


@socketio.on('getCavesHome')
def getCave(user):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #get the user's caves and for each cave get the cave's name , id ,  last reccorded data , total number of bottles in the user's caves by color
    c.execute("SELECT caves.id, name, location FROM caves JOIN cave_users ON caves.id = cave_users.cave_id WHERE user_id = ?", (user,))
    caves = c.fetchall()
    id_caves = [cave[0] for cave in caves]
    #get the cave's
    stats,random_bottles,images = [],[],[]
    for cave in id_caves:
        c.execute("SELECT * FROM cave_data WHERE cave_id = ? ORDER BY time DESC LIMIT 1", (cave,))
        stats.append(c.fetchone())
        if stats[-1] == None:
            stats[-1] = (cave, 0., 0., 0., 'No data')
        c.execute("SELECT name,id,color,region,country,year,rating,price,grape,quantity,description FROM wine WHERE cave_id = ? ORDER BY RANDOM() LIMIT 10", (cave,))
        #if the user has no bottles in his cave, we send an empty list
        random_bottles.append(c.fetchall())
        if len(random_bottles[-1]) == 0:
            random_bottles[-1] = []
        else:
            images.append([])
            # for every bottle check if it has a picture (ie images/bottles/bottle_id.jpg exists)
            for i in range(len(random_bottles[len(images)-1])):
                if os.path.isfile('images/bottles/' + str(random_bottles[len(images)-1][i][1]) + '.jpg'):
                    images[-1].append(base64.b64encode(open('images/bottles/' + str(random_bottles[len(images)-1][i][1]) + '.jpg', 'rb').read()).decode('utf-8'))
                else:
                    images[-1].append(None)
    conn.close()
    socketio.emit('caveHome', [caves, stats, random_bottles, images])
    
@socketio.on('getCavesManagementPage')
def getCaveManagement(user):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #get the user's caves and for each cave get the cave's name , id ,  last reccorded data , total number of bottles in the user's caves by color
    c.execute("SELECT cave_id, name FROM caves JOIN cave_users ON caves.id = cave_users.cave_id WHERE user_id = ?", (user,))
    caves = c.fetchall()
    id_caves = [cave[0] for cave in caves]
    #get the cave's stats
    stats,bottlesnumber = [],[]
    for cave in id_caves:
        c.execute("SELECT time FROM cave_data WHERE cave_id = ? ORDER BY time DESC LIMIT 1", (cave,))
        stats.append(c.fetchone())
        if stats[-1] == None:
            stats[-1] = ('No data',)
        c.execute("SELECT color, COUNT(id) FROM wine WHERE cave_id = ? GROUP BY color", (cave,))
        bottlesnumber.append(c.fetchall())
        if len(bottlesnumber[-1]) < 3:
            for color in ['red', 'white', 'rose']:
                if color not in [bottle[0] for bottle in bottlesnumber[-1]]:
                    bottlesnumber[-1].append((color, 0))
    conn.close()
    socketio.emit('cavesManagementPage', [caves, stats, bottlesnumber])

@socketio.on('addCave')
def addCave(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #add the cave
    c.execute("INSERT INTO caves (name, location) VALUES (?, ?)", (data['caveName'], data['caveLocation']))
    conn.commit()
    #get the cave id
    c.execute("SELECT id FROM caves WHERE name = ? AND location = ?", (data['caveName'], data['caveLocation']))
    cave_id = c.fetchone()[0]
    c.execute("INSERT INTO cave_users (cave_id, user_id) VALUES (?, ?)", (cave_id, data['userID']))
    conn.commit()
    c.execute("INSERT INTO cave_value (cave_id, temperatureWarning , temperatureCritical , humidityWarning , humidityCritical , lightWarning , lightCritical) VALUES (?, ?, ?, ?, ?, ?, ?)", (cave_id, 16, 27, 52, 72, 52, 72))
    conn.commit()
    conn.close()
    socketio.emit('caveAdded', [cave_id])


@socketio.on('getCavePage')
def getCavePage(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    cave_id = data['caveID']

    #get the cave's name and location
    c.execute("SELECT name, location FROM caves WHERE id = ?", (cave_id,))
    caves = c.fetchone()

    #get the cave's stats
    c.execute("SELECT * FROM cave_data WHERE cave_id = ? ORDER BY time DESC LIMIT 1", (cave_id,))
    stats =c.fetchone()
    if stats == None:
        stats = (cave_id, 0., 0., 0., 'No data')
    

    c.execute("SELECT name,id,color,region,country,year,rating,price,grape,quantity,description  FROM wine WHERE cave_id = ?", (cave_id,))
    #if the user has no bottles in his cave, we send an empty list
    bottles = c.fetchall()
    images = []
    if len(bottles) == 0:
        bottles = []
    else:
        # for every bottle check if it has a picture (ie images/bottles/bottle_id.jpg exists)
        for i in range(len(bottles)):
            if os.path.isfile('images/bottles/' + str(bottles[i][1]) + '.jpg'):
                images.append(base64.b64encode(open('images/bottles/' + str(bottles[i][1]) + '.jpg', 'rb').read()).decode('utf-8'))
            else:
                images.append(None)


    conn.close()
    socketio.emit('cavePage', [caves, stats, bottles, cave_id, images])


@socketio.on('modifyCave')
def modifyCave(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #modify the cave
    c.execute("UPDATE caves SET name = ?, location = ? WHERE id = ?", (data['caveName'], data['caveLocation'], data['caveID']))
    conn.commit()
    conn.close()
    socketio.emit('caveModified', [data['caveID']])

@socketio.on('deleteCave')
def deleteCave(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #delete the cave
    c.execute("DELETE FROM caves WHERE id = ?", (data['caveID'],))
    conn.commit()
    #delete the relation of the caves in data, cave_user, wine
    c.execute("DELETE FROM cave_data WHERE cave_id = ?", (data['caveID'],))
    conn.commit()
    c.execute("DELETE FROM cave_users WHERE cave_id = ?", (data['caveID'],))
    conn.commit()
    c.execute("DELETE FROM wine WHERE cave_id = ?", (data['caveID'],))
    conn.commit()
    c.execute("DELETE FROM cave_value WHERE cave_id = ?", (data['caveID'],))
    conn.close()
    socketio.emit('caveDeleted', [data['caveID']])

@socketio.on('addBottle')
def addBottle(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #add the bottle
    c.execute("INSERT INTO wine (name , color , country , region , year , grape , price ,quantity , rating , description , cave_id ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ( data['bottleName'], data['bottleColor'], data['bottleCountry'], data['bottleRegion'], int(data['bottleYear']), data['bottleGrappes'],float(data['bottlePrice']),float(data['bottleQuantity']), float(data['bottleRating']), data['bottleComment'], int(data['caveID'])))
    conn.commit()
    #get the bottle id
    c.execute("SELECT id FROM wine WHERE name = ? AND color = ? AND country = ? AND region = ? AND year = ? AND grape = ? AND price = ? AND rating = ? AND description = ? AND cave_id = ?", (data['bottleName'], data['bottleColor'], data['bottleCountry'], data['bottleRegion'], int(data['bottleYear']), data['bottleGrappes'], float(data['bottlePrice']), float(data['bottleRating']), data['bottleComment'], int(data['caveID'])))
    bottle_id = c.fetchone()[0]
    #save the image if there is one
    if data['bottleImage'] != 'no-image':
        # print('saving image')
        # convert from base64 to image and save it as bottle_id.jpg
        with open('images/bottles/' + str(bottle_id) + '.jpg', 'wb') as f:
            f.write(base64.b64decode(data['bottleImage']))
    conn.close()
    socketio.emit('bottleAdded', [data['caveID']])

@socketio.on('deleteBottle')
def deleteBottle(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #delete the bottle
    c.execute("DELETE FROM wine WHERE id = ?", (data['bottleID'],))
    conn.commit()
    conn.close()
    socketio.emit('bottleDeleted', "1")

@socketio.on('modifyBottle')
def modifyBottle(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #modify the bottle
    c.execute("UPDATE wine SET name = ?, color = ?, country = ?, region = ?, year = ?, grape = ?, price = ?, quantity = ?, rating = ?, description = ? WHERE id = ?", (data['bottleName'], data['bottleColor'], data['bottleCountry'], data['bottleRegion'], int(data['bottleYear']), data['bottleGrappes'], float(data['bottlePrice']), float(data['bottleQuantity']), float(data['bottleRating']), data['bottleComment'], data['bottleID']))
    conn.commit()
    #save the image if there is one
    if data['bottleImage'] != 'no-image':
        # print('saving image')
        # convert from base64 to image and save it as bottle_id.jpg
        with open('images/bottles/' + str(data['bottleID']) + '.jpg', 'wb') as f:
            f.write(base64.b64decode(data['bottleImage']))
    conn.close()
    socketio.emit('bottleModified', "1")

@socketio.on('signUp')
def signUp(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #check if the username is already taken
    c.execute("SELECT * FROM users WHERE username = ?", (data['username'],))
    if c.fetchone() != None:
        socketio.emit('signedUp', ["Username already taken",0])
    else:
        #add the user
        c.execute("INSERT INTO users (username, password) VALUES (?, ?)", (data['username'], data['password']))
        conn.commit()
        #get the user id
        c.execute("SELECT id FROM users WHERE username = ?", (data['username'],))
        user_id = c.fetchone()[0]
        conn.close()
        socketio.emit('signedUp', ["signedUp",user_id])

@socketio.on('logIn')
def logIn(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #check if the username exists
    c.execute("SELECT * FROM users WHERE username = ?", (data['username'],))
    if c.fetchone() == None:
        socketio.emit('loggedIn', ["Username doesn't exist",0])
    else:
        #check if the password is correct
        c.execute("SELECT * FROM users WHERE username = ? AND password = ?", (data['username'], data['password']))
        if c.fetchone() == None:
            socketio.emit('loggedIn', ["Wrong password",0])
        else:
            #get the user id
            c.execute("SELECT id FROM users WHERE username = ?", (data['username'],))
            user_id = c.fetchone()[0]
            
            conn.close()
            socketio.emit('loggedIn', ["loggedIn",user_id])

@socketio.on('getProfilePage')
def getProfilePage(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #get the user's caves
    c.execute("SELECT username,password FROM users WHERE id = ?", (int(data),))
    user = c.fetchone()
    conn.close()
    socketio.emit('profilePage', user)

@socketio.on('modifyUser')
def modifyProfile(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #modify the user's profile
    c.execute("UPDATE users SET username = ?, password = ? WHERE id = ?", (data['username'], data['password'], data['userID']))
    conn.commit()
    conn.close()

@socketio.on('getDataStats')
def getDataStats(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    # for each cave of the user get the 100 last data
    caves = []
    c.execute("SELECT cave_id FROM cave_users WHERE user_id = ?", (data,))
    for cave in c.fetchall():
        temp = []
        temp.append(cave[0])
        c.execute("SELECT name FROM caves WHERE id = ?", (cave[0],))
        temp.append(c.fetchone()[0])
        c.execute("SELECT temperature , humidity , light , time FROM cave_data WHERE cave_id = ? ORDER BY time DESC LIMIT 10", (cave[0],))
        temp.append(c.fetchall())
        c.execute("SELECT temperatureWarning , temperatureCritical , humidityWarning , humidityCritical , lightWarning , lightCritical FROM cave_value WHERE cave_id = ?", (cave[0],))
        temp.append(c.fetchone())
        caves.append(temp)
    conn.close()
    # print(caves)
    socketio.emit('dataStats', caves)

@socketio.on('updateCaveValue')
def updateCaveValue(data):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    if data['type'] == 'temperature':
        c.execute("UPDATE cave_value SET temperatureWarning = ?, temperatureCritical = ? WHERE cave_id = ?", (data['warning'], data['critical'], data['caveID']))
    elif data['type'] == 'humidity':
        c.execute("UPDATE cave_value SET humidityWarning = ?, humidityCritical = ? WHERE cave_id = ?", (data['warning'], data['critical'], data['caveID']))
    elif data['type'] == 'luminosity':
        c.execute("UPDATE cave_value SET lightWarning = ?, lightCritical = ? WHERE cave_id = ?", (data['warning'], data['critical'], data['caveID']))
    conn.commit()
    conn.close()
    socketio.emit('caveValueUpdated', "1")



if __name__ == '__main__':
    socketio.run(app,port=5021 ,host= '0.0.0.0', debug=True)