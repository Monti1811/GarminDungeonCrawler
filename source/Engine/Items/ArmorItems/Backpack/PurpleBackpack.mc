import Toybox.Lang;

class PurpleBackpack extends ArmorItem {

	private const size = 15;

	function initialize() {
		ArmorItem.initialize();
		id = 1251;
		name = "Purple Backpack";
		description = "A bigger backpack";
		value = 500;
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
		player.getInventory().increaseWeight(size);
	}

	function onUnequipItem(player as Player) as Void {
		ArmorItem.onUnequipItem(player);
		player.getInventory().decreaseWeight(size);
	}

	function deepcopy() as Item {
		var backpack = new PurpleBackpack();
		backpack.amount = amount;
		backpack.pos = pos;
		backpack.equipped = equipped;
		backpack.in_inventory = in_inventory;
		return backpack;
	}

}
	