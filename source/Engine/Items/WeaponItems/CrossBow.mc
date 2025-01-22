import Toybox.Lang;


class CrossBow extends Bow {

	function initialize() {
		Bow.initialize();
		id = 10;
		name = "Crossbow";
		description = "A simple crossbow";
		slot = RIGHT_HAND;
		value = 12;
		weight = 4;
		attribute_bonus = {
			:charisma => 2,
			:strength => 2
		};

		attack = 9;
		range = 3;
		range_type = LINEAR;
		attack_type = DEXTERITY;
		cooldown = 2;

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
		return $.Rez.Drawables.crossbow;
	}

	function deepcopy() as Item {
		var bow = new CrossBow();
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