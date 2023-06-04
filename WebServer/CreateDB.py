#Create a database and table in SQLite3 made for the webserver
#To simulate the future users

import os
import sqlite3
import random
import time


#if the file data.db exist delete it

try:
    os.remove("data.db")
except OSError:
    pass

conn = sqlite3.connect('data.db')
c = conn.cursor()

# The table users will contain the username and password of the users with their unique id as the primary key

c.execute('''CREATE TABLE users
                (id INTEGER PRIMARY KEY, username TEXT, password TEXT)''')

conn.commit()

# The Cave table will contain the cave name and the cave id as the primary key

c.execute('''CREATE TABLE caves
                (id INTEGER PRIMARY KEY, name TEXT, Location TEXT)''')

conn.commit()

# The table cave_users will contain the cave id and the user id as the primary key

c.execute('''CREATE TABLE cave_users
                (cave_id INTEGER, user_id INTEGER, PRIMARY KEY (cave_id, user_id))''')

conn.commit()

# The table cave_data will contain the cave id, the temperature, the humidity, the light and the time of the data

c.execute('''CREATE TABLE cave_data
                (cave_id INTEGER, temperature REAL, humidity REAL, light REAL, time TEXT)''')

conn.commit()

c.execute('''CREATE TABLE cave_value
                (cave_id INTEGER PRIMARY KEY, temperatureWarning REAL, temperatureCritical REAL, humidityWarning REAL, humidityCritical REAL, lightWarning REAL, lightCritical REAL)''')

conn.commit()

# The table wine will contain the wine name, color, country, region, year, grape, price, rating, description, id and the cave id

c.execute('''CREATE TABLE wine
                (name TEXT,id INTEGER PRIMARY KEY , color TEXT, region TEXT, country TEXT, year INTEGER, rating REAL, price REAL, grape TEXT, quantity INTEGER, description TEXT, cave_id INTEGER)''')

# fill different tables with data

c.execute("INSERT INTO caves VALUES (1, 'Cave1', 'Location1')")
c.execute("INSERT INTO caves VALUES (2, 'Cave2', 'Location2')")
c.execute("INSERT INTO caves VALUES (3, 'Cave3', 'Location3')")

c.execute("INSERT INTO users VALUES (1, 'user1', 'pass1')")
c.execute("INSERT INTO users VALUES (2, 'user2', 'pass2')")

c.execute("INSERT INTO cave_users VALUES (1, 1)")
c.execute("INSERT INTO cave_users VALUES (2, 1)")
c.execute("INSERT INTO cave_users VALUES (3, 1)")
c.execute("INSERT INTO cave_users VALUES (1, 2)")

c.execute("INSERT INTO cave_value VALUES (1, 18, 25, 50, 70, 50, 70)")
c.execute("INSERT INTO cave_value VALUES (2, 17, 26, 51, 71, 51, 71)")
c.execute("INSERT INTO cave_value VALUES (3, 16, 27, 52, 72, 52, 72)")

conn.commit()

#fill data table with random data for 300 entries but all different with 10 seconds between each entry


initial_time = time.strftime('%Y-%m-%d %H:%M:%S')
print(initial_time)

for i in range(300):
    c.execute("INSERT INTO cave_data VALUES (1, ?, ?, ?, ?)", (random.uniform(0, 30), random.uniform(0, 100), random.uniform(0, 100), time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.mktime(time.strptime(initial_time, '%Y-%m-%d %H:%M:%S')) + 300*i))))
    c.execute("INSERT INTO cave_data VALUES (2, ?, ?, ?, ?)", (random.uniform(0, 30), random.uniform(0, 100), random.uniform(0, 100), time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.mktime(time.strptime(initial_time, '%Y-%m-%d %H:%M:%S')) + 300*i))))
    c.execute("INSERT INTO cave_data VALUES (3, ?, ?, ?, ?)", (random.uniform(0, 30), random.uniform(0, 100), random.uniform(0, 100), time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.mktime(time.strptime(initial_time, '%Y-%m-%d %H:%M:%S')) + 300*i))))


conn.commit()

#fill wine table with random data for 100 entries
wine_color = ["red", "white", "rose"]

for i in range(100):
    c.execute("INSERT INTO wine (name , color , country , region , year , grape , price ,quantity , rating , description , cave_id ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ("Wine"+str(i), wine_color[random.randint(0,2)] , "France", "Bordeaux", 2015, "Merlot", random.uniform(0, 100), random.randint(1,10),random.uniform(0, 5), "This is a description of the wine", 1))
    c.execute("INSERT INTO wine (name , color , country , region , year , grape , price ,quantity , rating , description , cave_id ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ("Wine"+str(i+100), wine_color[random.randint(0,2)], "France", "Bordeaux", 2015, "Merlot", random.uniform(0, 100), random.randint(1,10),random.uniform(0, 5), "This is a description of the wine", 2))
    c.execute("INSERT INTO wine (name , color , country , region , year , grape , price ,quantity , rating , description , cave_id ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ("Wine"+str(i+200) , wine_color[random.randint(0,2)], "France", "Bordeaux", 2015, "Merlot", random.uniform(0, 100), random.randint(1,10),random.uniform(0, 5), "This is a description of the wine", 3))

conn.commit()

conn.close()




