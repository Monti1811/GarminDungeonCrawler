import Toybox.Lang;

class FireEmber extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4002;
		self.name = "Fire Ember";
		self.description = "A smoldering ember that refuses to go out.";
		self.value = 40;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.fire_ember;
	}
}
