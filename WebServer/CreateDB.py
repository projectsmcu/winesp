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

# The table wine will contain the wine name, color, country, region, year, grape, price, rating, description, id and the cave id

c.execute('''CREATE TABLE wine
                (id INTEGER PRIMARY KEY, quantity INTEGER , name TEXT, color TEXT, country TEXT, region TEXT, year INTEGER, grape TEXT, price REAL, rating REAL, description TEXT, cave_id INTEGER)''')

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

conn.commit()

#fill data table with random data for 300 entries but all different with 10 seconds between each entry



for i in range(300):
    c.execute("INSERT INTO cave_data VALUES (1, ?, ?, ?, ?)", (random.uniform(0, 30), random.uniform(0, 100), random.uniform(0, 100), time.strftime('%Y-%m-%d %H:%M:%S').format(i*2)))
    c.execute("INSERT INTO cave_data VALUES (2, ?, ?, ?, ?)", (random.uniform(0, 30), random.uniform(0, 100), random.uniform(0, 100), time.strftime('%Y-%m-%d %H:%M:%S').format(i*5)))
    c.execute("INSERT INTO cave_data VALUES (3, ?, ?, ?, ?)", (random.uniform(0, 30), random.uniform(0, 100), random.uniform(0, 100), time.strftime('%Y-%m-%d %H:%M:%S').format(i*10)))


conn.commit()

#fill wine table with random data for 100 entries
wine_color = ["red", "white", "rose"]

for i in range(100):
    c.execute("INSERT INTO wine VALUES (?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", (i, "Wine"+str(i),random.randint(1,10), wine_color[random.randint(0,2)] , "France", "Bordeaux", 2015, "Merlot", random.uniform(0, 100), random.uniform(0, 5), "This is a description of the wine", 1))
    c.execute("INSERT INTO wine VALUES (?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", (i+100, "Wine"+str(i+100),random.randint(1,10), wine_color[random.randint(0,2)], "France", "Bordeaux", 2015, "Merlot", random.uniform(0, 100), random.uniform(0, 5), "This is a description of the wine", 2))
    c.execute("INSERT INTO wine VALUES (?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", (i+200, "Wine"+str(i+200),random.randint(1,10), wine_color[random.randint(0,2)], "France", "Bordeaux", 2015, "Merlot", random.uniform(0, 100), random.uniform(0, 5), "This is a description of the wine", 3))

conn.commit()

conn.close()




