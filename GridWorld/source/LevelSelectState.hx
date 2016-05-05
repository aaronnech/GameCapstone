package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;

class LevelSelectState extends FlxState
{
	private static var GRID_X:Int = 20;
	private static var GRID_Y:Int = 20;
	private static var GRID_WIDTH:Int = 5;
	private static var GRID_HEIGHT:Int = 5;
	private static var GRID_GAP:Int = 100;
	private var currentPage:Int;
	private var levels:List<Level>;
	private var levelGrid:FlxTypedGroup<FlxButton>;

	private function loadLevels():List<Level> {
		var allAssets = openfl.Assets.list();
		var mp = new Map<Int, Level>();
		var numberLevels = 0;
		for (asset in allAssets) {
			if (asset.indexOf('levels') > -1) {
				var l = new Level(asset);
				l.load();
				var n = l.number;
				mp.set(n, l);
				numberLevels += 1;
			}
		}

		var result = new List<Level>();
		for (i in 0...numberLevels) {
			result.add(mp[i + 1]);
		}

		return result;
	}

	private function startLevel(level:Level):Void {
		FlxG.switchState(new PlayState(level));
	}

	private function getPage():List<Level> {
		var result = new List<Level>();
		var i = 0;
		var numInPage = LevelSelectState.GRID_HEIGHT * LevelSelectState.GRID_WIDTH;
		var minimum = this.currentPage * numInPage;
		var maximum = minimum + numInPage;
		for (level in this.levels) {
			if (i >= minimum && i < maximum) {
				result.add(level);
			}
			i += 1;
		}

		return result;
	}

	private function updatePage():Void {
		this.levelGrid.clear();
		var currentLevels = this.getPage();
		var row = 0;
		var col = 0;

		for (level in currentLevels) {
			var btn = new FlxButton(0, 0, "" + level.number, startLevel.bind(level));
			btn.scale.set(1, 4.5);
			btn.label.size = 18;
			btn.x = col * LevelSelectState.GRID_GAP + LevelSelectState.GRID_X;
			btn.y = row * LevelSelectState.GRID_GAP + LevelSelectState.GRID_Y;
			this.levelGrid.add(btn);

			// Update grid coordinates
			col += 1;
			if (col >= LevelSelectState.GRID_WIDTH) {
				col = 0;
				row += 1;
				if (row >= LevelSelectState.GRID_HEIGHT) {
					break;
				}
			}
		}
	}

	private function updateNextPrevious():Void {
		var currentLevels = this.getPage();
	}

	override public function create():Void {
		super.create();
		this.levels = loadLevels();
		this.currentPage = 0;
		this.levelGrid = new FlxTypedGroup<FlxButton>();
		this.updatePage();
		this.updateNextPrevious();
		add(this.levelGrid);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
