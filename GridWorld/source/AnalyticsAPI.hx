package;
import flixel.util.FlxSave;
import haxe.Http;

class AnalyticsAPI {
    #if flash
        private static var kongLoaded:Bool;
    #end

    private static var SERVER_ENDPOINT = "https://students.washington.edu/drapeau/games/logger.php";
    private static var KEY = "COFFEEISGO123123OD_ANDLYFEBLOOD23123123";
    private static var GAME_VERSION = "2.5";
    private static var eventNum:Int;
    private static var save:FlxSave;
    private static var userID:String;
    private static var screenToken:String;
    private static var host:String;
    private static var screenName:String;
    private static var isAEnabled:Bool;
    private static var isInitialized:Bool = false;

    private static function genUUID() {
        return GUID.gen();
    }

    public static function sendMaxScoreToKong(score:Int) {
        #if flash
            if (AnalyticsAPI.kongLoaded) {
                flixel.addons.api.FlxKongregate.submitScore(score, "Normal");
            }
        #end
    }

    public static function sendBeatAllLevelsToKong() {
        #if flash
            if (AnalyticsAPI.kongLoaded) {
                flixel.addons.api.FlxKongregate.submitStats("Beat All Levels", 1);
            }
        #end
    }

    public static function isA() {
        return AnalyticsAPI.isAEnabled;
    }

    public static function init() {
        if (AnalyticsAPI.isInitialized) return;

        #if flash
            flixel.addons.api.FlxKongregate.init(function() {
                flixel.addons.api.FlxKongregate.connect();
                AnalyticsAPI.kongLoaded = true;
            });
        #end

        // Get or set the UUID / AB Test cohort
        AnalyticsAPI.save = new FlxSave();
        AnalyticsAPI.save.bind("Game");
        if (!AnalyticsAPI.save.data.userID) {
            AnalyticsAPI.save.data.userID = AnalyticsAPI.genUUID();
            AnalyticsAPI.save.data.isAEnabled = Std.random(2) > 0;
            AnalyticsAPI.save.flush();
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

        AnalyticsAPI.isInitialized = true;
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
        // var req = new Http(AnalyticsAPI.SERVER_ENDPOINT);

        // // req.addHeader("Access-Control-Allow-Origin", "*");
        // req.setParameter("user_id", AnalyticsAPI.userID);
        // req.setParameter("app_token", haxe.crypto.Md5.encode(AnalyticsAPI.KEY + AnalyticsAPI.userID + AnalyticsAPI.eventNum));
        // req.setParameter("version", "" + AnalyticsAPI.GAME_VERSION);
        // req.setParameter("event_number", "" + AnalyticsAPI.eventNum);
        // req.setParameter("host_name", AnalyticsAPI.host);
        // req.setParameter("screen_token", AnalyticsAPI.screenToken);
        // req.setParameter("screen_name", AnalyticsAPI.screenName);
        // req.setParameter("event_category", category);
        // req.setParameter("event_name", event);
        // req.setParameter("event_value", "" + value);
        // req.setParameter("is_a", AnalyticsAPI.isAEnabled ? "1" : "0");
        // req.request(false);
        //

        var url:String = AnalyticsAPI.SERVER_ENDPOINT;
        url += "?";
        url += "user_id=" + AnalyticsAPI.userID;
        url += "&app_token=" + haxe.crypto.Md5.encode(AnalyticsAPI.KEY + AnalyticsAPI.userID + AnalyticsAPI.eventNum);
        url += "&version=" + AnalyticsAPI.GAME_VERSION;
        url += "&event_number=" + AnalyticsAPI.eventNum;
        url += "&host_name=" + AnalyticsAPI.host;
        url += "&screen_token=" + AnalyticsAPI.screenToken;
        url += "&screen_name=" + AnalyticsAPI.screenName;
        url += "&event_category=" + category;
        url += "&event_name=" + event;
        url += "&event_value=" + value;
        url += "&is_a=" + (AnalyticsAPI.isAEnabled ? "1" : "0");

        #if js
            // well, in javascript ocurrs the same thing with CORS, so no request, just load an image.
            var img:js.html.Image = new js.html.Image();
            img.src = url;
        #elseif flash
            // we must load GoogleAnalytics using Flash API (like loading an image to avoid the check
            // of a crossdomain.xml
            var l : flash.display.Loader = new flash.display.Loader();
            var urlRequest : flash.net.URLRequest=new flash.net.URLRequest();
            urlRequest.url=url;
            //flash have unspoken error that can happen nonetheless due to denied DNS resolution...
            l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, function(foo){});
            try{ l.load(urlRequest); }catch(e:Dynamic){}
        #end

        AnalyticsAPI.eventNum += 1;
    }
}
