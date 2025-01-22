import Toybox.Lang;


class SteelStaff extends Staff {
	
	function initialize() {
		Staff.initialize();
		id = 7;
		name = "Steel Staff";
		description = "A simple steel staff. If the player has mana available, uses it to perform more powerful attacks.";
		slot = RIGHT_HAND;
		value = 10;
		weight = 10;
		attribute_bonus = {
			:intelligence => 2
		};

		attack = 2;
		range = 1;
		range_type = LINEAR;
		attack_type = INTELLIGENCE;

		mana_loss = 15;
	}

	function activateStaff() as Void {
		Staff.activateStaff();
		attack = 20;
		range = 3;
	}

	function deactivateStaff() as Void {
		Staff.deactivateStaff();
		attack = 2;
		range = 1;
	}

	function onEquipItem(player as Player) as Void {
		Staff.onEquipItem(player);

	}
	function onUnequipItem(player as Player) as Void {
		Staff.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		Staff.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		Staff.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		Staff.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		Staff.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		Staff.onBuyItem(player);
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
		staff.range_type = range_type;
		staff.active = active;
		staff.current_cooldown = current_cooldown;
		return staff;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		Staff.onLoad(save_data);
	}

}