package;

import googleAnalytics.Stats;

class AnalyticsAPI {
    public static function init(){
        Stats.init('UA-77349792-1', 'cs.washington.edu');
    }

    public static function emitEvent(category:String, event:String, label:String, value:Int=0) {
        Stats.trackEvent(category, event, label, value);
    }
}
