package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class PlayState extends FlxState {
	private var level:Level;
	private var mainSimulator:Simulator;

	public function new(level:Level) {
		super();
		this.level = level;
	}

	override public function create():Void {
		super.create();
		FlxG.mouse.visible = false;

		this.mainSimulator = new Simulator(28, 15, this.level);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
