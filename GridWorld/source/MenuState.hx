package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;

class MenuState extends FlxState {
	private var play:FlxButton;
	private var instructionText:FlxText;

	override public function create():Void {
		super.create();
		FlxG.mouse.visible = true;

		play = new FlxButton(0, 0, "Play", clickPlay);
		play.screenCenter();
		add(play);

		instructionText = new FlxText(0, 0);
		instructionText.text = "GRIDWORLD";
		instructionText.screenCenter();
		instructionText.y = instructionText.y - 70;
		add(instructionText);
	}

	private function clickPlay():Void {
		FlxG.switchState(new LevelSelectState());
	}
}