import Toybox.Lang;


class SteelShoes extends ArmorItem {
	var id as Number = 1003;
	var name as String = "Steel Shoes";
	var slot as ItemSlot = HEAD;
	var description as String = "A simple steel shoes";
	var value as Number = 10;
	var weight as Number = 10;
	var attribute_bonus as Dictionary<Symbol, Number> = {
		:constitution => 2
	};

	function initialize() {
		ArmorItem.initialize();
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