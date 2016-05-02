package ;

#if sys
	import sys.io.File;
#elseif js
	import js.Browser;
#end

class Level {
	private var json:Dynamic;
	private var name:String;

	public function new(filePath:String) {
		this.name = filePath;
	}

	public function load(cb:Dynamic) {
		#if sys
			var s = File.getContent(this.name);
			this.json = haxe.Json.parse(s);
			cb();
		#elseif js
			var req = new haxe.Http(this.name);
			req.onData = function (data : String) {
				this.json = haxe.Json.parse(data);
				cb();
			}
			req.onError = function (error) {
				trace(error);
			}
			req.request(false);
		#end
	}

	public function getGrid() {
		return this.json.tileData;
	}

	public function getObjects() {
		return this.json.objectData;
	}
}