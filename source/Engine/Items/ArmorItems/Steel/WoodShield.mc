import Toybox.Lang;

class WoodShield extends ArmorItem {
	
	function initialize() {
		ArmorItem.initialize();
		id = 1006;
		name = "Shield";
		description = "A simple shield";
		value = 5;
		weight = 3;
		slot = LEFT_HAND;
		attribute_bonus = {
			:constitution => 3,
			:dexterity => -1
		};

		defense = 4;

	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		ArmorItem.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		ArmorItem.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		ArmorItem.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		ArmorItem.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		ArmorItem.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		ArmorItem.onBuyItem(player);
	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.shield_wood;
	}

	function deepcopy() as Item {
		var shield = new WoodShield();
		shield.name = name;
		shield.description = description;
		shield.value = value;
		shield.amount = amount;
		shield.attribute_bonus = attribute_bonus;
		shield.defense = defense;
		return shield;
	}
}