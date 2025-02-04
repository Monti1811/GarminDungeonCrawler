import Toybox.Lang;

class Inventory {
	private var items as Dictionary<Number, Item>;
	private var current_weight as Numeric = 0;
	private var base_max_weight as Numeric;
	private var max_weight as Numeric;
	private var permanent_increased_weight as Numeric = 0;

	function initialize(max_weight as Numeric) {
		self.items = {};
		self.base_max_weight = max_weight;
		self.max_weight = max_weight;
	}

	function add(item as Item) as Boolean {
		var item_weight = item.weight * item.amount;
		if (current_weight < max_weight 
				&& (current_weight + item_weight <= max_weight)) {
			var existing_item = items[item.id];
			if (existing_item != null) {
				existing_item.amount += item.amount;
			} else {
				item.setIsInInventory(true);
				items[item.id] = item;	
			}
			current_weight += item_weight;
			return true;
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
			current_weight -= item.weight;
			var new_item = item.deepcopy();
			new_item.setIsInInventory(false);
			new_item.amount = 1;
			return new_item;
		}
		return null;
	}

	function removeMultiple(item as Item, amount as Number) as Item? {
		var existing_item = items[item.id];
		if (existing_item != null) {
			var dropped_amount = MathUtil.min(amount, existing_item.amount);
			existing_item.amount -= dropped_amount;
			if (existing_item.amount <= 0) {
				items.remove(item.id);
			}
			current_weight -= item.weight * dropped_amount;
			var new_item = item.deepcopy();
			new_item.setIsInInventory(false);
			new_item.amount = dropped_amount;
			return new_item;
		}
		return null;
	}

	function getItems() as Array<Item> {
		var item_list = items.values() as Array<Item>;
		return item_list;
	}

	function isFull() as Boolean {
		return current_weight >= max_weight;
	}

	function wouldBeFull(item as Item) as Boolean {
		return current_weight + item.weight * item.amount > max_weight;
	}

	function addWeight(amount as Numeric) as Boolean {
		if (current_weight + amount <= max_weight) {
			current_weight += amount;
			return true;
		}
		return false;
	}

	function removeWeight(amount as Numeric) as Boolean {
		if (current_weight - amount >= 0) {
			current_weight -= amount;
			return true;
		}
		return false;
	}

	function getCurrentItemWeight() as Numeric {
		return current_weight;
	}

	function getMaxItemWeight() as Numeric {
		return max_weight;
	}

	function addPermanentBonusWeight(amount as Numeric) as Void {
		permanent_increased_weight += amount;
		max_weight += amount;
	}

	function removePermanentBonusWeight(amount as Numeric) as Void {
		permanent_increased_weight -= amount;
		max_weight -= amount;
		if (max_weight < 0) {
			max_weight = 0;
		}
	}

	function increaseWeight(amount as Numeric) as Void {
		max_weight += amount;
	}

	function decreaseWeight(amount as Numeric) as Void {
		max_weight -= amount;
		if (max_weight < 0) {
			max_weight = 0;
		}
	}

	function save() as Dictionary {
		var save_data = {};
		save_data["permanent_increased_weight"] = permanent_increased_weight;
		save_data["base_max_weight"] = base_max_weight;
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
		var base_max_weight = save_data["base_max_weight"] as Numeric;
		if (base_max_weight == null) {
			base_max_weight = 30;
		}
		var inventory = new Inventory(base_max_weight);
		inventory.onLoad(save_data);
		return inventory;
	}

	function onLoad(save_data as Dictionary) as Void {
		if (save_data["permanent_increased_weight"] != null) {
			self.permanent_increased_weight = save_data["permanent_increased_weight"] as Number;
			self.max_weight += permanent_increased_weight;
		}
		var item_list = save_data["items"] as Array<Dictionary>;
		for (var i = 0; i < item_list.size(); i++) {
			var item = Item.load(item_list[i]);
			if (item != null) {
				items[item.id] = item;
				current_weight += item.weight * item.amount;
			}
		}
	}

}