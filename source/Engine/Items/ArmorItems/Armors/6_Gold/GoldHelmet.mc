import Toybox.Lang;

class GoldHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1060;
		name = "Gold Helmet";
		description = "A golden helm radiant with divine protection.";
		value = 35;
		weight = 3;
		slot = HEAD;
		defense = 7;
		attribute_bonus = {
			:constitution => 8
		};
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new GoldHelmet();
		// ...existing code...
		return helmet;
	}

}
