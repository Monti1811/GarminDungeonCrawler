import Toybox.Lang;


class SteelDagger extends WeaponItem {
	var id as Number = 2;
	var name as String = "Steel Dagger";
	var description as String = "A simple steel dagger";
	var slot as ItemSlot = RIGHT_HAND;
	var value as Number = 10;
	var weight as Number = 10;
	var attribute_bonus as Dictionary<Symbol, Number> = {
		:luck => 2
	};

	function initialize() {
		WeaponItem.initialize();
		attack = 7;
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