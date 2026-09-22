import Toybox.Lang;

class GoldGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1062;
		name = "Gold Gauntlets";
		description = "Golden gauntlets that amplify the wearer's strength.";
		value = 28;
		weight = 2;
		slot = EITHER_HAND;
		defense = 7;
		attribute_bonus = {
			:charisma => 8
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new GoldGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
