package;

class OptimalLevelCount {
	private static var OPTIMAL_COUNTS:Map<Int, Int> = [
		1 => 1,
		2 => 1,
		3 => 2,
		4 => 2,
		5 => 4,
		6 => 4,
		7 => 4,
		8 => 3,
		9 => 2,
		10 => 1,
		11 => 1,
		12 => 4,
		13 => 4,
		14 => 4,
		15 => 4,
		16 => 2,
		17 => 3,
		18 => 3,
		19 => 7,
		20 => 7
	];

	public static function getCountForLevel(levelNumber:Int):Int {
		if (OptimalLevelCount.OPTIMAL_COUNTS.exists(levelNumber)) {
			return OptimalLevelCount.OPTIMAL_COUNTS.get(levelNumber);
		}

		return -1;
	}
}
