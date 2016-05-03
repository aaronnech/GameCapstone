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
import haxe.ds.HashMap;

class PlayState extends FlxState {
	private static var TICK_TIME:Float = 0.2;
	private var level:Level;
	private var mainSimulator:Simulator;
    private var spriteManager:ObjectManager;
	private var tileMap:FlxTilemap;
	private var totalElapsed:Float;
	private var controls:HashMap<Color, Array<Control>>;
	private var isPlaying:Bool;

	public function new(level:Level) {
		super();
		this.level = level;
	}

	override public function create():Void {
		super.create();

		this.isPlaying = false;
		this.controls = new HashMap();
		for (color in this.level.getColors()) {
			this.controls.set(color, new Array());
		}

		// FlxG.mouse.visible = false;
		this.mainSimulator = new Simulator(this.level.getWidth(), this.level.getHeight(), this.level);
		this.mainSimulator.onSetControls(this.controls);

		// Background tile map
		trace(this.level.getGrid());
		this.tileMap = new FlxTilemap();
		this.tileMap.loadMapFrom2DArray(this.level.getGrid(), "assets/images/backgroundtiles.png", 24, 24, FlxTilemapAutoTiling.OFF, 0, 0);
		add(this.tileMap);

		// Objects
		this.spriteManager = new ObjectManager(this.mainSimulator, this.level.getTileSize());
		var sprites = this.spriteManager.getSprites();
		for (sprite in sprites) {
			add(sprite);
		}

        // Create control buttons
        var forward:FlxButton = new FlxButton(100, FlxG.height - 70, "", this.onClickForward.bind(Control.FORWARD));
        forward.loadGraphic("assets/images/forward.png");
        var left:FlxButton = new FlxButton(170, FlxG.height - 70, "", this.onClickLeft.bind(Control.LEFT));
        left.loadGraphic("assets/images/left.png");
        var right:FlxButton = new FlxButton(240, FlxG.height - 70, "", this.onClickRight.bind(Control.RIGHT));
        right.loadGraphic("assets/images/right.png");
        var pause:FlxButton = new FlxButton(310, FlxG.height - 70, "", this.onClickPause.bind(Control.PAUSE));
        pause.loadGraphic("assets/images/pause.png");

        var play:FlxButton = new FlxButton(10, FlxG.height - 70, "", this.onClickPlay);
        play.loadGraphic("assets/images/play.png");

        add(forward);
        add(left);
        add(right);
        add(pause);
        add(play);

		this.totalElapsed = 0;
	}

	private function onClickPlay():Void {
		this.isPlaying = !this.isPlaying;
	}

	private function onClickControl(ctl:Control):Void {
		for (color in this.level.getColors()) {
			this.controls.get(color).push(ctl);
			trace(this.controls.get(color));
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		this.totalElapsed = this.totalElapsed + elapsed;
		if (this.isPlaying && this.totalElapsed > PlayState.TICK_TIME) {
			if (this.mainSimulator.tick()) {
				this.spriteManager.update();
			} else {
				this.mainSimulator.reset();
				this.isPlaying = false;
			}
			this.totalElapsed = 0;
		} else if (!this.isPlaying) {
			this.totalElapsed = 0;
		}
	}
}
