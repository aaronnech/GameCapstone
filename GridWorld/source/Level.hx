package ;


class Level {
	private var json:Dynamic;
	private var name:String;

	public function new(filePath:String) {
		this.name = filePath;
	}

	public function load() {
		var s = openfl.Assets.getText(this.name);
		this.json = haxe.Json.parse(s);
	}

	public function getGrid() {
		return this.json.tileData;
	}

	public function getObjects() {
		return this.json.objectData;
	}
}