package;

import Vehicle;
import Color;
import Wall;
import Gem;
import Control;

import haxe.ds.HashMap;

class Level {
	private var json:Dynamic;
	private var name:String;
	public var number:Int;

	private static var idCounter:Int = 0;

	public function new(filePath:String) {
		this.name = filePath;
		this.number = Std.parseInt(filePath.split('.')[1]);
	}

	public function load() {
		var s = openfl.Assets.getText(this.name);
		this.json = haxe.Json.parse(s);
		// trace(this.json.objectData);
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
		return 32;
	}

	public function getBannedControls():Array<Control> {
		if (!this.json.banned) {
			return new Array();
		}

		var bannedControls = new Array();
		for (i in 0...this.json.banned.length) {
			var bannedControl = this.json.banned[i];
			if (bannedControl == 'FORWARD') {
				bannedControls.push(Control.FORWARD);
			} else if (bannedControl == 'LEFT') {
				bannedControls.push(Control.LEFT);
			} else if (bannedControl == 'RIGHT') {
				bannedControls.push(Control.RIGHT);
			} else if (bannedControl == 'PAUSE') {
				bannedControls.push(Control.PAUSE);
			}
		}

		return bannedControls;
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
					object.attributes.orientation
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

	public function getWalls():Array<Wall> {
		var walls = new Array();
		for (row in 0...this.json.tileData.length) {
			for (col in 0...this.json.tileData[row].length) {
				if (this.json.tileData[row][col] == 1) {
					var wall = new Wall(idCounter, col, row);
					walls.push(wall);
					idCounter += 1;
				}
			}
		}

		return walls;
	}
}
