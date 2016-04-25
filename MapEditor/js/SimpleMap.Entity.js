var SimpleMap = SimpleMap || {};

/*
* Our Tile class. This is anything that will become part of our outputs two dimensional array.
* the definition will provide all necessary information
*/

SimpleMap.Tile = function(def, x, y, img) {
	this.x = x;
	this.y = y;
	this.definition = def;
	if(typeof(img) != 'undefined')
		this.img = img
};

/*
* Our MapObject class. This is anything that will become part of our constructor output.
* the definition will provide all necessary information
*/

SimpleMap.MapObject = function(def, x, y, img) {
	this.x = x;
	this.y = y;
	this.definition = def;
	if(typeof(img) != 'undefined')
		this.img = img
};

SimpleMap.MapObject.method("exportData", function() {
	var result = {};
	result.attributes = this.definition.attributes;
	result.name = this.definition.name;
	result.x = this.x;
	result.y = this.y;
	return result;
});