package;

import Control;
import Vehicle;
import Goal;
import Gem;
import Wall;
import OptimalLevelCount;

import haxe.ds.HashMap;

class Simulator {
	public var width:Int;
	public var height:Int;
	public var levelNumber:Int;

	private var vehicles:HashMap<Color, Array<Vehicle>>;
	private var goals:Array<Goal>;
	private var walls:Array<Wall>;
	private var gems:Array<Gem>;
	private var finishedGems:Array<Gem>;

	private var controls:HashMap<Color, Array<Control>>;
	private var controlIndices:HashMap<Color, Int>;

	public function new(
		width:Int,
		height:Int,
		level: Level
	) {
		this.width = width;
		this.height = height;

		this.vehicles = level.getVehicles();
		this.gems = level.getGems();
		this.walls = level.getWalls();
		this.finishedGems = new Array();
		this.goals = level.getGoals();
		this.levelNumber = level.number;
	}

	public function getVehicles():Array<Vehicle> {
		var result = new Array();
		for (color in this.vehicles.keys()) {
			var vehicles = this.vehicles.get(color);
			for (i in 0...vehicles.length) {
				result.push(vehicles[i]);
			}
		}

		return result;
	}

	private function countNumControls():Int {
		var count = 0;
		for (color in this.controls.keys()) {
			count += this.controls.get(color).length;
		}

		return count;
	}

	public function getScore():Int {
		var numControls = this.countNumControls();
		var difference = numControls - OptimalLevelCount.getCountForLevel(this.levelNumber);

		// User found a more optimal way to solve the level
		if (difference < 0) {
			return 200;
		}

		return Std.int(100.0 / (difference + 1));
	}

	public function didUserWin():Bool {
		return this.gems.length == 0;
	}

	public function getGems():Array<Gem> {
		return this.gems.concat(this.finishedGems);
	}

	public function getGoals():Array<Goal> {
		return this.goals;
	}

	public function getWalls():Array<Wall> {
		return this.walls;
	}

	public function getControlIndices():HashMap<Color, Int> {
		return this.controlIndices;
	}

	public function onSetControls(controls:HashMap<Color, Array<Control>>) {
		this.controls = controls;

		this.controlIndices = new HashMap();
		for (color in controls.keys()) {
			this.controlIndices.set(color, 0);
		}

		this.reset();
	}

	public function tick():Bool {
		for (color in this.controlIndices.keys()) {
			var index = this.controlIndices.get(color);
			var controls = this.controls.get(color);
			if (controls.length == 0) {
				continue;
			}

			// Move the vehicles forward in time 1 step
			var control = controls[index];
			var vehicles = this.vehicles.get(color);
			for (i in 0...vehicles.length) {
				vehicles[i].updateWithControl(control, this);
			}

			// Reset the index of the control back to the beginning if gone over
			if (index + 1 >= controls.length) {
				this.controlIndices.set(color, 0);
			} else {
				this.controlIndices.set(color, index + 1);
			}
		}

		// Check for collisions between cars
		var allVehicles:Array<Dynamic> = this.getVehicles();
		if (checkCollisions(allVehicles)) {
			return false;
		}

		// Cars are clear, update gem positions
		for (i in 0...allVehicles.length) {
			var vehicle = allVehicles[i];
			for (j in 0...this.gems.length) {
				var gem = this.gems[j];
				if (gem.x == vehicle.x && gem.y == vehicle.y) {
					// Gem and car are overlapping -> advance the gem forward
					if (!gem.moveWithDirection(vehicle.direction, this)) {
						// Gem collided with the wall: Undo the control on the
						var controls = this.controls.get(vehicle.color);

						var index = this.controlIndices.get(vehicle.color);
						index = (index == 0) ? controls.length - 1 : index - 1;
						vehicle.undoControl(controls[index], this);
					}

					// Check if a gem is in a goal state
					this.checkForGoalGems(gem);
					break; // Assume that no two gems can be colliding with a car at once
				}
			}
		}

		// Check that no cars ghosted through one another
		for (i in 0...allVehicles.length) {
			var vehicle = allVehicles[i];
			for (j in 0...allVehicles.length) {
				if (i == j) {
					continue;
				}

				var badCollision = false;
				var other = allVehicles[j];

				var vehicleControls = this.controls.get(vehicle.color);
				var otherControls = this.controls.get(other.color);

				var vehicleIndex = this.controlIndices.get(vehicle.color);
				var otherIndex = this.controlIndices.get(other.color);

				vehicleIndex = (vehicleIndex == 0) ? vehicleControls.length - 1 : vehicleIndex - 1;
				otherIndex = (otherIndex == 0) ? otherControls.length - 1 : otherIndex - 1;

				vehicle.undoControl(vehicleControls[vehicleIndex], this);
				if (vehicle.x == other.x && vehicle.y == other.y) {
					badCollision = true;
				}

				vehicle.updateWithControl(vehicleControls[vehicleIndex], this);
				other.undoControl(otherControls[otherIndex], this);
				if (vehicle.x == other.x && vehicle.y == other.y && badCollision) {
					return false;
				}

				other.updateWithControl(otherControls[otherIndex], this);
			}
		}

		var allObjects:Array<Dynamic> = allVehicles.concat(this.gems);
		return !checkCollisions(allObjects);
	}

	private function checkForGoalGems(gem:Gem) {
		for (i in 0...this.goals.length) {
			var goal = this.goals[i];
			if (gem.color == goal.color && gem.x == goal.x && gem.y == goal.y) {
				gem.isInGoal = true;
				gem.parentGoal = goal;
				this.gems.remove(gem);
				this.finishedGems.push(gem);
				break;
			}
		}
	}

	private function checkCollisions(objects:Array<Dynamic>):Bool {
		for (i in 0...objects.length) {
			for (j in (i + 1)...objects.length) {
				if (objects[i].x == objects[j].x && objects[i].y == objects[j].y) {
					return true;
				}
			}
		}

		return false;
	}

	public function reset() {
		for (color in this.vehicles.keys()) {
			for (i in 0...this.vehicles.get(color).length) {
				this.vehicles.get(color)[i].reset();
			}
		}

		this.gems = this.gems.concat(this.finishedGems);
		this.finishedGems = new Array();
		for (i in 0...this.gems.length) {
			this.gems[i].reset();
		}

		for (color in this.controlIndices.keys()) {
			this.controlIndices.set(color, 0);
		}
	}
}
