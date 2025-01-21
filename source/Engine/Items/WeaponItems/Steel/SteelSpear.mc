import Toybox.Lang;


class SteelLance extends WeaponItem {

	function initialize() {
		WeaponItem.initialize();
		id = 5;
		name = "Steel Spear";
		description = "A simple steel spear";
		slot = RIGHT_HAND;
		value = 10;
		weight = 10;
		attribute_bonus = {
			:luck => 2
		};

		attack = 10;
		range = 2;
		range_type = LINEAR;
		damage_type = DEXTERITY;
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