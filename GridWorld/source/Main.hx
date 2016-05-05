package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		AnalyticsAPI.init();
		AnalyticsAPI.emitEvent('lifecycle', 'initialization', 'startup');
		addChild(new FlxGame(640, 480, MenuState, 1, 60, 60, true));
	}
}
