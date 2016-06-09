import sqlite3
import sys
import matplotlib.pyplot as plt
import numpy as np
import re

def getScores(rows):
    scores = np.zeros(24)
    entries = np.zeros(24)

    for r in rows:
        level = int(re.findall(r'\d+', r[1])[0])
        if r[2] <= 100:
            scores[level] += r[2]
            entries[level] += 1

    return scores / entries

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

c.execute('SELECT game_version, screen_name, event_value FROM all_data WHERE event_name="level-complete"')
a = c.fetchall()

v1 = [t for t in a if t[0] == '1.0']
v25 = [t for t in a if t[0] == '2.5']

v1Graph = getScores(v1)
v25Graph = getScores(v25)

lvls = range(1,25)
plt.xlabel("Levels", fontsize=25)
plt.ylabel("Average Scores", fontsize=25)
plt.bar(lvls, v1Graph, alpha=0.5, color='b', label="Version 1.0")
plt.bar(lvls, v25Graph, alpha=0.5, color='r', label="Version 2.5")
plt.yticks(range(0,120,10), fontsize=18)
plt.xticks(lvls, fontsize=18)
plt.legend(loc=2)

plt.show()
