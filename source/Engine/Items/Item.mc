import Toybox.Lang;

class Item {
	var id as Number = 0;
	var name as String = "Item";
	var description as String = "";
	var type as ItemType = CUSTOM; 	
	var slot as ItemSlot = NONE; 
	var value as Number = 0;
	var amount as Number = 1;
	var weight as Number = 1;
	var pos as Point2D = [0, 0];

	function initialize();
	function onEquipItem(player as Player) as Void;
	function onUnequipItem(player as Player) as Void;
	function canBeUsed(player as Player) as Boolean {
		return true;
	}
	function onUseItem(player as Player) as Void;
	function onPickupItem(player as Player) as Void;
	function onDropItem(player as Player) as Void;
	function onSellItem(player as Player) as Void;
	function onBuyItem(player as Player) as Void;

	function hashCode() {
		return id;
	}

	function getPos() as Point2D {
		return pos;
	}

	function setPos(pos as Point2D) as Void {
		self.pos = pos;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.LauncherIcon;
	}

	function canBePickedUp(player as Player) as Boolean {
		return true;
	}

	function getName() as String {
		return name;
	}

	function getDescription() as String {
		return description;
	}

	function getItemType() as ItemType {
		return type;
	}

	function getItemSlot() as ItemSlot {
		return slot;
	}

	function getValue() as Number {
		return value;
	}
	
	function getAmount() as Number {
		return amount;
	}
}