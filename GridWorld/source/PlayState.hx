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
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
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

	public function new(levels:Array<Level>, cur:Int) {
		super();
		this.level = levels[cur];
		this.levels = levels;
	}

	override public function create():Void {
		super.create();
		var backdrop = new FlxBackdrop('assets/images/playbg.png');
		add(backdrop);

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
		this.tileMap.x = 20;
		this.tileMap.y = 20;
		this.add(this.tileMap);

		// Objects
		this.spriteManager = new ObjectManager(this.mainSimulator, this.level.getTileSize());
		this.spriteManager.xOffset = 20;
		this.spriteManager.yOffset = 20;
		this.spriteManager.generate();
		var sprites = this.spriteManager.getSprites();
		for (sprite in sprites) {
			this.add(sprite);
		}

		// UI
		this.createUI();

		this.totalElapsed = 0;
	}

	private function createUI():Void {
        this.playButton = new FlxButton(10, FlxG.height - 70, "", this.onClickPlay);
		this.playButton.loadGraphic("assets/images/stop.png");
        this.playButton.loadGraphic("assets/images/play.png");

        var backButton = new FlxButton(400, FlxG.height - 40, "Menu", this.onClickBack);

        add(backButton);
        add(this.playButton);
	}

	private function onClickBack() {
		FlxG.switchState(new LevelSelectState());
	}

	private function onClickPlay():Void {
		this.isPlaying = !this.isPlaying;
		this.mainSimulator.reset();
		this.spriteManager.snap();
		this.updatePlayControls();
	}

	private function updatePlayControls():Void {
		if (this.isPlaying) {
			this.playButton.loadGraphic("assets/images/stop.png");
		} else {
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
			if (this.mainSimulator.tick()) {
				this.spriteManager.update();
				if (this.mainSimulator.didUserWin()) {
					haxe.Timer.delay(this.endLevel, Std.int(PlayState.TICK_TIME * 1000));
					this.controlManager.resetControlHighlights();
					this.isPlaying = false;
					return;
				}
			} else {
				if (this.mainSimulator.didUserWin()) {
					haxe.Timer.delay(this.endLevel, Std.int(PlayState.TICK_TIME * 1000));
					this.controlManager.resetControlHighlights();
					this.isPlaying = false;
					return;
				}

				this.mainSimulator.reset();
				this.spriteManager.snap();
				this.isPlaying = false;
				this.controlManager.resetControlHighlights();
				FlxG.camera.flash();
				this.updatePlayControls();
			}

			this.totalElapsed = 0;
		} else if (!this.isPlaying) {
			this.totalElapsed = 0;
			this.controlManager.resetControlHighlights();
		}
	}
}
