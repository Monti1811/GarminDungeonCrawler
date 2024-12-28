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

}