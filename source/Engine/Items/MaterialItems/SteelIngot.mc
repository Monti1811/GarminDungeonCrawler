import Toybox.Lang;

class SteelIngot extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4000;
		self.name = "Steel Ingot";
		self.description = "A bar of raw steel, staple of every smith.";
		self.value = 10;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_ingot;
	}
}
