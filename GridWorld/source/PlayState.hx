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
import flixel.util.FlxTimer;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import haxe.ds.HashMap;

class PlayState extends FlxState {
	public static var TICK_TIME:Float = 0.5;
	private var levels:Array<Level>;
	private var level:Level;
	private var mainSimulator:Simulator;
    private var spriteManager:ObjectManager;
    private var controlManager:ControlManager;
	private var tileMap:FlxTilemap;
	private var totalElapsed:Float;
	private var controls:HashMap<Color, Array<Control>>;
	private var isPlaying:Bool;
	private var playButton:FlxButton;
	private var helpText:FlxText;
	private var levelIndex:Int;
	private var tickSound:FlxSound;
	private var crashSound:FlxSound;
	private var helpSprite:FlxSprite;

	public function new(levels:Array<Level>, cur:Int) {
		super();
		AnalyticsAPI.startLevel(cur);
		this.levelIndex = cur;
		this.level = levels[cur];
		this.levels = levels;
	}

	override public function create():Void {
		super.create();
		var backdrop = new FlxBackdrop('assets/images/playbg.png');
		add(backdrop);

		this.tickSound = FlxG.sound.load("assets/sounds/carmove.wav");
		this.crashSound = FlxG.sound.load("assets/sounds/carcrash.wav");

		this.isPlaying = false;

		// Background tile map
		this.tileMap = new FlxTilemap();
		this.tileMap.loadMapFrom2DArray(
			this.level.getGrid(),
			"assets/images/backgroundtiles.png",
			this.level.getTileSize(),
			this.level.getTileSize(),
			FlxTilemapAutoTiling.OFF, 0, 0
		);
		this.tileMap.x = 80;
		this.tileMap.y = 50;
		this.add(this.tileMap);

		this.mainSimulator = new Simulator(this.level.getWidth(), this.level.getHeight(), this.level);

		// Create control panel
		this.controlManager = new ControlManager(70, 6, this.level.getColors(),
												 this.level.getBannedControls(),
												 this.mainSimulator, this);
		this.controls = this.controlManager.getControls();

		this.mainSimulator.onSetControls(this.controls);

		// Objects
		this.spriteManager = new ObjectManager(this.mainSimulator, this.level.getTileSize());
		this.spriteManager.xOffset = 80;
		this.spriteManager.yOffset = 50;
		this.spriteManager.generate();
		var sprites = this.spriteManager.getSprites();
		for (sprite in sprites) {
			this.add(sprite);
		}

		if (level.number == 1) {
			if (AnalyticsAPI.isA()) {
				this.tutorialA();
			} else {
				this.tutorialB();
			}
		}

		// UI
		add(new FlxText(210, 10, 300, "Level " + (this.levelIndex + 1), 14));
		this.createUI();
		this.totalElapsed = 0;
	}

	private function createUI():Void {
        this.playButton = new FlxButton(10, FlxG.height - 70, "", this.onClickPlay);
		this.playButton.loadGraphic("assets/images/stop.png");
        this.playButton.loadGraphic("assets/images/play.png");

        var backButton = new FlxButton(100, 10, "Menu", this.onClickBack);
        var helpButton = new FlxButton(10, 10, "Shortcuts", this.onClickHelp);
        this.helpSprite = new FlxSprite(50, 50, "assets/images/help.png");
        helpSprite.visible = false;

        add(backButton);
        add(helpButton);
        add(helpSprite);
        add(this.playButton);
	}

	private function onClickBack() {
		FlxG.switchState(new LevelSelectState());
		this.isPlaying = false;
		this.controlManager.enableControls();
		AnalyticsAPI.click('navigation', 'backToLevelSelect');
	}

	private function onClickPlay():Void {
		if (!this.controlManager.hasControls()) {
			AnalyticsAPI.click('controls', 'play', 0);
			return;
		}

		AnalyticsAPI.click('controls', 'play', 1);

		this.isPlaying = !this.isPlaying;
		if (!this.isPlaying) {
			AnalyticsAPI.reset();
		}
		this.mainSimulator.reset();
		this.spriteManager.snap();
	}

	private function onClickHelp():Void {
		this.helpSprite.visible = !this.helpSprite.visible;
		AnalyticsAPI.click('help', 'shortcuts');
	}

	private function updatePlayControls():Void {
		if (this.controlManager.hasControls()) {
			this.playButton.alpha = 1.0;
		} else {
			this.playButton.alpha = 0.5;
		}

		if (this.isPlaying) {
			this.playButton.loadGraphic("assets/images/stop.png");
			this.controlManager.disableControls();
		} else {
			this.controlManager.enableControls();
			this.controlManager.resetControlHighlights();
			this.playButton.loadGraphic("assets/images/play.png");
		}
	}

	private function onClickControl(ctl:Control):Void {
		for (color in this.level.getColors()) {
			this.controls.get(color).push(ctl);
			trace(this.controls.get(color));
		}
		this.spriteManager.snap();
	}

	private function endLevel():Void {
		this.isPlaying = false;
		this.controlManager.enableControls();
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function() {
			FlxG.switchState(new LevelCompleteState(this.levels, this.level.number, this.mainSimulator.getScore()));
		});
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		this.totalElapsed = this.totalElapsed + elapsed;
		if (this.isPlaying && this.totalElapsed > PlayState.TICK_TIME) {
			// Advance highlighted control indices in the ControlManager
			this.controlManager.updateControlHighlights();
			this.tickSound.play();
			if (this.mainSimulator.tick()) {
				this.spriteManager.update();
				if (this.mainSimulator.didUserWin()) {
					haxe.Timer.delay(this.endLevel, Std.int(PlayState.TICK_TIME * 1000));
					this.isPlaying = false;
					return;
				}
			} else {
				if (this.mainSimulator.didUserWin()) {
					haxe.Timer.delay(this.endLevel, Std.int(PlayState.TICK_TIME * 1000));
					this.isPlaying = false;
					return;
				}

				AnalyticsAPI.crash();

				this.crashSound.play();

				this.mainSimulator.reset();
				this.spriteManager.snap();
				this.isPlaying = false;
				FlxG.camera.flash(FlxColor.WHITE, 0.1);
			}

			this.totalElapsed = 0;
		} else if (!this.isPlaying) {
			this.totalElapsed = 0;
		}

		if (FlxG.keys.anyJustPressed([P, ENTER])) {
			this.onClickPlay();
		}
		this.controlManager.keyboardControls();
		this.updatePlayControls();

		if (this.helpSprite.visible && FlxG.mouse.justPressed) {
			this.helpSprite.visible = false;
		}
	}

	private function tutorialA() {
		var actors = [
			new FlxSprite(170, FlxG.height - 70, "assets/images/forward.png"),
			new FlxSprite(170, FlxG.height - 70, "assets/images/forward.png"),
			new FlxSprite(170, FlxG.height - 70, "assets/images/forward.png")
		];
		var cursor = new FlxSprite(185, FlxG.height - 50, "assets/images/dragcursor.png");
		var instructions = new FlxText(250, FlxG.height - 45, 300, "", 12);
		instructions.text = "drag and drop sequences into the track";
		var goal = new FlxText(105, 150, 300, 12);
		goal.text = "push the matching gem into the goal";
		var tileSize = this.controlManager.tileSize;
		var timer = new FlxTimer();
		var i = 0;
		var time = 0.7;

		function animateButton(timer:FlxTimer) {
			if (i == actors.length * 2) {
				for (actor in actors) {
					actor.destroy();
				}
				cursor.destroy();
				return;
			} else if (i < actors.length * 2 - 1) {
				if (i % 2 == 0) {
					var j = Std.int(i / 2);
					add(actors[j]);
					FlxTween.tween(actors[j], {x: FlxG.width - tileSize, y: j * tileSize}, time);
					FlxTween.tween(cursor, {x: FlxG.width - tileSize + 10, y: j * tileSize + 10}, time);
				} else {
					FlxTween.tween(cursor, {x: 185, y: FlxG.height - 50}, time);
				}
			}
			i += 1;
		}
		add(cursor);
		add(instructions);
		add(goal);
		timer.start(time + 0.3, animateButton, 7);
	}

	private function tutorialB() {
		var timer = new haxe.Timer(500);
		var time = 1.0;
		var elapsed = 0;
		var forward = new FlxSprite(170, FlxG.height - 70, "assets/images/forward.png");
		forward.alpha = 0.5;
		var cursor = new FlxSprite(185, FlxG.height - 50, "assets/images/dragcursor.png");
		cursor.alpha = 0.5;
		var dragText = new FlxText(250, FlxG.height - 45, 300, "", 12);
		dragText.text = "click and drag sequence onto the track";
		var playText = new FlxText(10, FlxG.height - 100, 300, "", 12);
		playText.text = "press PLAY to start looping sequence";
		var goalText = new FlxText(100, 150, 300, 12);
		goalText.text = "make the bulldozer push the matching gem into the goal";

		function tut_goal() {
			if (this.isPlaying) {
				playText.destroy();
				add(goalText);
				timer.stop();
			}
		}

		function tut_play() {
			if (this.controlManager.hasControls()) {
				this.playButton.visible = true;
				dragText.destroy();
				forward.destroy();
				cursor.destroy();
				add(playText);
				timer.run = tut_goal;
			} else if (elapsed >= 2000){
				forward.setPosition(170, FlxG.height - 70);
				cursor.setPosition(185, FlxG.height - 50);
				FlxTween.tween(forward, {x: FlxG.width - this.controlManager.tileSize, y: 0}, time);
				FlxTween.tween(cursor, {x: FlxG.width - this.controlManager.tileSize + 10, y: 10}, time);
				elapsed = 0;
			}
			elapsed += 500;
		}

		this.playButton.visible = false;
		add(dragText);
		add(forward);
		add(cursor);
		FlxTween.tween(forward, {x: FlxG.width - this.controlManager.tileSize, y: 0}, time);
		FlxTween.tween(cursor, {x: FlxG.width - this.controlManager.tileSize + 10, y: 10}, time);
		timer.run = tut_play;
	}
}
