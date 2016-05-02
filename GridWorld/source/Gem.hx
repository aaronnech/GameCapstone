package;

class Gem extends Movable {
	public var color:Color;

	override public function new(id:Int, color:Color, x:Int, y:Int) {
		super(id, x, y);
		this.color = color;
	}
}
