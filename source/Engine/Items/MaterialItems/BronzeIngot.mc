import Toybox.Lang;

class BronzeIngot extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4001;
		self.name = "Bronze Ingot";
		self.description = "A warm bronze bar, tough and reliable.";
		self.value = 20;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.bronze_ingot;
	}
}
