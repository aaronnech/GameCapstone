package;

class Movable {
	public var x:Int;
	public var y:Int;

	public var startingX:Int;
	public var startingY:Int;

	public function new(x:Int, y:Int) {
		this.x = x;
		this.y = y;

		this.startingX = x;
		this.startingY = y;
	}

	public function updatePosition(deltaX:Int, deltaY:Int) {
		this.x += deltaX;
		this.y += deltaY;
	}

	public function reset() {
		this.x = this.startingX;
		this.y = this.startingY;
	}
}
