import Toybox.Lang;


class SteelBreastPlate extends ArmorItem {
	var id as Number = 1001;
	var name as String = "Steel Breastplate";
	var slot as ItemSlot = CHEST;
	var description as String = "A simple steel breastplate";
	var value as Number = 10;
	var weight as Number = 15;
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