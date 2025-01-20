import Toybox.Lang;


class SteelBow extends Bow {
	var id as Number = 1;
	var name as String = "Steel Bow";
	var description as String = "A simple steel bow";

	function initialize() {
		Bow.initialize();
		id = 1;
		name = "Steel Bow";
		description = "A simple steel bow";
		slot = RIGHT_HAND;
		value = 10;
		weight = 10;
		attribute_bonus = {
			:dexterity => 2
		};

		attack = 3;
		range = 3;
		range_type = LINEAR;

	}

	function onEquipItem(player as Player) as Void {
		Bow.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		Bow.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		Bow.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		Bow.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		Bow.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		Bow.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		Bow.onBuyItem(player);
	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_bow;
	}

	function deepcopy() as Item {
		var bow = new SteelBow();
		bow.name = name;
		bow.description = description;
		bow.value = value;
		bow.amount = amount;
		bow.attribute_bonus = attribute_bonus;
		bow.pos = pos;
		bow.equipped = equipped;
		bow.in_inventory = in_inventory;
		bow.attack = attack;
		bow.range = range;
		return bow;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		Bow.onLoad(save_data);
	}

}