import Toybox.Lang;

class EquippableItem extends Item {
	
	var attribute_bonus as Dictionary<Symbol, Number> = {};

	function initialize() {
		Item.initialize();
	}

	function onEquipItem(player as Player) as Void {
		Item.onEquipItem(player);
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

	function getAttributeBonus(slot as Symbol) as Number {
		return attribute_bonus[slot];
	}

	function getAllAttributeBonuses() as Dictionary<Symbol, Number> {
		return attribute_bonus;
	}
	
	function deepcopy() as Item {
		var item = new EquippableItem();
		item.id = id;
		item.name = name;
		item.description = description;
		item.slot = slot;
		item.value = value;
		item.weight = weight;
		item.attribute_bonus = attribute_bonus;
		return item;
	}

}