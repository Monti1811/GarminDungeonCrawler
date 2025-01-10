import Toybox.Lang;


class SteelAxe extends WeaponItem {
	var id as Number = 0;
	var name as String = "Steel Axe";
	var description as String = "A simple steel axe";
	var slot as ItemSlot = RIGHT_HAND;
	var value as Number = 10;
	var weight as Number = 10;
	var attribute_bonus as Dictionary<Symbol, Number> = {
		:strength => 2
	};

	function initialize() {
		WeaponItem.initialize();
		attack = 10;
		range = 1;
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
		return $.Rez.Drawables.steel_axe;
	}

	function deepcopy() as Item {
		var axe = new SteelAxe();
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

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
	}

}