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

class PlayState extends FlxState {
	private var level:Level;
	private var mainSimulator:Simulator;
	private var tileMap:FlxTilemap;

	public function new(level:Level) {
		super();
		this.level = level;
	}

	override public function create():Void {
		super.create();
		FlxG.mouse.visible = false;

		this.mainSimulator = new Simulator(28, 15, this.level);

		// // Background tile map
		// var str:String = '';
		// for (arr in this.level.getGrid()) {
		// 	for (num in arr) {
		// 		str = str + num + ',';
		// 	}
		// }
		// str = str.substr(0, str):String
		// this.tileMap = new FlxTilemap();
		// this.tileMap.loadMap(MapData:String, TileGraphic:Class, TileWidth:uint = 0, TileHeight:uint = 0, AutoTile:uint, StartingIndex:uint = 0, DrawIndex:uint = 1, CollideIndex:uint = 1)
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
