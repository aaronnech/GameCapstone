package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxSound;
import flixel.util.FlxSave;

class LevelCompleteState extends FlxState {
	private var levels:Array<Level>;
	private var nextIndex:Int;
	private var score:Int;

	public function new(levels:Array<Level>, nextIndex:Int, score:Int) {
		super();
		this.levels = levels;
		this.nextIndex = nextIndex;

		var save = new FlxSave();
		save.bind("Game");
		if (!save.data.highestLevel) {
			save.data.highestLevel = 0;
		}

		save.data.highestLevel = Math.max(nextIndex, save.data.highestLevel);
	}

	override public function create():Void {
		super.create();
		FlxG.mouse.visible = true;

		var backdrop = new FlxBackdrop('assets/images/playbg.png');
		add(backdrop);

		if (this.nextIndex < this.levels.length) {
			var next = new FlxButton(0, 0, "Next Level", clickNext);
			next.screenCenter();
			next.x += 50;
			add(next);
		}

		var redo = new FlxButton(0, 0, "Redo", clickRedo);
		redo.screenCenter();
		redo.x -= 50;
		add(redo);


		var scoreText = new FlxText(0, 0);
		scoreText.text = "Score: " + this.score;
		scoreText.screenCenter();
		scoreText.y = scoreText.y - 70;
		add(scoreText);
	}

	private function clickNext():Void {
		FlxG.switchState(new PlayState(this.levels, this.nextIndex));
	}

	private function clickRedo():Void {
		FlxG.switchState(new PlayState(this.levels, this.nextIndex - 1));
	}
}