package;

import Control;
import Vehicle;
import Goal;
import Gem;

import haxe.ds.HashMap;

class Simulator {
	public var width:Int;
	public var height:Int;

	private var vehicles:HashMap<Color, Array<Vehicle>>;
	private var goals:Array<Goal>;
	private var gems:Array<Gem>;

	private var controls:Map<Color, Array<Control>>;
	private var controlIndices:Map<Color, Int>;

	public function new(
		width:Int,
		height:Int,
		level: Level
	) {
		this.width = width;
		this.height = height;

		this.vehicles = level.getVehicles();
		this.gems = level.getGems();
		this.goals = level.getGoals();
	}

	public function onSetControls(controls:Map<Color, Array<Control>>) {
		this.reset();
		this.controls = controls;

		this.controlIndices = new Map();

		for (color in controls.keys()) {
			this.controlIndices[color] = 0;
		}
	}

	public function tick() {
		for (color in this.controlIndices.keys()) {
			var index = this.controlIndices[color];
			var control = this.controls[color][index];

			for (i in 0...this.vehicles.get(color).length) {
				this.vehicles.get(color)[i].updateWithControl(control, this);
			}

			this.controlIndices[color] += 1;

			// Reset the index of the control back to the beginning if gone over
			if (index >= this.controls[color].length) {
				this.controlIndices[color] = 0;
			}
		}
	}

	public function reset() {
		for (color in this.vehicles.keys()) {
			for (i in 0...this.vehicles.get(color).length) {
				this.vehicles.get(color)[i].reset();
			}
		}

		for (i in 0...gems.length) {
			gems[i].reset();
		}

		for (color in this.controlIndices.keys()) {
			this.controlIndices[color] = 0;
		}
	}


}
