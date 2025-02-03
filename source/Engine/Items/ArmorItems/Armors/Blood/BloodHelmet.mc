import Toybox.Lang;

class BloodHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1058;
		name = "Blood Helmet";
		description = "A blood helmet, reflecting the blood of your enemies.";
		value = 3000;
		weight = 3;
		slot = HEAD;
		defense = 25;
		attribute_bonus = {
			:constitution => 10,
			:strength => 5,
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new BloodHelmet();
		// ...existing code...
		return helmet;
	}

}
