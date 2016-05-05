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
		this.controls = new HashMap();
		for (color in this.level.getColors()) {
			this.controls.set(color, new Array());
		}

		// FlxG.mouse.visible = false;
		this.mainSimulator = new Simulator(this.level.getWidth(), this.level.getHeight(), this.level);
		this.mainSimulator.onSetControls(this.controls);

		// Background tile map
		// trace(this.level.getGrid());
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
        // Create control buttons
        var forward:FlxButton = new FlxButton(100, FlxG.height - 70, "", this.onClickControl.bind(Control.FORWARD));
        forward.loadGraphic("assets/images/forward.png");
        var left:FlxButton = new FlxButton(170, FlxG.height - 70, "", this.onClickControl.bind(Control.LEFT));
        left.loadGraphic("assets/images/left.png");
        var right:FlxButton = new FlxButton(240, FlxG.height - 70, "", this.onClickControl.bind(Control.RIGHT));
        right.loadGraphic("assets/images/right.png");
        var pause:FlxButton = new FlxButton(310, FlxG.height - 70, "", this.onClickControl.bind(Control.PAUSE));
        pause.loadGraphic("assets/images/pause.png");

        this.playButton = new FlxButton(10, FlxG.height - 70, "", this.onClickPlay);
		this.playButton.loadGraphic("assets/images/stop.png");
        this.playButton.loadGraphic("assets/images/play.png");

        add(forward);
        add(left);
        add(right);
        add(pause);
        add(this.playButton);
	}

	private function onClickPlay():Void {
		this.isPlaying = !this.isPlaying;
		if (this.isPlaying) {
			this.playButton.loadGraphic("assets/images/stop.png");
		} else {
			this.playButton.loadGraphic("assets/images/play.png");
			this.mainSimulator.reset();
			this.spriteManager.snap();
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
				this.mainSimulator.reset();
				this.spriteManager.snap();
				this.isPlaying = false;
			}
			this.totalElapsed = 0;
		} else if (!this.isPlaying) {
			this.totalElapsed = 0;
		}
	}
}
