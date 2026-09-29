import Toybox.Lang;

class EquippableItem extends Item {
	
	var attribute_bonus as Dictionary<Symbol, Number> = {};
	var upgrade_level as Number = 0;

	function initialize() {
		Item.initialize();
	}

	function getUpgradeLevel() as Number {
		return upgrade_level;
	}

	function canUpgrade() as Boolean {
		return upgrade_level < $.Constants.UPGRADE_MAX_LEVEL;
	}

	function getName() as String {
		if (upgrade_level > 0) {
			return name + " +" + upgrade_level;
		}
		return name;
	}

	function getValue() as Number {
		return (value * (1.0 + upgrade_level * $.Constants.UPGRADE_VALUE_BONUS)).toNumber();
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		Item.onEquipItem(player, slot);
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		for (var i = 0; i < bonus_keys.size(); i++) {
			var symbol = bonus_keys[i];
			player.addToAttribute(symbol, attribute_bonus[symbol]);
		}
	}

	function onUnequipItem(player as Player) as Void {
		Item.onUnequipItem(player);
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		for (var i = 0; i < bonus_keys.size(); i++) {
			var symbol = bonus_keys[i];
			player.removeFromAttribute(symbol, attribute_bonus[symbol]);
		}
	}

	function onPickupItem(player as Player) as Void {
		Item.onPickupItem(player);
	}

	function getAttributeBonus(slot as Symbol) as Number {
		var res = attribute_bonus[slot];
		if (res == null) {
			return 0;
		}
		return res;
	}

	function getAllAttributeBonuses() as Dictionary<Symbol, Number> {
		return attribute_bonus;
	}
	
	function deepcopy() as Item {
		var item = Items.createItemFromId(id);
		if (item == null) {
			item = new EquippableItem();
			item.id = id;
			item.name = name;
			item.description = description;
			item.slot = slot;
			item.value = value;
			item.weight = weight;
		}
		if (item instanceof EquippableItem) {
			(item as EquippableItem).upgrade_level = upgrade_level;
			var new_bonus = {} as Dictionary<Symbol, Number>;
			var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
			for (var i = 0; i < bonus_keys.size(); i++) {
				new_bonus[bonus_keys[i]] = attribute_bonus[bonus_keys[i]];
			}
			(item as EquippableItem).attribute_bonus = new_bonus;
		}
		item.pos = pos;
		item.equipped = equipped;
		item.in_inventory = in_inventory;
		return item;
	}

	function save() as Dictionary {
		var data = Item.save();
		data["upgrade_level"] = upgrade_level;
		return data;
	}

	function onLoad(save_data as Dictionary) as Void {
		Item.onLoad(save_data);
		if (save_data["upgrade_level"] != null) {
			upgrade_level = save_data["upgrade_level"] as Number;
		}
	}

}