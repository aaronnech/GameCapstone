import sys
import csv
import re
import numpy as np
import matplotlib.pyplot as plt

aDist = [[] for i in range(24)]
with open(sys.argv[1], 'rb') as csvfile:
	cv = csv.reader(csvfile)
	for s in cv:
		if s[0] == 'screen_name': continue
		if 'Complete' in s[0]: continue
		if 'Select' in s[0]: continue
		if 'level' not in s[0]: continue

		sLevel = int(re.findall(r'\d+', s[0])[0])
		n = int(s[1])
		if n != 0:
			aDist[sLevel].append(n)
bDist = [[] for i in range(24)]
with open(sys.argv[2], 'rb') as csvfile:
	cv = csv.reader(csvfile)
	for s in cv:
		if s[0] == 'screen_name': continue
		if 'Complete' in s[0]: continue
		if 'Select' in s[0]: continue
		if 'level' not in s[0]: continue

		sLevel = int(re.findall(r'\d+', s[0])[0])
		n = int(s[1])
		if n != 0:
			bDist[sLevel].append(n)

meds1 = [np.median(a) for a in aDist]
meds2 = [np.median(a) for a in bDist]

plt.plot(meds1)
plt.plot(meds2)

plt.show()