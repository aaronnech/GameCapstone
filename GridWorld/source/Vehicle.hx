package;

class Vehicle extends Turnable {
	public var color:Color;

	override public function new(color:Color, x:Int, y:Int, direction:Int) {
		super(x, y, direction);
		this.color = color;
	}
}
