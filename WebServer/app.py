from flask import Flask, render_template
from flask_socketio import SocketIO
import sqlite3


app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

@socketio.on('connect')
def connect():
    print("a client connected")

@socketio.on('disconnect')
def disconnect():
    print('Client disconnected')

@socketio.on('getCaves')
def getCave(user):
    conn = sqlite3.connect('data.db')
    c = conn.cursor()
    #get the user's caves and for each cave get the cave's name , id ,  last reccorded data , total number of bottles in the user's caves by color
    c.execute("SELECT cave_id, name FROM caves JOIN cave_users ON caves.id = cave_users.cave_id WHERE user_id = ?", (user,))
    caves = c.fetchall()
    id_caves = [cave[0] for cave in caves]
    #get the cave's
    stats,bottlesnumber,random_bottles = [],[],[]
    for cave in id_caves:
        c.execute("SELECT * FROM cave_data WHERE cave_id = ? ORDER BY time DESC LIMIT 1", (cave,))
        stats.append(c.fetchone())
        c.execute("SELECT color, COUNT(id) FROM wine WHERE cave_id IN (SELECT cave_id FROM cave_users WHERE user_id = ?) GROUP BY color", (user,))
        bottlesnumber.append(c.fetchall())
        c.execute("SELECT * FROM wine WHERE cave_id IN (SELECT cave_id FROM cave_users WHERE user_id = ?) ORDER BY RANDOM() LIMIT 10", (user,))
        random_bottles.append(c.fetchall())
    socketio.emit('cave', [caves, stats, bottlesnumber, random_bottles])
    


@app.route('/')
def hello():
    return "Hello World!"


if __name__ == '__main__':
    socketio.run(app,port=5021 ,host= '0.0.0.0')