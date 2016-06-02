package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxSound;

class MenuState extends FlxState {
	private var play:FlxButton;
	private var logo:FlxSprite;
	private var backdrop:FlxBackdrop;

	override public function create():Void {
		super.create();
		AnalyticsAPI.init();
		AnalyticsAPI.setScreen('mainMenu');
		AnalyticsAPI.emitEvent('progress', 'loadMainMenu');
		FlxG.mouse.visible = true;

		backdrop = new FlxBackdrop('assets/images/justfloor.png');
		add(backdrop);

		play = new FlxButton(0, 0, "Play", clickPlay);
		play.scale.set(2, 2);
		play.label.size = 12;
		play.screenCenter();
		add(play);

		logo = new FlxSprite(0, 0);
		logo.loadGraphic('assets/images/logo.png');
		logo.screenCenter();
		logo.y -= 100;
		add(logo);
	}

	private function clickPlay():Void {
		AnalyticsAPI.click('navigation', 'play');
		var levelSelect = new LevelSelectState();
		var levelOne = levelSelect.getStartState();
		if (levelOne == null) {
			FlxG.switchState(levelSelect);
		} else {
			FlxG.switchState(levelOne);
		}
	}
}
