import Toybox.Lang;

class GreenBackpack extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1250;
		name = "Green Backpack";
		description = "A simple backpack";
		value = 100;
		weight = 0.5;
		slot = BACK;
		attribute_bonus = {};
		defense = 0;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.backpack_green;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
		player.getInventory().increaseWeight(5);
	}

	function onUnequipItem(player as Player) as Void {
		ArmorItem.onUnequipItem(player);
		player.getInventory().decreaseWeight(5);
	}

	function getDefense(enemy, armors_size) as Number {
		return ArmorItem.getDefense(enemy, armors_size);
	}

	function deepcopy() as Item {
		var backpack = new GreenBackpack();
		backpack.amount = amount;
		backpack.pos = pos;
		backpack.equipped = equipped;
		backpack.in_inventory = in_inventory;
		backpack.defense = defense;
		return backpack;
	}

}
	