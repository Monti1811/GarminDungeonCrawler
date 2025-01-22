import Toybox.Lang;


class SteelDagger extends WeaponItem {

	function initialize() {
		WeaponItem.initialize();
		id = 2;
		name = "Steel Dagger";
		description = "A simple steel dagger";
		slot = EITHER_HAND;
		value = 10;
		weight = 10;
		attribute_bonus = {
			:dexterity => 2,
			:luck => 2
		};

		attack = 7;
		// range = 1;
		attack_type = DEXTERITY;
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
		return $.Rez.Drawables.steel_dagger;
	}

	function deepcopy() as Item {
		var dagger = new SteelDagger();
		dagger.name = name;
		dagger.description = description;
		dagger.value = value;
		dagger.amount = amount;
		dagger.attribute_bonus = attribute_bonus;
		dagger.pos = pos;
		dagger.equipped = equipped;
		dagger.in_inventory = in_inventory;
		dagger.attack = attack;
		dagger.range = range;
		return dagger;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
	}

}