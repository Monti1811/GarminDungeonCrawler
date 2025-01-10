import Toybox.Lang;


class SteelLance extends WeaponItem {
	var id as Number = 5;
	var name as String = "Steel Spear";
	var description as String = "A simple steel spear";
	var slot as ItemSlot = RIGHT_HAND;
	var value as Number = 10;
	var weight as Number = 10;
	var attribute_bonus as Dictionary<Symbol, Number> = {
		:luck => 2
	};

	function initialize() {
		WeaponItem.initialize();
		attack = 10;
		range = 2;
		range_type = LINEAR;
	}

	function onEquipItem(player as Player) as Void {
		WeaponItem.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		WeaponItem.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		WeaponItem.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		WeaponItem.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		WeaponItem.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		WeaponItem.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		WeaponItem.onBuyItem(player);
	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_lance;
	}

	function deepcopy() as Item {
		var axe = new SteelLance();
		axe.name = name;
		axe.description = description;
		axe.value = value;
		axe.amount = amount;
		axe.attribute_bonus = attribute_bonus;
		axe.pos = pos;
		axe.equipped = equipped;
		axe.in_inventory = in_inventory;
		axe.attack = attack;
		axe.range = range;
		return axe;
	}

}