import Toybox.Lang;


class Helmet extends ArmorItem {
	var id as Number = 1000;
	var name as String = "Helmet";
	var slot as ItemSlot = HEAD;
	var description as String = "A simple helmet";
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
		return $.Rez.Drawables.Helmet;
	}
	

	function deepcopy() as Item {
		var helmet = new Helmet();
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