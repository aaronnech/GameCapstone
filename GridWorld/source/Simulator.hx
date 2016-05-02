package;

class Simulator {
	public var width:Int;
	public var height:Int;

	private var vehicles:Map<Color, Array<Vehicle>>;
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

		this.vehicles = vehicles;
		this.goals = goals;
		this.gems = gems;
	}

	public function onSetControls(controls:Map<Color, Array<Control>>) {
		this.reset();
		this.controls = controls;

		this.controlIndices = new Map();

		for (var color in controls.keys()) {
			this.controlIndices[color] = 0;
		}
	}

	public function tick() {
		for (var color in this.controlIndices.keys()) {
			var index = this.controlIndices[color];
			var control = this.controls[color][index];

			for (var i = 0; i < this.vehicles[color].length; i++) {
				this.vehicles[color][i].updateWithControl(control, this);
			}

			this.controlIndices[color]++;
			// Reset the index of the control back to the beginning if gone over
			if (index >= this.controls[color].length {
				this.controlIndices[color] = 0;
			}
		}
	}

	public function reset() {
		for (var color in this.vehicles.keys()) {
			for (var i = 0; i < this.vehicles[color].length; i++) {
				this.vehicles[color][i].reset();
			}
		}

		for (var i = 0; i < gems.length; i++) {
			gems[i].reset();
		}

		for (var color in this.controlIndices.keys()) {
			this.controlIndices[color] = 0;
		}
	}


}
