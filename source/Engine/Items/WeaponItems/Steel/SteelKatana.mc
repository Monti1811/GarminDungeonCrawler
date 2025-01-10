import Toybox.Lang;


class SteelKatana extends WeaponItem {
	var id as Number = 4;
	var name as String = "Steel Katana";
	var description as String = "A simple steel katana";
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
		return $.Rez.Drawables.steel_katana;
	}

	function deepcopy() as Item {
		var katana = new SteelSword();
		katana.name = name;
		katana.description = description;
		katana.value = value;
		katana.amount = amount;
		katana.attribute_bonus = attribute_bonus;
		katana.pos = pos;
		katana.equipped = equipped;
		katana.in_inventory = in_inventory;
		katana.attack = attack;
		katana.range = range;
		return katana;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
	}

}