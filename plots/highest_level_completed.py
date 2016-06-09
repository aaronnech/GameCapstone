import sqlite3
import sys
import matplotlib.pyplot as plt
import numpy as np
import re
import math
from util import *

conn = sqlite3.connect(sys.argv[1])
c = conn.cursor()

c.execute('SELECT game_version, screen_name, user_id, event_name, event_number FROM all_data')
a = c.fetchall()

version_1 = [t for t in a if t[0] == '1.0']
version_25 = [t for t in a if t[0] == '2.5']

lastEventPerUser = lastEventByUser(version_1)
highestPerUser, maxLevel = highestLevelsByUser(version_1)
keepOnlyValue(highestPerUser, lastEventPerUser, ['level-reset'])
dist_1 = distributionOfHighestLevels(highestPerUser, maxLevel)

lastEventPerUser = lastEventByUser(version_25)
highestPerUser, maxLevel = highestLevelsByUser(version_25)
keepOnlyValue(highestPerUser, lastEventPerUser, ['level-reset'])
dist_25 = distributionOfHighestLevels(highestPerUser, maxLevel)

# Plot comparison
lvls = range(1, 25)
bar_width = 0.35
plt.xlabel('Highest Level Completed', fontsize=25)
plt.ylabel('Percent of total users in cohort', fontsize=25)
plt.bar(lvls, dist_1, alpha=0.5, color='b', label='Version 1')
plt.bar(lvls, dist_25, alpha=0.5, color='r', label='Version 2.5')
plt.xticks(lvls, fontsize=18)

plt.legend(loc=2)
plt.show()
