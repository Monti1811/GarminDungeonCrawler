import Toybox.Lang;

class IceHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1030;
		name = "Ice Helmet";
		description = "A helm carved from a single shard of eternal frost.";
		value = 70;
		weight = 3;
		slot = HEAD;
		defense = 22;
		attribute_bonus = {
			:constitution => 3,
			:wisdom => 3,
			:luck => 1
		};
		element = ELEMENT_ICE;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new IceHelmet();
		// ...existing code...
		return helmet;
	}

}
