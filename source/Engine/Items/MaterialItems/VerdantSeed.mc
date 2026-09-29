import Toybox.Lang;

class VerdantSeed extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4004;
		self.name = "Verdant Seed";
		self.description = "A seed pulsing with plant life.";
		self.value = 90;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.verdant_seed;
	}
}
