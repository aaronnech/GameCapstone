package;

import Color;

class Vehicle extends Turnable {
	public var color:Color;

	override public function new(id:Int, color:Color, x:Int, y:Int, direction:Int) {
		super(id, x, y, direction);
		this.color = color;
	}

    public function hashcode():Int {
        this.id;
    }
}
