import Toybox.Lang;

class WaterPearl extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4005;
		self.name = "Water Pearl";
		self.description = "A pearl holding a drop of the deep.";
		self.value = 130;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.water_pearl;
	}
}
