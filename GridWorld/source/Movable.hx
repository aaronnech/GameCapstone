package;

import GameObject;
import Wall;

class Movable extends GameObject {
	public var x:Int;
	public var y:Int;

	public var startingX:Int;
	public var startingY:Int;

	public function new(id:Int, x:Int, y:Int) {
		super(id);
		this.x = x;
		this.y = y;

		this.startingX = x;
		this.startingY = y;
	}

	public function updatePosition(deltaX:Int, deltaY:Int, sim:Simulator):Bool {
		var x = this.x + deltaX;
		var y = this.y + deltaY;

		var walls = sim.getWalls();
		for (i in 0...walls.length) {
			if (walls[i].x == x && walls[i].y == y) {
				return false;
			}
		}

		if (x >= 0 && y >= 0 && y < sim.height && x < sim.width) {
			this.x += deltaX;
			this.y += deltaY;
			return true;
		}

		return false;
	}

	public function reset() {
		this.x = this.startingX;
		this.y = this.startingY;
	}
}
