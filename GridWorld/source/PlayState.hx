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

class PlayState extends FlxState {
	private static var TICK_TIME:Int = 200;
	private var level:Level;
	private var mainSimulator:Simulator;
    private var spriteManager:ObjectManager;
	private var tileMap:FlxTilemap;
	private var totalElapsed:Float;

	public function new(level:Level) {
		super();
		this.level = level;
	}

	override public function create():Void {
		super.create();

		// FlxG.mouse.visible = false;
		this.mainSimulator = new Simulator(this.level.getWidth(), this.level.getHeight(), this.level);

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

		this.totalElapsed = 0;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		this.totalElapsed = this.totalElapsed + elapsed;
		if (this.totalElapsed > PlayState.TICK_TIME) {
			if (this.mainSimulator.tick()) {
				this.spriteManager.update();
			} else {
				this.mainSimulator.reset();
			}
			this.totalElapsed = 0;
		}
	}
}
