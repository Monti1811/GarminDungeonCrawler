import Toybox.Lang;

class IceCrystal extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4003;
		self.name = "Ice Crystal";
		self.description = "A crystal of unmelting ice.";
		self.value = 60;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_crystal;
	}
}
