import Toybox.Lang;


class SteelGauntlets extends ArmorItem {
	var id as Number = 1002;
	var name as String = "Steel Gauntlets";
	var slot as ItemSlot = HEAD;
	var description as String = "Simple steel gauntlets";
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
		return $.Rez.Drawables.steel_gauntlets;
	}
	

	function deepcopy() as Item {
		var gauntlets = new SteelGauntlets();
		gauntlets.name = name;
		gauntlets.description = description;
		gauntlets.value = value;
		gauntlets.amount = amount;
		gauntlets.attribute_bonus = attribute_bonus;
		gauntlets.pos = pos;
		gauntlets.equipped = equipped;
		gauntlets.in_inventory = in_inventory;
		gauntlets.defense = defense;
		return gauntlets;
	}

}