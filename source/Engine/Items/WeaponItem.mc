import Toybox.Lang;


enum RangeType {
	DIRECTIONAL,
	SURROUNDING,
	LINEAR
}

class WeaponItem extends EquippableItem {

	var attack as Number = 10;
	var range as Numeric = 1;
	var range_type as RangeType = DIRECTIONAL;
	var weapon_type as WeaponType = MELEE;
	var cooldown as Number = 0;
	var current_cooldown as Number = 0;
	var attack_type as AttackType = STRENGTH;

	function initialize() {
		EquippableItem.initialize();
		type = WEAPON;
		slot = RIGHT_HAND;
	}

	function onEquipItem(player as Player) as Void {
		EquippableItem.onEquipItem(player);
		if (slot == LEFT_HAND) {
			var right_hand = player.getEquip(RIGHT_HAND) as WeaponItem?;
			if (right_hand != null && right_hand.weapon_type == TWOHAND) {
				player.unequipItem(LEFT_HAND);
			}
		}
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

	function canAttack(enemy as Enemy?) as Boolean {
		if (current_cooldown > 0) {
			return false;
		}
		return true;
	}

	function getCooldown() as Number {
		return cooldown;
	}

	function onTurnDone() as Void {
		if (current_cooldown > 0) {
			current_cooldown -= 1;
		}
	}

	function getBaseAttack() as Number {
		return attack;
	}

	function getAttack(enemy as Enemy?, weapons_size as Number) as Number {
		var player = $.getApp().getPlayer();
		var attribute_modifiers = $.Constants.ATTRIBUTE_WEIGHTS[attack_type] as Dictionary<Symbol, Float>;
		var attack = self.attack;
		var attribute_keys = [
			:strength,
			:dexterity,
			:intelligence,
			:constitution,
			:wisdom,
			:charisma,
		];
		for (var i = 0; i < attribute_keys.size(); i++) {
			var attribute = attribute_keys[i] as Symbol;
			var weight = attribute_modifiers[attribute];
			attack += player.getAttribute(attribute) * weight / (2 * weapons_size);
		}

		var luck = player.getAttribute(:luck) * attribute_modifiers[:luck];
		if (enemy != null && MathUtil.random(0, 100) < luck) {
			attack *= 1.25;
		}
		return attack.toNumber();
	}

	function onDamageDone(damage as Number, enemy as Enemy?) as Void {
		current_cooldown = cooldown;
	}

	function getRange() as Number {
		return range;
	}

	function getRangeType() as RangeType {
		return range_type;
	}
	
	function save() as Dictionary {
		var data = EquippableItem.save();
		data["attack"] = attack;
		data["range"] = range;
		data["range_type"] = range_type;
		return data;
	}

}