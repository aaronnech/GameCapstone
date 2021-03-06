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
	private var yaySound:FlxSound;

	public function new(levels:Array<Level>, nextIndex:Int, score:Int) {
		super();
		AnalyticsAPI.complete(nextIndex - 1, score);

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

		var scoreManager = new ScoreManager(levels);
		scoreManager.setLevelScore(nextIndex - 1, score);

		AnalyticsAPI.sendMaxScoreToKong(scoreManager.getTotalScore());
		AnalyticsAPI.sendHighestLevelToKong(nextIndex);
	}

	override public function create():Void {
		super.create();
		this.yaySound = FlxG.sound.load("assets/sounds/yay.wav");
		this.yaySound.volume = 0.5;
		this.yaySound.play();

		FlxG.mouse.visible = true;

		var backdrop = new FlxBackdrop('assets/images/playbg.png');
		add(backdrop);

		if (this.nextIndex < this.levels.length) {
			var next = new FlxButton(0, 0, "", clickNext);
			next.loadGraphic('assets/images/next.png');
			next.screenCenter();
			next.x += 100;
			add(next);
		} else {
			var winText = new FlxText(0, 0);
			winText.size = 20;
			winText.text = "Congratulations, you are a GridWorld master!";
			winText.screenCenter();
			winText.y -= 150;
			add(winText);
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
		if (this.nextIndex < this.levels.length) {
			AnalyticsAPI.click("navigation", "nextLevel");
			FlxG.switchState(new PlayState(this.levels, this.nextIndex));
		}
	}

	private function clickBack():Void {
		AnalyticsAPI.click("navigation", "backToMenu");
		FlxG.switchState(new LevelSelectState());
	}

	private function clickRedo():Void {
		AnalyticsAPI.click("navigation", "redoLevel");
		FlxG.switchState(new PlayState(this.levels, this.nextIndex - 1));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([D, P, ENTER, RIGHT])) {
			this.clickNext();
		} else if (FlxG.keys.anyJustPressed([W, R, UP])) {
			this.clickRedo();
		} else if (FlxG.keys.anyJustPressed([A, LEFT, BACKSPACE])) {
			this.clickBack();
		}
	}
}
