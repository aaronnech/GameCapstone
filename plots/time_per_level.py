import sqlite3
import sys
import matplotlib.pyplot as plt
import numpy as np
import re

def normalize(v):
    return v/v[0]

def getTimes(db):
    playsPerLevel = np.zeros(24)
    totalTimePerLevel = np.zeros(24)
    starts = [t for t in db if t[3] == "level-start"]
    completes = [t for t in db if t[3] == "level-complete"]
    idAndLevelToTimeAndEventNum = dict()

    for s in starts:
        level = int(re.findall(r'\d+', s[2])[0])
        idAndLevelToTimeAndEventNum[(s[1], level)] = (s[0], s[5])

    for c in completes:
        level = int(re.findall(r'\d+', c[2])[0])
        if (c[1], level) in idAndLevelToTimeAndEventNum:
            startTime, eventNum = idAndLevelToTimeAndEventNum[(c[1], level)]
            playTime = c[0] - startTime
            if playTime > 0 and playTime < 2000 and eventNum < c[5]:
                idAndLevelToTimeAndEventNum[(c[1], level)] = (playTime, eventNum)
                playsPerLevel[level] += 1
                totalTimePerLevel[level] += playTime

    return totalTimePerLevel / playsPerLevel

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

c.execute('SELECT time_stamp, user_id, screen_name, event_name, game_version, event_number \
    FROM all_data WHERE event_name="level-start" OR event_name="level-complete"')
a = c.fetchall()

v1 = [t for t in a if t[4] == '1.0']
v25 = [t for t in a if t[4] == '2.5']

v1Graph = getTimes(v1)
v25Graph = getTimes(v25)

# plt.title("Average Play Time Per Level", fontsize=25)
plt.xlabel("Levels", fontsize=25)
plt.ylabel("Seconds", fontsize=25)
plt.xticks(range(24), fontsize=18)
plt.plot(v1Graph, '-b', label="Version 1.0", linewidth=4.0)
plt.plot(v25Graph, '-r', label="Version 2.5", linewidth=4.0)
plt.legend(loc=2)

plt.show()
