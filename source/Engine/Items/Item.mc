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
	var weight as Numeric = 1;
	var pos as Point2D = [0, 0];
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
	function onPickupItem(player as Player) as Void {
		var text = "Picked up" + (amount > 1 ? " x" + amount : "") + " " + name + ".";
		WatchUi.showToast(text, {:icon=>self.getSprite()});
		$.Log.log(text);
	}
	function onDropItem(player as Player) as Void;
	function onSellItem(player as Player) as Void;
	function onBuyItem(player as Player) as Void;

	function onInteract(player as Player, room as Room) as Boolean {
		var success = player.pickupItem(self);
		if (success) {
			room.removeItem(self);
		}
		return success;
	}

	function hashCode() {
		return id;
	}

	function isSameItem(item as Item) as Boolean {
		return item.id == id;
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

	function getSpriteRef() as Toybox.Graphics.BitmapReference {
		return $.Toybox.WatchUi.loadResource(getSprite());
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

	function isItemSlot(slot as ItemSlot) as Boolean {
		if (slot == EITHER_HAND) {
			return self.slot == RIGHT_HAND || self.slot == LEFT_HAND;
		}
		return self.slot == slot;
	}

	function getValue() as Number {
		return value;
	}

	function getSellValue() as Number {
		return value / 4;
	}
	
	function getAmount() as Number {
		return amount;
	}

	function setAmount(amount as Number) as Void {
		self.amount = amount;
	}

	function addAmount(amount as Number) as Void {
		self.amount += amount;
	}

	function isEquipped() as Boolean {
		return equipped;
	}

	function isInInventory() as Boolean {
		return in_inventory;
	}

	function getWeight() as String {
		return weight.format("%.2f");
	}

	function setIsInInventory(in_inventory as Boolean) as Void {
		self.in_inventory = in_inventory;
	}

	function getSpriteOffset() as Point2D {
		return [0, 0];
	}

	function onTurnDone() as Void {}

	function deepcopy() as Item {
		var new_item = new Item();
		new_item.pos = pos;
		new_item.equipped = equipped;
		new_item.in_inventory = in_inventory;
		return new_item;
	}

	function save() as Dictionary {
		var save_data = {};
		save_data["id"] = id;
		save_data["pos"] = pos;
		save_data["equipped"] = equipped;
		save_data["in_inventory"] = in_inventory;
		save_data["amount"] = amount;
		return save_data;
	}

	static function load(save_data as Dictionary) as Item? {
		// TODO remove later
		if (save_data["id"] == null) {
			save_data["id"] = 0;
		}
		var item = Items.createItemFromId(save_data["id"]);
		if (item == null) {
			return null;
		}
		item.onLoad(save_data);
		return item;
	}

	function onLoad(save_data as Dictionary) as Void {
		if (save_data["pos"] != null) {
			pos = save_data["pos"] as Point2D;
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