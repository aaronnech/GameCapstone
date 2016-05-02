package;

class Color {
	private static var singletons:Map<String, Color> = new Map();
	public var color:String;

	private function new(color:String) {
		this.color = color;
	}

	public static function getColor(color:String) {
		if (!singletons.exists(color)) {
			singletons[color] = new Color(color);
		}

		return singletons[color];
	}

	public function hashCode():Int {
        return this.color.charCodeAt(0);
    }

	public function toString() {
        return this.color;
    }
}
