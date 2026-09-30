import Toybox.Lang;

class GoldIngot extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4006;
		self.name = "Gold Ingot";
		self.description = "A bar of pure gold, prized by smiths.";
		self.value = 180;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_ingot;
	}
}
