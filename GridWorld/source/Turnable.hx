package;

import Control;
import Movable;
import Simulator;

class Turnable extends Movable {
	public static var NUM_POSSIBLE_DIRECTIONS:Int = 4;
	public var direction:Int;

	public var startingDirection:Int;

	override public function new(id:Int, x:Int, y:Int, direction:Int) {
		super(id, x, y);
		this.direction = direction;
		this.startingDirection = direction;
	}

	public function updateWithControl(control:Control, sim:Simulator):Bool {
		if (control == Control.FORWARD) {
			return this.updatePositionWithControl(control, sim, 1);
		} else if (control == Control.LEFT) {
			this.direction = (this.direction - 1) % NUM_POSSIBLE_DIRECTIONS;
			if (this.direction == -1) {
				this.direction = NUM_POSSIBLE_DIRECTIONS - 1;
			}

			return true;
		} else if (control == Control.RIGHT) {
			this.direction = (this.direction + 1) % NUM_POSSIBLE_DIRECTIONS;
			return true;
		}

		return false;
	}

	public function undoControl(control:Control, sim:Simulator):Bool {
		if (control == Control.FORWARD) {
			return this.updatePositionWithControl(control, sim, -1);
		} else if (control == Control.LEFT) {
			this.direction = (this.direction + 1) % NUM_POSSIBLE_DIRECTIONS;
			return true;
		} else if (control == Control.RIGHT) {
			this.direction = (this.direction - 1) % NUM_POSSIBLE_DIRECTIONS;
			if (this.direction == -1) {
				this.direction = NUM_POSSIBLE_DIRECTIONS - 1;
			}

			return true;
		}

		return false;
	}

	private function updatePositionWithControl(control:Control, sim:Simulator, reverse:Int):Bool {
		switch this.direction {
			case 0: return this.updatePosition(0, reverse * -1, sim);
			case 1: return this.updatePosition(reverse * 1, 0, sim);
			case 2: return this.updatePosition(0, reverse * 1, sim);
			case 3: return this.updatePosition(reverse * -1, 0, sim);
			default: return false;
		}
	}

	override public function reset() {
		super.reset();
		this.direction = startingDirection;
	}
}
