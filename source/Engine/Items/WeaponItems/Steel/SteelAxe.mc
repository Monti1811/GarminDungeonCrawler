import Toybox.Lang;


class SteelAxe extends WeaponItem {

	function initialize() {
		WeaponItem.initialize();
		id = 0;
		name = "Steel Axe";
		description = "A simple steel axe";
		value = 10;
		weight = 10;
		slot = RIGHT_HAND;
		attribute_bonus = {
			:strength => 4,
			:dexterity => -1,
			:luck => -1
		};

		attack = 8;

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