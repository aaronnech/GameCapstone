package;
import flixel.util.FlxSave;
import haxe.Http;

class AnalyticsAPI {
    private static var SERVER_ENDPOINT = "http://students.washington.edu/rdrapeau/";
    private static var GAME_VERSION = "1.0";
    private static var eventNum:Int;
    private static var save:FlxSave;
    private static var userID:String;
    private static var screenToken:String;
    private static var host:String;
    private static var screenName:String;
    private static var isAEnabled:Bool;

    private static function genUUID() {
        return GUID.gen();
    }

    private static function isA() {
        return AnalyticsAPI.isAEnabled;
    }

    public static function init() {
        // Get or set the UUID / AB Test cohort
        AnalyticsAPI.save = new FlxSave();
        AnalyticsAPI.save.bind("Game");
        if (!AnalyticsAPI.save.data.userID) {
            AnalyticsAPI.save.data.userID = AnalyticsAPI.genUUID();
            AnalyticsAPI.save.data.isAEnabled = Std.random(2) > 0;
        }
        AnalyticsAPI.userID = AnalyticsAPI.save.data.userID;
        AnalyticsAPI.isAEnabled = AnalyticsAPI.save.data.isAEnabled;

        // Set host
    	var myURL:String = 'cs.washington.edu';
    	#if js
    		myURL = js.Browser.window.location.href;
    	#elseif flash
    		myURL = ((new flash.net.LocalConnection()).domain);
    	#end
        AnalyticsAPI.host = myURL;

        // Event counter
        AnalyticsAPI.eventNum = 0;
    }

    public static function click(btnCategory:String, btnName:String, enabled:Int=1) {
        AnalyticsAPI.emitEvent(btnCategory, btnName, enabled);
    }

    public static function complete(lvl:Int, score:Int) {
        AnalyticsAPI.setScreen("levelComplete" + lvl);
    	AnalyticsAPI.emitEvent('progress', 'level-complete', score);
    }

    public static function crash() {
    	AnalyticsAPI.emitEvent('progress', 'level-crash');
    }

    public static function reset() {
    	AnalyticsAPI.emitEvent('progress', 'level-reset');
    }

    public static function startLevel(lvl:Int) {
        AnalyticsAPI.setScreen("level" + lvl);
    	AnalyticsAPI.emitEvent('progress', 'level-start');
    }

    public static function setScreen(name:String) {
        AnalyticsAPI.screenName = name;
        AnalyticsAPI.screenToken = genUUID();
    }

    public static function emitEvent(category:String, event:String, value:Int=0) {
        var req = new Http(AnalyticsAPI.SERVER_ENDPOINT);
        req.setParameter("user_id", AnalyticsAPI.userID);
        req.setParameter("version", "" + AnalyticsAPI.GAME_VERSION);
        req.setParameter("event_number", "" + AnalyticsAPI.eventNum);
        req.setParameter("host_name", AnalyticsAPI.host);
        req.setParameter("screen_token", AnalyticsAPI.screenToken);
        req.setParameter("screen_name", AnalyticsAPI.screenName);
        req.setParameter("event_category", category);
        req.setParameter("event_name", event);
        req.setParameter("event_value", "" + value);
        req.setParameter("is_a", AnalyticsAPI.isAEnabled ? "1" : "0");
        req.request(true);

        AnalyticsAPI.eventNum += 1;
    }
}
