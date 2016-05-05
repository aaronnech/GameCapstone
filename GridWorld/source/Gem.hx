package;

import Color;

class Gem extends Movable {
	public var color:Color;
	public var isInGoal:Bool;
	public var parentGoal:Goal;

	override public function new(id:Int, color:Color, x:Int, y:Int) {
		super(id, x, y);
		this.color = color;
		this.isInGoal = false;
	}

	public function moveWithDirection(direction:Int, sim:Simulator):Bool {
		switch direction {
			case 0: return this.updatePosition(0, -1, sim);
			case 1: return this.updatePosition(1, 0, sim);
			case 2: return this.updatePosition(0, 1, sim);
			case 3: return this.updatePosition(-1, 0, sim);
			default: return false;
		}
	}

	override public function reset() {
		super.reset();
		this.isInGoal = false;
		this.parentGoal = null;
	}
}
