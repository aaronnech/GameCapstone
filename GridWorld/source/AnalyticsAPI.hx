package;

import googleAnalytics.Stats;

class AnalyticsAPI {
    public static function init() {
    	var myURL:String = 'cs.washington.edu';
    	#if js
    		myURL = js.Browser.window.location.href;
    	#elseif flash
    		myURL = ((new flash.net.LocalConnection()).domain);
    	#end
    	trace(myURL);
        Stats.init('UA-77349792-1', myURL);
    }

    public static function click(screen:String, buttonName:String, lvl:Int=-1) {
    	var str = '';
    	if (lvl != -1) {
    		str = screen + '/' + 'level-' + lvl;
    	} else {
    		str = screen;
    	}
    	AnalyticsAPI.emitEvent('Click', buttonName, str);
    }

    public static function score(lvl:Int, score:Int) {
    	AnalyticsAPI.emitEvent('Score', '' + score, 'level-' + lvl);
    }

    public static function levelComplete(lvl:Int) {
    	AnalyticsAPI.emitProgress('/level-' + lvl + '/complete');
    }

    public static function levelCrash(lvl:Int) {
    	AnalyticsAPI.emitProgress('/level-' + lvl + '/crash');
    }

    public static function levelReset(lvl:Int) {
    	AnalyticsAPI.emitProgress('/level-' + lvl + '/reset');
    }

    public static function levelStart(lvl:Int) {
    	AnalyticsAPI.emitProgress('/level-' + lvl + '/start');
    }

    public static function emitEvent(category:String, event:String, label:String) {
        Stats.trackEvent(category, event, label, 0);
    }

    public static function emitProgress(location:String) {
        Stats.trackPageview(location);
    }
}
