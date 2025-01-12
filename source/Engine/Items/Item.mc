import Toybox.Lang;
import Toybox.Application;

class Item {
	var id as Number = 0;
	var name as String = "Item";
	var description as String = "";
	var type as ItemType = CUSTOM; 	
	var slot as ItemSlot = NONE; 
	var value as Number = 0;
	var amount as Number = 1;
	var weight as Number = 1;
	var pos as Point2D = new Point2D(0, 0);
	var equipped as Boolean = false;
	var in_inventory as Boolean = false;

	function initialize();
	function onEquipItem(player as Player) as Void {
		self.equipped = true;
	}
	function onUnequipItem(player as Player) as Void {
		self.equipped = false;
	}
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

	function setAmount(amount as Number) as Void {
		self.amount = amount;
	}

	function isEquipped() as Boolean {
		return equipped;
	}

	function isInInventory() as Boolean {
		return in_inventory;
	}

	function setIsInInventory(in_inventory as Boolean) as Void {
		self.in_inventory = in_inventory;
	}

	function onTurnDone() as Void {}

	function deepcopy() as Item {
		var new_item = new Item();
		new_item.pos = pos;
		new_item.equipped = equipped;
		new_item.in_inventory = in_inventory;
		return new_item;
	}

	function save() as Dictionary<PropertyKeyType, PropertyValueType> {
		var save_data = {};
		save_data["id"] = id;
		save_data["pos"] = pos;
		save_data["equipped"] = equipped;
		save_data["in_inventory"] = in_inventory;
		save_data["amount"] = amount;
		return save_data;
	}

	static function load(save_data as Dictionary<PropertyKeyType, PropertyValueType>) as Item {
		// TODO remove later
		if (save_data["id"] == null) {
			save_data["id"] = 0;
		}
		var item = Items.createItemFromId(save_data["id"]);
		item.onLoad(save_data);
		return item;
	}

	function onLoad(save_data as Dictionary<PropertyKeyType, PropertyValueType>) as Void {
		if (save_data["pos"] != null) {
			pos = Point2D.toPoint2D(save_data["pos"] as Array<Number>);
		}
		if (save_data["equipped"] != null) {
			equipped = save_data["equipped"] as Boolean;
		}
		if (save_data["in_inventory"] != null) {
			in_inventory = save_data["in_inventory"] as Boolean;
		}
		if (save_data["amount"] != null) {
			amount = save_data["amount"] as Number;
		}
	}
}