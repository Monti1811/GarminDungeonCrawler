import Toybox.Lang;


class SteelBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1001;
		name = "Steel Breastplate";
		description = "A steel breastplate";
		value = 10;
		weight = 10;
		slot = CHEST;
		defense = 5;
		attribute_bonus = {
			:constitution => 2,
			:dexterity => -1
		};
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
		return $.Rez.Drawables.steel_armor;
	}

	function deepcopy() as Item {
		var breastplate = new SteelBreastPlate();
		breastplate.name = name;
		breastplate.description = description;
		breastplate.value = value;
		breastplate.amount = amount;
		breastplate.attribute_bonus = attribute_bonus;
		breastplate.pos = pos;
		breastplate.equipped = equipped;
		breastplate.in_inventory = in_inventory;
		breastplate.defense = defense;
		return breastplate;
	}

}