import Toybox.Lang;


class SteelStaff extends WeaponItem {
	var id as Number = 7;
	var name as String = "Steel Staff";
	var description as String = "A simple steel staff";
	var slot as ItemSlot = RIGHT_HAND;
	var value as Number = 10;
	var weight as Number = 10;
	var attribute_bonus as Dictionary<Symbol, Number> = {
		:intelligence => 2
	};

	function initialize() {
		WeaponItem.initialize();
		attack = 2;
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
		return $.Rez.Drawables.steel_staff;
	}

	function deepcopy() as Item {
		var staff = new SteelStaff();
		staff.name = name;
		staff.description = description;
		staff.value = value;
		staff.amount = amount;
		staff.attribute_bonus = attribute_bonus;
		staff.pos = pos;
		staff.equipped = equipped;
		staff.in_inventory = in_inventory;
		staff.attack = attack;
		staff.range = range;
		return staff;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
	}

}