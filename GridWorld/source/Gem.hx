package;

class Gem extends Movable {
	public var color:Color;

	override public function new(color:Color, x:Int, y:Int) {
		super(x, y);
		this.color = color;
	}
}
