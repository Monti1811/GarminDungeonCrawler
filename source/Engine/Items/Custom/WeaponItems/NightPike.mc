import Toybox.Lang;


class NightPike extends WeaponItem {

	function initialize() {
		WeaponItem.initialize();
		id = 303;
		name = "Night Pike";
		description = "A custom weapon item";
		slot = RIGHT_HAND;
		value = 10;
		weight = 1.0;
		attack = 10;
		range = 1;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_sword;
	}

	function deepcopy() as Item {
		var nightPike = new NightPike();
		nightPike.name = name;
		nightPike.description = description;
		nightPike.value = value;
		nightPike.amount = amount;
		nightPike.attribute_bonus = attribute_bonus;
		nightPike.pos = pos;
		nightPike.equipped = equipped;
		nightPike.in_inventory = in_inventory;
		nightPike.attack = attack;
		nightPike.range = range;
		return nightPike;
	}

}
