import Toybox.Lang;

class Inventory {
	private var items as Dictionary<Number, Item>;
	private var current_items as Number = 0;
	private var max_items as Number;

	function initialize(max_items as Number) {
		self.items = {};
		self.max_items = max_items;
	}

	function add(item as Item) as Boolean {
		if (items.size() < max_items) {
			var existing_item = items[item.id];
			if (existing_item != null) {
				existing_item.amount += item.amount;
				current_items += item.amount;
				return true;
			} else {
				item.setIsInInventory(true);
				items[item.id] = item;
				current_items += item.amount;
				return true;
			}
		}
		return false;
	}

	function remove(item as Item) as Item? {
		var existing_item = items[item.id];
		if (existing_item != null) {
			existing_item.amount -= 1;
			if (existing_item.amount <= 0) {
				items.remove(item.id);
			}
			var new_item = item.deepcopy();
			new_item.setIsInInventory(false);
			new_item.amount = 1;
			return new_item;
		}
		return null;
	}

	function getItems() as Array<Item> {
		var item_list = items.values() as Array<Item>;
		return item_list;
	}

	function isFull() as Boolean {
		return current_items >= max_items;
	}

	function save() as Dictionary {
		var save_data = {};
		save_data["max_items"] = max_items;
		save_data["current_items"] = current_items;
		save_data["items"] = saveItems();
		return save_data;
	}

	function saveItems() as Array<Dictionary> {
		var item_list = items.values() as Array<Item>;
		var save_data = new Array<Dictionary>[item_list.size()];
		for (var i = 0; i < item_list.size(); i++) {
			save_data[i] = item_list[i].save();
		}
		return save_data;
	}

	static function load(save_data as Dictionary) as Inventory {
		var max_items = save_data["max_items"] as Number;
		if (max_items == null) {
			max_items = 10;
		}
		var inventory = new Inventory(save_data["max_items"]);
		inventory.onLoad(save_data);
		return inventory;
	}

	function onLoad(save_data as Dictionary) as Void {
		if (save_data["current_items"] != null) {
			self.current_items = save_data["current_items"] as Number;
		}
		var item_list = save_data["items"] as Array<Dictionary>;
		for (var i = 0; i < item_list.size(); i++) {
			var item = Item.load(item_list[i]);
			items[item.id] = item;
		}
	}

}