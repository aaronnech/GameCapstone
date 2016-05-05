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
		this.score = score;

		var save = new FlxSave();
		save.bind("Game");
		if (!save.data.highestLevel) {
			save.data.highestLevel = 0;
		}

		save.data.highestLevel = Math.max(nextIndex, save.data.highestLevel);
		save.flush();
	}

	override public function create():Void {
		super.create();
		FlxG.mouse.visible = true;

		var backdrop = new FlxBackdrop('assets/images/playbg.png');
		add(backdrop);

		if (this.nextIndex < this.levels.length) {
			var next = new FlxButton(0, 0, "", clickNext);
			next.loadGraphic('assets/images/next.png');
			next.screenCenter();
			next.x += 100;
			add(next);
		}

		var redo = new FlxButton(0, 0, "", clickRedo);
		redo.loadGraphic('assets/images/retry.png');
		redo.screenCenter();
		add(redo);

		var back = new FlxButton(0, 0, "", clickBack);
		back.loadGraphic('assets/images/back.png');
		back.screenCenter();
		back.x -= 100;
		add(back);

		var scoreText = new FlxText(0, 0);
		scoreText.size = 20;
		scoreText.text = "Score: " + this.score;
		scoreText.screenCenter();
		scoreText.y = scoreText.y - 70;
		add(scoreText);
	}

	private function clickNext():Void {
		FlxG.switchState(new PlayState(this.levels, this.nextIndex));
	}

	private function clickBack():Void {
		FlxG.switchState(new LevelSelectState());
	}

	private function clickRedo():Void {
		FlxG.switchState(new PlayState(this.levels, this.nextIndex - 1));
	}
}