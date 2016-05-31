import sqlite3
import sys
import matplotlib.pyplot as plt
import numpy as np
import re

def normalize(v):
    return v/v[0]

def getEventFreq(data):
    events = dict()
    for d in data:
        if d[0] in events:
            events[d[0]] += 1
        else:
            events[d[0]] = 1
    return events

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

c.execute('SELECT event_name, MAX(event_number), ab_value FROM all_data GROUP BY user_id')
a = c.fetchall()

bData = [t for t in a if t[2] == 0]
aData = [t for t in a if t[2] == 1]

aDict = getEventFreq(aData)
bDict = getEventFreq(bData)

aHistogram = np.zeros(len(aDict))
bHistogram = np.zeros(len(aDict))

for i, k in enumerate(aDict.keys()):
    aHistogram[i] = aDict[k]
    bHistogram[i] = bDict[k]

# create plot
fig, ax = plt.subplots()
index = np.arange(len(aDict))
bar_width = 0.35
opacity = 0.8

rects1 = plt.bar(index, aHistogram, bar_width,
                 alpha=opacity,
                 color='r',
                 label='Old tutorial')

rects2 = plt.bar(index + bar_width, bHistogram, bar_width,
                 alpha=opacity,
                 color='b',
                 label='Improved tutorial')

plt.xlabel('events')
plt.title('Last Event Before Exit')
plt.xticks(index + bar_width, aDict.keys())
plt.legend()

plt.tight_layout()
plt.show()
