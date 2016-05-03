package;

import Vehicle;
import Color;

import haxe.ds.HashMap;

class Level {
	private var json:Dynamic;
	private var name:String;

	private static var idCounter:Int = 0;

	public function new(filePath:String) {
		this.name = filePath;
	}

	public function load() {
		var s = openfl.Assets.getText(this.name);
		this.json = haxe.Json.parse(s);
		trace(this.json.objectData);
	}

	public function getGrid() {
		return this.json.tileData;
	}

	public function getObjects() {
		return this.json.objectData;
	}

	public function getWidth(): Int {
		return this.json.width;
	}

	public function getHeight(): Int {
		return this.json.height;
	}

	public function getTileSize(): Int {
		return this.json.tileSize;
	}

	public function getVehicles():HashMap<Color, Array<Vehicle>> {
		var vehicles = new HashMap();
		for (i in 0...this.json.objectData.length) {
			var object = this.json.objectData[i];
			if (object.attributes.type.indexOf('Vehicles') != -1) {
				var color = Color.getColor(object.attributes.color);
				var vehicle = new Vehicle(
					idCounter,
					color,
					object.x,
					object.y,
					object.orientation
				);
				idCounter += 1;

				if (!vehicles.exists(color)) {
					vehicles.set(color, new Array());
				}

				vehicles.get(color).push(vehicle);
			}
		}

		return vehicles;
	}

	public function getColors():Array<Color> {
		var colors = new HashMap();
		for (i in 0...this.json.objectData.length) {
			var object = this.json.objectData[i];
			if (object.attributes.type.indexOf('Vehicles') != -1) {
				var color = Color.getColor(object.attributes.color);
				colors.set(color, 0);
			}
		}

		return [for (k in colors.keys()) k];
	}

	public function getGems():Array<Gem> {
		var gems = new Array();
		for (i in 0...this.json.objectData.length) {
			var object = this.json.objectData[i];
			if (object.attributes.type == 'Pushables') {
				var color = Color.getColor(object.attributes.color);
				var gem = new Gem(idCounter, color, object.x, object.y);
				idCounter += 1;
				gems.push(gem);
			}
		}

		return gems;
	}

	public function getGoals():Array<Goal> {
		var goals = new Array();
		for (i in 0...this.json.objectData.length) {
			var object = this.json.objectData[i];
			if (object.attributes.type == 'Goal') {
				var color = Color.getColor(object.attributes.order[0]);
				var goal = new Goal(idCounter, color, object.x, object.y);
				idCounter += 1;
				goals.push(goal);
			}
		}

		return goals;
	}
}
