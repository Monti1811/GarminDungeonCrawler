import Toybox.Lang;

class DemonShard extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4007;
		self.name = "Demon Shard";
		self.description = "A jagged shard of demonic matter.";
		self.value = 250;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_shard;
	}
}
