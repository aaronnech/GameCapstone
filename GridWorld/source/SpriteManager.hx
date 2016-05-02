package ;

import flixel.FlxSprite;

interface SpriteManager {
	public function getSprites():List<FlxSprite>;
	public function update():Void;
	public function setSimulator(s:Simulator);
}