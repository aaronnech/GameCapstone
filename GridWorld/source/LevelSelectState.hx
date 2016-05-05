package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class LevelSelectState extends FlxState
{
	private var levels:List<Level>;

	private function loadLevels():List<Level> {
		var allAssets = openfl.Assets.list();
		var mp = new Map<Int, Level>();
		var numberLevels = 0;
		for (asset in allAssets) {
			if (asset.indexOf('levels') > -1) {
				var l = new Level(asset);
				l.load();
				var n = Std.parseInt(asset.split('.')[1]);
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

	override public function create():Void {
		super.create();
		this.levels = loadLevels();

		var y = 0;
		var i = 0;
		for (level in levels) {
			var btn = new FlxButton(0, 0, "Play " + i, startLevel.bind(level));
			btn.screenCenter();
			btn.y = y;
			add(btn);
			i = i + 1;
			y = y + 50;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
