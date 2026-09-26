import Toybox.Lang;

class IceGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1032;
		name = "Ice Gauntlets";
		description = "Gauntlets rimmed with frost that freeze on contact.";
		value = 50;
		weight = 2;
		slot = EITHER_HAND;
		defense = 22;
		attribute_bonus = {
			:charisma => 3,
			:wisdom => 4,
		};
		element = ELEMENT_ICE;
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new IceGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
