var SimpleMap = SimpleMap || {};

/*
* Our Map class. This is a state manager for our tile map editor. Provides hooks into a frontend interface
*/
SimpleMap.Map = function() {
	this.tiles = [];
	this.obj = [];
	this.tileSize = 16;
	this.width = 28;
	this.height = 15;
	this.hovering = false;
};
SimpleMap.Map.method("place", function(def, x, y, img) {
	if(!this.outOfBounds(x, y)) {
		if(def.type == 'tile') {
			this.remove('tile', x, y);
			this.tiles.push(new SimpleMap.Tile(def, x, y, img));
		} else if(def.type == 'object') {
			this.remove('object', x, y);
			this.obj.push(new SimpleMap.MapObject(def, x, y, img));
		}
	}
});
SimpleMap.Map.method("flood", function(def, x, y, img) {
	if(this.get(def.type, x, y) == null)
		this.place(def, x, y, img);
	if(!this.outOfBounds(x - 1, y) && this.get(def.type, x - 1, y) == null)
		this.flood(def, x - 1, y, img);
	if(!this.outOfBounds(x, y - 1) && this.get(def.type, x, y - 1) == null)
		this.flood(def, x, y - 1, img);
	if(!this.outOfBounds(x + 1, y) && this.get(def.type, x + 1, y) == null)
		this.flood(def, x + 1, y, img);
	if(!this.outOfBounds(x, y + 1) && this.get(def.type, x, y + 1) == null)
		this.flood(def, x, y + 1, img);
});
SimpleMap.Map.method("get", function(type, x, y) {
	var result = null;
	if(type == 'tile') {
		$.each(this.tiles, function(index, value) {
			if(value.x == x && value.y == y) {
				result = value;
			}
		});
	} else if(type == 'object') {
		$.each(this.obj, function(index, value) {
			if(value.x == x && value.y == y)
				result = value;
		});
	}
	return result;
});
SimpleMap.Map.method("remove", function(type, x, y) {
	var toRemove = -1;
	if(type == 'tile') {
		$.each(this.tiles, function(index, value) {
			if(value.x == x && value.y == y)
				toRemove = index;
		});
		if(toRemove >= 0) {
			this.tiles.splice(toRemove, 1);
			return true;
		}
	} else if(type == 'object') {
		$.each(this.obj, function(index, value) {
			if(value.x == x && value.y == y)
				toRemove = index;
		});
		if(toRemove >= 0) {
			this.obj.splice(toRemove, 1);
			return true;
		}
	}
	return false;
});
SimpleMap.Map.method("trimBounds", function() {
	for(var i = this.tiles.length - 1; i >= 0; i--)
		if(this.outOfBounds(this.tiles[i].x, this.tiles[i].y))
			this.tiles.splice(i, 1);
	for(var i = this.obj.length - 1; i >= 0; i--)
		if(this.outOfBounds(this.obj[i].x, this.obj[i].y))
			this.obj.splice(i, 1);
});
SimpleMap.Map.method("outOfBounds", function(x, y) {
	return x >= this.width || x < 0 || y >= this.height || y < 0;
});
SimpleMap.Map.method("active", function(hovering) {
	this.hovering = hovering;
});
SimpleMap.Map.method("draw", function(processing, hovered) {
	var that = this;
	processing.stroke(0, 0, 0);
	processing.strokeWeight(2);
	$.each(this.tiles, function(index, value) {
		if(typeof(value.img) != 'undefined') {
			processing.image(value.img, value.x * that.tileSize, value.y * that.tileSize,
				that.tileSize, that.tileSize);
		} else {
			processing.fill(hexToR(value.definition.color),
			 hexToG(value.definition.color), hexToB(value.definition.color));
			processing.rect(value.x * that.tileSize, value.y * that.tileSize,
			 that.tileSize, that.tileSize);
		}
	});
	$.each(this.obj, function(index, value) {
		if(typeof(value.img) != 'undefined') {
			processing.image(value.img, value.x * that.tileSize, value.y * that.tileSize,
				that.tileSize, that.tileSize);
		} else {
			processing.fill(hexToR(value.definition.color),
			 hexToG(value.definition.color), hexToB(value.definition.color));
			processing.ellipse(value.x * that.tileSize + (that.tileSize / 2),
			 value.y * that.tileSize + (that.tileSize / 2),
			 that.tileSize, that.tileSize);
		}
	});
	if(typeof(hovered) != 'undefined') {
		if(typeof(hovered.imageData) != 'undefined') {
			processing.image(hovered.imageData, this.toGrid(processing.mouseX) * this.tileSize,
				 this.toGrid(processing.mouseY) * this.tileSize,
				 this.tileSize, this.tileSize);
		} else {
			processing.fill(hexToR(hovered.color), hexToG(hovered.color), hexToB(hovered.color));
			if(hovered.type == 'tile') {
				processing.rect(this.toGrid(processing.mouseX) * this.tileSize,
				 this.toGrid(processing.mouseY) * this.tileSize,
				 this.tileSize, this.tileSize);
			} else if(hovered.type == 'object') {
				processing.ellipse(this.toGrid(processing.mouseX) * this.tileSize + (this.tileSize / 2),
				 this.toGrid(processing.mouseY) * this.tileSize + (this.tileSize / 2),
				 this.tileSize, this.tileSize);
			}
		}
	}
	//draw boundary
	processing.stroke(255, 255, 255);
	processing.strokeWeight(4);
	processing.line(0, 0, this.width * this.tileSize, 0);
	processing.line(this.width * this.tileSize, 0, this.width * this.tileSize, this.height * this.tileSize);
	processing.line(0, this.height * this.tileSize, this.width * this.tileSize, this.height * this.tileSize);
	processing.line(0, 0, 0, this.height * this.tileSize);
});

SimpleMap.Map.method("toGrid", function(value) {
	return Math.floor(value / this.tileSize);
});

SimpleMap.Map.method("setDimensions", function(width, height, tileSize) {
	this.width = width;
	this.height = height;
	this.tileSize = tileSize;
	this.trimBounds();
});

SimpleMap.Map.method("exportTiles", function() {
	var result = [];
	for(var y = 0; y < this.height; y++) {
		var row = [];
		for(var x = 0; x < this.width; x++) {
			var getTile = this.get('tile', x, y);
			if(getTile != null) {
				row.push(getTile.definition.value);
			} else {
				row.push(-1);
			}
		}
		result.push(row);
	}
	return result;
});

SimpleMap.Map.method("exportObjects", function() {
	var result = [];
	for(var i = 0; i < this.obj.length; i++) {
		var test = this.obj[i].exportData();
		result.push(this.obj[i].exportData());
	}
	return result;
});