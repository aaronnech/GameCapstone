package ;

import flixel.FlxSprite;

interface SpriteManager {
	public function getSprites():Array<FlxSprite>;
	public function update():Void;
	public function setSimulator(s:Dynamic):Void;
}
