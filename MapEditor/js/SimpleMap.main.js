var simpleMap;
var renderer;
var selected;
var palette;

$(document).ready(function() {
	var json = {
		'settings' : {
			'tileSize' : 24,
			'width' : 28,
			'height' : 15
		},
		'tiles' : [
			{
				"group" : "Basic",
				"members" : [
					{
						'type' : 'tile',
						'name' : 'Wall',
						'value' : 1,
						'color' : '#FF0000'
					},
					{
						'type' : 'tile',
						'name' : 'Normal',
						'value' : 0,
						'color' : '#999999'
					}
				]
			}
		],
		'objects' : [
			{
				"group" : "Delete",
				"members" : [
					{
						'type' : 'object',
						'name' : 'Delete',
						'color' : '#FF0000',
						'attributes' : {
							'color' : 'red',
							'type' : 'delete'
						}
					},
				]
			},
			{
				"group" : "VehiclesNorth",
				"members" : [
					{
						'type' : 'object',
						'name' : 'Vehicle 1',
						'color' : '#0000FF',
						'attributes' : {
							'color' : 'blue',
							'type' : 'VehiclesNorth',
							'orientation' : 0
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 2',
						'color' : '#FF0000',
						'attributes' : {
							'color' : 'red',
							'type' : 'VehiclesNorth',
							'orientation' : 0
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 3',
						'color' : '#00FF00',
						'attributes' : {
							'color' : 'green',
							'type' : 'VehiclesNorth',
							'orientation' : 0
						}
					}
				]
			},
			{
				"group" : "VehiclesEast",
				"members" : [
					{
						'type' : 'object',
						'name' : 'Vehicle 1',
						'color' : '#0000FF',
						'attributes' : {
							'color' : 'blue',
							'type' : 'VehiclesEast',
							'orientation' : 1
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 2',
						'color' : '#FF0000',
						'attributes' : {
							'color' : 'red',
							'type' : 'VehiclesEast',
							'orientation' : 1
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 3',
						'color' : '#00FF00',
						'attributes' : {
							'color' : 'green',
							'type' : 'VehiclesEast',
							'orientation' : 1
						}
					}
				]
			},
			{
				"group" : "VehiclesSouth",
				"members" : [
					{
						'type' : 'object',
						'name' : 'Vehicle 1',
						'color' : '#0000FF',
						'attributes' : {
							'color' : 'blue',
							'type' : 'VehiclesSouth',
							'orientation' : 3
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 2',
						'color' : '#FF0000',
						'attributes' : {
							'color' : 'red',
							'type' : 'VehiclesSouth',
							'orientation' : 3
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 3',
						'color' : '#00FF00',
						'attributes' : {
							'color' : 'green',
							'type' : 'VehiclesSouth',
							'orientation' : 3
						}
					}
				]
			},
			{
				"group" : "VehiclesWest",
				"members" : [
					{
						'type' : 'object',
						'name' : 'Vehicle 1',
						'color' : '#0000FF',
						'attributes' : {
							'color' : 'blue',
							'type' : 'VehiclesWest',
							'orientation' : 3
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 2',
						'color' : '#FF0000',
						'attributes' : {
							'color' : 'red',
							'type' : 'VehiclesWest',
							'orientation' : 3
						}
					},
					{
						'type' : 'object',
						'name' : 'Vehicle 3',
						'color' : '#00FF00',
						'attributes' : {
							'color' : 'green',
							'type' : 'VehiclesWest',
							'orientation' : 3
						}
					}
				]
			},
			{
				"group" : "Pushables",
				"members" : [
					{
						'type' : 'object',
						'name' : 'Red Rock',
						'color' : '#992222',
						'attributes' : {
							'color' : 'red',
							'type' : 'Pushables'
						}
					},
					{
						'type' : 'object',
						'name' : 'Green Rock',
						'color' : '#229922',
						'attributes' : {
							'color' : 'green',
							'type' : 'Pushables'
						}
					},
					{
						'type' : 'object',
						'name' : 'Blue Rock',
						'color' : '#222299',
						'attributes' : {
							'color' : 'blue',
							'type' : 'Pushables'
						}
					}
				]
			},
			{
				"group" : "Simple Goals",
				"members" : [
					{
						'type' : 'object',
						'name' : 'Red Goal',
						'color' : '#992222',
						'img' : 'hole_r.png',
						'attributes' : {
							'order' : ['red'],
							'type' : 'Goal'
						}
					},
					{
						'type' : 'object',
						'name' : 'Green Hole',
						'color' : '#229922',
						'img' : 'hole_g.png',
						'attributes' : {
							'order' : ['green'],
							'type' : 'Goal'
						}
					},
					{
						'type' : 'object',
						'name' : 'Blue Goal',
						'color' : '#222299',
						'img' : 'hole_b.png',
						'attributes' : {
							'order' : ['blue'],
							'type' : 'Goal'
						}
					}
				]
			},
			{
				"group" : "Mixed Goals",
				"members" : [
					{
						'type' : 'object',
						'name' : 'RGB Goal',
						'color' : '#992222',
						'img' : 'hole_rgb.png',
						'attributes' : {
							'order' : ['red', 'green', 'blue'],
							'type' : 'Goal'
						}
					},
					{
						'type' : 'object',
						'name' : 'RBG Goal',
						'color' : '#229922',
						'img' : 'hole_rbg.png',
						'attributes' : {
							'order' : ['red', 'blue', 'green'],
							'type' : 'Goal'
						}
					},
					{
						'type' : 'object',
						'name' : 'BRG Goal',
						'color' : '#222299',
						'img' : 'hole_brg.png',
						'attributes' : {
							'order' : ['blue', 'red', 'green'],
							'type' : 'Goal'
						}
					},
					{
						'type' : 'object',
						'name' : 'BGR Goal',
						'color' : '#992222',
						'img' : 'hole_bgr.png',
						'attributes' : {
							'order' : ['blue', 'green', 'red'],
							'type' : 'Goal'
						}
					},
					{
						'type' : 'object',
						'name' : 'GBR Goal',
						'color' : '#229922',
						'img' : 'hole_gbr.png',
						'attributes' : {
							'order' : ['green', 'blue', 'red'],
							'type' : 'Goal'
						}
					},
					{
						'type' : 'object',
						'name' : 'GRB Goal',
						'color' : '#222299',
						'img' : 'hole_grb.png',
						'attributes' : {
							'order' : ['green', 'red', 'blue'],
							'type' : 'Goal'
						}
					}
				]
			}
		]
	};

	init(json, function() {
		$(document).tooltip();
	});
});

function init(json, callback) {
	palette = json;
	simpleMap = new SimpleMap.Map();
	var canvas = document.getElementById("SimpleMap-render");
	renderer = new Processing(canvas, render);
	setupToolbox();
	setupInterface();
	callback();
}

function setupToolbox() {
	$(".tool input").change(settings);
	$(".exportLevel").click(toJson);
	loadPalette();
}
function loadPalette() {
	loadSettings();
	loadSwatches();

}
function loadSettings() {
	$('#tileSize').val(palette.settings.tileSize);
	$('#tileSize').parent().find('.tool-display').html(palette.settings.tileSize);
	$('#width').val(palette.settings.width);
	$('#width').parent().find('.tool-display').html(palette.settings.width);
	$('#height').val(palette.settings.height);
	$('#height').parent().find('.tool-display').html(palette.settings.height);
	simpleMap.setDimensions(palette.settings.width, palette.settings.height,
	 palette.settings.tileSize);
}
function loadSwatches() {
	$('#tiles ul.grid').html('');
	$('#objects ul.grid').html('');
	$.each(palette.tiles, function(index, value) {
		$('#tiles ul.grid').append('<h2>' + value.group + '</h2>')
		$.each(value.members, function(memberIndex, memberValue) {
			if(typeof(memberValue.img) == 'undefined') {
				$('#tiles ul.grid').append('<li class="no-image"><a href="#" class="tile" data-name="' + memberValue.name + '"\
				 style="background-color: ' + memberValue.color + '" title="' + memberValue.name + '"></a></li>');
			} else {
				$('#tiles ul.grid').append('<li class="image"><a href="#" class="tile" data-name="' + memberValue.name + '"\
				 title="' + memberValue.name + '"><img src="img/' + memberValue.img + '" /></a></li>');
				//processingImages[memberValue.name] = renderer.loadImage("img/" + memberValue.img);
			}
		});
	});
	$.each(palette.objects, function(index, value) {
		$('#objects ul.grid').append('<h2>' + value.group + '</h2>')
		$.each(value.members, function(memberIndex, memberValue) {
			if(typeof(memberValue.img) == 'undefined') {
				$('#objects ul.grid').append('<li class="no-image"><a href="#" class="object" data-name="' + memberValue.name + '"\
				 style="background-color: ' + memberValue.color + '" title="' + memberValue.name + '"></a></li>');
			} else {
				$('#objects ul.grid').append('<li class="image"><a href="#" class="object" data-name="' + memberValue.name + '"\
				 title="' + memberValue.name + '"><img src="img/' + memberValue.img + '" /></a></li>');
				// processingImages[memberValue.name] = renderer.loadImage("img/" + memberValue.img);
			}
		});
	});
	$(".tile").click(swatch);
	$(".object").click(swatch);
}

function setupInterface() {
	renderer.size(800, 600);
	$("#SimpleMap-tools").accordion();
}

function swatch() {
	$(".selectedSwatch").removeClass("selectedSwatch");
	$(this).addClass("selectedSwatch");
	var name = $(this).data('name');
	if($(this).parent().parent().parent().attr('id') == 'tiles') {
		$.each(palette.tiles, function(groupIndex, group) {
			$.each(group.members, function(index, value) {
				if(name == value.name)
					selected = value;
			});
		});
	} else { //selected an object
		$.each(palette.objects, function(groupIndex, group) {
			$.each(group.members, function(index, value) {
				if(name == value.name)
					selected = value;
			});
		});
	}
	if(typeof(selected.img) != 'undefined')
		selected.imageData = renderer.loadImage('img/' + selected.img);
	return false; // cancel link following
}
function settings() {
	var id = $(this).attr('id');
	var value = $(this).val();
	$(this).parent().find('.tool-display').html(value);
	if(id == 'tileSize') {
		simpleMap.setDimensions(simpleMap.width, simpleMap.height, value);
	} else if (id == 'height') {
		simpleMap.setDimensions(simpleMap.width, value, simpleMap.tileSize);
	} else if (id == 'width') {
		simpleMap.setDimensions(value, simpleMap.height, simpleMap.tileSize);
	}
}
function render(processing) {
	processing.mouseClicked = function() {
		if(processing.mouseButton == processing.LEFT) {
			if(typeof(selected.img) == 'undefined') {
				simpleMap.place(selected, simpleMap.toGrid(processing.mouseX),
					simpleMap.toGrid(processing.mouseY));
			} else {
				simpleMap.place(selected, simpleMap.toGrid(processing.mouseX),
					simpleMap.toGrid(processing.mouseY), processing.loadImage('img/' + selected.img));
			}
		} else if(processing.mouseButton == processing.RIGHT) {
			if(typeof(selected.img) == 'undefined') {
				simpleMap.flood(selected, simpleMap.toGrid(processing.mouseX),
					simpleMap.toGrid(processing.mouseY));
			} else {
				simpleMap.flood(selected, simpleMap.toGrid(processing.mouseX),
					simpleMap.toGrid(processing.mouseY), processing.loadImage('img/' + selected.img));
			}
		}
	}
	processing.mouseOver = function() {
		simpleMap.active(true);
	}
	processing.mouseOut = function() {
		simpleMap.active(false);
	}
	processing.draw = function() {
		processing.background(0);
		simpleMap.draw(processing, selected);
	};
}
function toJson() {
	var result = {};
	result.width = simpleMap.width;
	result.height = simpleMap.height;
	result.tileSize = simpleMap.tileSize;
	result.tileData = simpleMap.exportTiles();
	result.objectData = simpleMap.exportObjects();
	alert(JSON.stringify(result));
}