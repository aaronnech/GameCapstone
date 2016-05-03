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
	private var level:Level;
	private var mainSimulator:Simulator;
    private var spriteManager:ObjectManager;
	private var tileMap:FlxTilemap;

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
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
