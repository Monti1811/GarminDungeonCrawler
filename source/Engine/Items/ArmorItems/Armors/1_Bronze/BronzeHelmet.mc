import Toybox.Lang;

class BronzeHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1010; // Updated ID
		name = "Bronze Helmet";
		description = "A bronze helmet, it's a bit rusty";
		value = 15;
		weight = 3.5;
		slot = HEAD;
		defense = 4;
		attribute_bonus = {
			:constitution => 3
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.bronze_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new BronzeHelmet();
		// ...existing code...
		return helmet;
	}

}
