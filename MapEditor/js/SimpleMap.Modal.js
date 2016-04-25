var SimpleMap = SimpleMap || {};

SimpleMap.TileModal = function(def) {
	if(typeof(def) != 'undefined') {
		this.id = 'tileModal_' + ($('.tileModal').length + 1);
		$(body).append('<div id="' + this.id + '" class="tileModal" title="' + def.name + '">\
						  <form>\
						  <fieldset>\
						    <label for="name">Name</label>\
						    <input type="text" name="name" id="' + this.id + '_name" class="text ui-widget-content ui-corner-all" />\
						    <label for="color">Color</label>\
						    <input type="text" name="color" id="' + this.id + '_color" value="" class="text ui-widget-content ui-corner-all" />\
						  </fieldset>\
						  <fieldset class="attr">\
						  	<h2>Attributes</h2>\
						  	<button id="' + this.id + '_addAttr">Add</button>\
						  </fieldset>\
						  <button id="' + this.id + '_submit">Save</button>\
						  </form>\
						</div>');
		$('#' + this.id + '_addAttr', function() {
			$('#' + this.id + ' .attr').append('<div class="attribute-pair">\
													<input type="text" class="attr_name">
												</div>');
		});
	}
}

