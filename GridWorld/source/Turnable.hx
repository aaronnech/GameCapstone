package;

import Control;
import Movable;
import Simulator;

class Turnable extends Movable {
	public static var NUM_POSSIBLE_DIRECTIONS:Int = 4;
	public var direction:Int;

	public var startingDirection:Int;

	override public function new(x:Int, y:Int, direction:Int) {
		super(x, y);
		this.direction = direction;
		this.startingDirection = direction;
	}

	public function updateWithControl(control:Control, sim:Simulator) {
		if (control == Control.FORWARD) {
			this.updatePositionWithControl(control, sim, 1);
		} else if (control == Control.LEFT) {
			this.direction = (this.direction - 1) % NUM_POSSIBLE_DIRECTIONS;
		} else if (control == Control.RIGHT) {
			this.direction = (this.direction + 1) % NUM_POSSIBLE_DIRECTIONS;
		}
	}

	public function undoControl(control:Control, sim:Simulator) {
		if (control == Control.FORWARD) {
			this.updatePositionWithControl(control, sim, -1);
		} else if (control == Control.LEFT) {
			this.direction = (this.direction + 1) % NUM_POSSIBLE_DIRECTIONS;
		} else if (control == Control.RIGHT) {
			this.direction = (this.direction - 1) % NUM_POSSIBLE_DIRECTIONS;
		}
	}

	private function updatePositionWithControl(control:Control, sim:Simulator, reverse:Int) {
		switch this.direction {
			case 0: this.updatePosition(reverse * 0, reverse * -1, sim);
			case 1: this.updatePosition(reverse * 1, reverse * 0, sim);
			case 2: this.updatePosition(reverse * 0, reverse * 1, sim);
			case 3: this.updatePosition(reverse * -1,reverse *  0, sim);
		}
	}

	private function updatePosition(deltaX:Int, deltaY:Int, sim:Simulator) {
		// TODO: Bounds checking
		var x = this.x + deltaX;
		var y = this.y + deltaY;

		if (x >= 0 && y >= 0 && y < sim.height && x < sim.width) {
			this.x += deltaX;
			this.y += deltaY;
		}
	}

	override public reset() {
		super.reset();
		this.direction = startingDirection;
	}
}
