import Toybox.Lang;

class DemonHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1052;
		name = "Demon Helmet";
		description = "A demon helmet, forged in the fires of hell.";
		value = 1000;
		weight = 5;
		slot = HEAD;
		defense = 18;
		attribute_bonus = {
			:charisma => 10,
			:strength => 5,
			:wisdom => -5,
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new DemonHelmet();
		// ...existing code...
		return helmet;
	}

}
