import Toybox.Lang;


class SteelShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1003;
		name = "Steel Shoes";
		description = "A simple steel shoes";
		value = 10;
		weight = 10;
		slot = FEET;
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
		return $.Rez.Drawables.steel_leg_armor;
	}
	

	function deepcopy() as Item {
		var shoes = new SteelShoes();
		shoes.name = name;
		shoes.description = description;
		shoes.value = value;
		shoes.amount = amount;
		shoes.attribute_bonus = attribute_bonus;
		shoes.pos = pos;
		shoes.equipped = equipped;
		shoes.in_inventory = in_inventory;
		shoes.defense = defense;
		return shoes;
	}

}