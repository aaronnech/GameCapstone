package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class MenuState extends FlxState
{
	private var level:Level;

	override public function create():Void
	{
		super.create();
		this.level = new Level('assets/levels/level.1.json');
		this.level.load(function() {
			trace(this.level.getGrid());
			trace(this.level.getObjects());
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
