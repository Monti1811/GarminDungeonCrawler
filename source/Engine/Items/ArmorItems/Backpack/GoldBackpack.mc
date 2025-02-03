import Toybox.Lang;

class GoldBackpack extends ArmorItem {

	private const size = 50;

	function initialize() {
		ArmorItem.initialize();
		id = 1252;
		name = "Gold Backpack";
		description = "The biggest backpack";
		value = 2500;
		weight = 0.5;
		slot = BACK;
		attribute_bonus = {
			:constitution => 2,
			:dexterity => -3,
			:luck => 5
		};
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
		var backpack = new GoldBackpack();
		backpack.amount = amount;
		backpack.pos = pos;
		backpack.equipped = equipped;
		backpack.in_inventory = in_inventory;
		return backpack;
	}

}
	