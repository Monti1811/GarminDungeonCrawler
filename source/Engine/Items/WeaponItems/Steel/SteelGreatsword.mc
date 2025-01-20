import Toybox.Lang;


class SteelGreatsword extends WeaponItem {

	function initialize() {
		WeaponItem.initialize();
		id = 3;
		name = "Steel Greatsword";
		description = "A simple steel greatsword";
		slot = RIGHT_HAND;
		value = 20;
		weight = 25;
		attribute_bonus = {
			:strength => 4,
			:dexterity => -2
		};

		attack = 12;
		range = 2;
		weapon_type = TWOHAND;
		cooldown = 1;
	}

	function onEquipItem(player as Player) as Void {
		WeaponItem.onEquipItem(player);
		player.unequipItem(LEFT_HAND);
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
		return $.Rez.Drawables.steel_greatsword;
	}

	function deepcopy() as Item {
		var greatsword = new SteelGreatsword();
		greatsword.name = name;
		greatsword.description = description;
		greatsword.value = value;
		greatsword.amount = amount;
		greatsword.attribute_bonus = attribute_bonus;
		greatsword.pos = pos;
		greatsword.equipped = equipped;
		greatsword.in_inventory = in_inventory;
		greatsword.attack = attack;
		greatsword.range = range;
		return greatsword;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
	}

}