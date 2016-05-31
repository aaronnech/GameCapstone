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
    starts = [t for t in a if t[3] == "level-start"]
    completes = [t for t in a if t[3] == "level-complete"]

    for s in starts:
        sLevel = int(re.findall(r'\d+', s[2])[0])
        for c in completes:
            if s[1] == c[1] and s[5] < c[5] and sLevel == int(re.findall(r'\d+', c[2])[0]):
                playsPerLevel[sLevel] += 1
                totalTimePerLevel[sLevel] += c[0] - s[0]
                break

    return totalTimePerLevel / playsPerLevel

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

c.execute('SELECT time_stamp, user_id, screen_name, event_name, ab_value, event_number FROM all_data WHERE event_name="level-start" OR event_name="level-complete"')
a = c.fetchall()

bData = [t for t in a if t[4] == 0]
aData = [t for t in a if t[4] == 1]

aHistogram = getTimes(aData)
bHistogram = getTimes(bData)

plt.title("Average Time Per Level")
plt.xlabel("levels")
plt.ylabel("seconds")
plt.xticks(range(24))
plt.yticks(range(0, 650, 50))
plt.plot(aHistogram, '-r', label="Old tutorial")
plt.plot(bHistogram, '-b', label="Improved tutorial")
plt.legend(loc=2)
plt.show()
