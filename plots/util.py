import numpy as np

def lastEventByUser(rows):
	eventNum = {}
	result = {}
	for s in rows:
		evt_name = s[3]
		evt_number = s[4]
		uid = s[2]

		if uid not in result:
			eventNum[uid] = evt_number
			result[uid] = evt_name
		elif evt_number > eventNum[uid]:
			eventNum[uid] = evt_number
			result[uid] = evt_name

	return result

def filterValue(filtered, userDict, value):
	for uid in filtered.keys():
		if userDict[uid] == value:
			del filtered[uid]

def keepOnlyValue(filtered, userDict, value):
	for uid in filtered.keys():
		if userDict[uid] != value:
			del filtered[uid]

def highestLevelsByUser(rows):
	result = {}
	maxLevel = 0
	for s in rows:
		if 'Complete' in s[1]: continue
		if 'Select' in s[1]: continue
		if 'level' not in s[1]: continue

		uid = s[2]
		sLevel = int(s[1].replace('level', ''))
		if sLevel > 23: sLevel = 23

		if uid not in result:
			result[uid] = sLevel
		else:
			result[uid] = max(sLevel, result[uid])
		maxLevel = max(sLevel, maxLevel)

	return result, maxLevel

def distributionOfHighestLevels(maxLevelByUser, maxLevel):
	dist = np.array([0.0 for i in range(maxLevel + 1)])
	for uid in maxLevelByUser.keys():
		dist[maxLevelByUser[uid]] += 1.0

	return dist / len(maxLevelByUser.keys())