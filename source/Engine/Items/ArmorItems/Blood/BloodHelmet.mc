import Toybox.Lang;

class BloodHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1058;
		name = "Blood Helmet";
		description = "A simple blood helmet";
		value = 45;
		weight = 3;
		slot = HEAD;
		defense = 11;
		attribute_bonus = {
			:constitution => 10
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
