import Toybox.Lang;

class Key extends KeyItem {
	var id as Number = 3000;
	var name as String = "Key";
	var description as String = "Opens treasure chests.";
	var type as ItemType = KEY;
	var slot as ItemSlot = NONE;
	var value as Number = 0;
	var weight as Number = 0;

	function initialize() {
		KeyItem.initialize();
	}

	function canBeUsed(player as Player) as Boolean {
		// Keys are consumed automatically by chests, not manually.
		return false;
	}

	function onUseItem(player as Player) as Void {}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.key;
	}

	function deepcopy() as Item {
		var key = new Key();
		key.amount = amount;
		key.pos = pos;
		key.in_inventory = in_inventory;
		return key;
	}
}