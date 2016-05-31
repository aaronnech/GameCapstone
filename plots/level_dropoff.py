import sqlite3
import sys
import matplotlib.pyplot as plt
import numpy as np
import re

def normalize(v):
    norm=np.linalg.norm(v)
    if norm==0:
       return v
    return v/norm

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

c.execute('SELECT * FROM all_data WHERE event_name="level-start" GROUP BY user_id, screen_name')
a = c.fetchall()

aNotEnabled = [t for t in a if t[10] == 0]
aEnabled = [t for t in a if t[10] == 1]

aHistogram = np.zeros(24)
for t in aEnabled:
	num = int(re.findall(r'\d+', t[4])[0])
	aHistogram[num] += 1
aHistogram = normalize(aHistogram)

notAHistogram = np.zeros(24)
for t in aNotEnabled:
	num = int(re.findall(r'\d+', t[4])[0])
	notAHistogram[num] += 1
notAHistogram = normalize(notAHistogram)

plt.xlabel("levels")
plt.xticks(range(24))
plt.plot(aHistogram, '-r', label="Improved tutorial")
plt.plot(notAHistogram, '-b', label="Old tutorial")
plt.legend()
plt.show()
