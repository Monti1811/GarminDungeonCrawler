import Toybox.Lang;


class SteelSword extends WeaponItem {

	function initialize() {
		WeaponItem.initialize();
		id = 8;
		name = "Steel Sword";
		description = "A simple steel sword";
		slot = RIGHT_HAND;
		value = 10;
		weight = 10;
		attribute_bonus = {
			:strength => 2
		};

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
		return $.Rez.Drawables.steel_sword;
	}

	function deepcopy() as Item {
		var sword = new SteelSword();
		sword.name = name;
		sword.description = description;
		sword.value = value;
		sword.amount = amount;
		sword.attribute_bonus = attribute_bonus;
		sword.pos = pos;
		sword.equipped = equipped;
		sword.in_inventory = in_inventory;
		sword.attack = attack;
		sword.range = range;
		return sword;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
	}

}