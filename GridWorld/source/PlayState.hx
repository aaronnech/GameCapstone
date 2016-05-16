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

	public function new(levels:Array<Level>, cur:Int) {
		super();
		AnalyticsAPI.levelStart(cur);
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

		// FlxG.mouse.visible = false;
		this.mainSimulator = new Simulator(this.level.getWidth(), this.level.getHeight(), this.level);

		// Create control panel
		this.controlManager = new ControlManager(70, this.level.getColors(),
												 this.level.getBannedControls(),
												 this.mainSimulator, this);
		this.controls = this.controlManager.getControls();

		this.mainSimulator.onSetControls(this.controls);

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

		// Objects
		this.spriteManager = new ObjectManager(this.mainSimulator, this.level.getTileSize());
		this.spriteManager.xOffset = 80;
		this.spriteManager.yOffset = 50;
		this.spriteManager.generate();
		var sprites = this.spriteManager.getSprites();
		for (sprite in sprites) {
			this.add(sprite);
		}

		// UI
		this.createUI();

		if (level.number == 1) {
			this.dragAndDropTutorial();
		}

		this.totalElapsed = 0;
	}

	private function createUI():Void {
        this.playButton = new FlxButton(10, FlxG.height - 70, "", this.onClickPlay);
		this.playButton.loadGraphic("assets/images/stop.png");
        this.playButton.loadGraphic("assets/images/play.png");

        var backButton = new FlxButton(10, 10, "Menu", this.onClickBack);

        add(backButton);
        add(this.playButton);
	}

	private function onClickBack() {
		FlxG.switchState(new LevelSelectState());
		this.isPlaying = false;
		this.controlManager.enableControls();
		AnalyticsAPI.click('playstate', 'back', this.levelIndex);
	}

	private function onClickPlay():Void {
		if (!this.controlManager.hasControls()) {
			AnalyticsAPI.click('playstate', 'play-disabled', this.levelIndex);
			return;
		}

		AnalyticsAPI.click('playstate', 'play-enabled', this.levelIndex);

		this.isPlaying = !this.isPlaying;
		if (!this.isPlaying) {
			AnalyticsAPI.levelReset(this.levelIndex);
		}
		this.mainSimulator.reset();
		this.spriteManager.snap();
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

				AnalyticsAPI.levelCrash(this.levelIndex);

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

		this.updatePlayControls();
	}

	private function dragAndDropTutorial() {
		var actors = [
			new FlxSprite(170, FlxG.height - 70, "assets/images/forward.png"),
			new FlxSprite(170, FlxG.height - 70, "assets/images/forward.png"),
			new FlxSprite(170, FlxG.height - 70, "assets/images/forward.png")
		];
		var tileSize = this.controlManager.tileSize;
		var timer = new FlxTimer();
		var i = 0;

		function animateButton(timer:FlxTimer) {
			if (i == actors.length + 1) {
				for (actor in actors) {
					actor.destroy();
				}
				return;
			} else if (i < actors.length) {
				add(actors[i]);
				FlxTween.tween(actors[i], {x: FlxG.width - tileSize, y: i * tileSize}, 1);
			}
			i += 1;
		}

		timer.start(0.7, animateButton, 5);
	}
}
