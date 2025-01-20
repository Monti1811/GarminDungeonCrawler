import Toybox.Lang;


class SteelStaff extends WeaponItem {
	
	function initialize() {
		WeaponItem.initialize();
		id = 7;
		name = "Steel Staff";
		description = "A simple steel staff";
		slot = RIGHT_HAND;
		value = 10;
		weight = 10;
		attribute_bonus = {
			:intelligence => 2
		};

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