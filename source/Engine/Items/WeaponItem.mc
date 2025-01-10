import Toybox.Lang;


enum RangeType {
	SURROUNDING,
	LINEAR
}

class WeaponItem extends EquippableItem {
	var id as Number = 0;
	var name as String = "Weapon";
	var description as String = "";
	var type as ItemType = WEAPON;
	var slot as ItemSlot = RIGHT_HAND;
	var value as Number = 10;
	var weight as Number = 20;
	var attack as Number = 10;
	var range as Numeric = 1;
	var range_type as RangeType = SURROUNDING;
	var weapon_type as WeaponType = MELEE;
	var cooldown as Number = 0;
	var current_cooldown as Number = 0;

	function initialize() {
		EquippableItem.initialize();
	}

	function onEquipItem(player as Player) as Void {
		EquippableItem.onEquipItem(player);
		if (slot == LEFT_HAND) {
			var right_hand = player.getEquip(RIGHT_HAND) as WeaponItem?;
			if (right_hand != null && right_hand.weapon_type == TWOHAND) {
				player.unequipItem(RIGHT_HAND);
			}
		} else if (slot == RIGHT_HAND) {
			player.unequipItem(LEFT_HAND);
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

	function getAttack(enemy as Enemy?) as Number {
		return attack;
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