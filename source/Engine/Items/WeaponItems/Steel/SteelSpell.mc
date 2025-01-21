import Toybox.Lang;


class SteelSpell extends Spell {

	function initialize() {
		Spell.initialize();
		id = 6;
		name = "Steel Spell";
		description = "A simple steel spell";
		slot = RIGHT_HAND;
		value = 10;
		weight = 2;
		attribute_bonus = {
			:intelligence => 2
		};

		attack = 8;
		range = 1;
		cooldown = 1;
	}

	function activateSpell() as Void {
		Spell.activateStaff();
		attack = 10;
		range = 3;
		range_type = SURROUNDING;
	}

	function deactivateSpell() as Void {
		Spell.deactivateStaff();
		attack = 2;
		range = 1;
		range_type = DIRECTIONAL;
	}


	function onEquipItem(player as Player) as Void {
		Spell.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		Spell.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		Spell.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		Spell.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		Spell.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		Spell.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		Spell.onBuyItem(player);
	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_spell;
	}

	function deepcopy() as Item {
		var spell = new SteelLance();
		spell.name = name;
		spell.description = description;
		spell.value = value;
		spell.amount = amount;
		spell.attribute_bonus = attribute_bonus;
		spell.pos = pos;
		spell.equipped = equipped;
		spell.in_inventory = in_inventory;
		spell.attack = attack;
		spell.range = range;
		return spell;
	}

}