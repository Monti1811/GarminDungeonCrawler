import Toybox.Lang;


class SteelHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1000;
		name = "Steel Helmet";
		description = "A simple steel helmet";
		value = 7;
		weight = 3;
		slot = HEAD;
		defense = 3;
		attribute_bonus = {
			:constitution => 2
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
		return $.Rez.Drawables.steel_helmet;
	}
	

	function deepcopy() as Item {
		var helmet = new SteelHelmet();
		helmet.name = name;
		helmet.description = description;
		helmet.value = value;
		helmet.amount = amount;
		helmet.attribute_bonus = attribute_bonus;
		helmet.pos = pos;
		helmet.equipped = equipped;
		helmet.in_inventory = in_inventory;
		helmet.defense = defense;
		return helmet;
	}

}