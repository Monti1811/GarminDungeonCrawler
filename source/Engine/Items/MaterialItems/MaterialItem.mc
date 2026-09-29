import Toybox.Lang;

class MaterialItem extends Item {

	function initialize() {
		Item.initialize();
		type = MATERIAL;
		slot = NONE;
		tag = :material;
		weight = 0.2;
	}

	function canBeUsed(player as Player) as Boolean {
		return false;
	}

	function onUseItem(player as Player) as Void {}

	function onDropItem(player as Player) as Void {}

	function onSellItem(player as Player) as Void {}

	function onBuyItem(player as Player) as Void {}

	function deepcopy() as Item {
		var copy = Items.createItemFromId(id);
		if (copy == null) {
			return self;
		}
		copy.amount = amount;
		copy.pos = pos;
		copy.equipped = equipped;
		copy.in_inventory = in_inventory;
		return copy;
	}
}
