import Toybox.Lang;


class ArmorItem extends EquippableItem {

	var defense as Number = 5;
	var defense_type as DefenseType = CONSTITUTION;

	function initialize() {
		EquippableItem.initialize();
		type = ARMOR;
		slot = CHEST;
	}

	function onEquipItem(player as Player) as Void {
		EquippableItem.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		EquippableItem.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		EquippableItem.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		EquippableItem.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		EquippableItem.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		EquippableItem.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		EquippableItem.onBuyItem(player);
	}

	function getBaseDefense() as Number {
		return defense;
	}

	function getDefense(enemy as Enemy?, armors_size as Number) as Number {
		var player = $.getApp().getPlayer();
		var attribute_modifiers = $.Constants.ATTRIBUTE_WEIGHTS[defense_type] as Dictionary<Symbol, Float>;
		var defense = self.defense;
		var attribute_keys = [
			:strength,
			:dexterity,
			:intelligence,
			:constitution,
			:wisdom,
			:charisma,
		];
		if (defense == 0) {
			return 0;
		}
		for (var i = 0; i < attribute_keys.size(); i++) {
			var attribute = attribute_keys[i] as Symbol;
			var weight = attribute_modifiers[attribute];
			defense += player.getAttribute(attribute) * weight / (4 * armors_size);
		}

		var luck = player.getAttribute(:luck) * attribute_modifiers[:luck];
		if (enemy != null && MathUtil.random(0, 100) < luck) {
			defense *= 1.25;
		}
		return defense.toNumber();
	}

}