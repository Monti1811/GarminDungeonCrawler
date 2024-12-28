import Toybox.Lang;


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

	function initialize() {
		EquippableItem.initialize();
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

	function getAttack() as Number {
		return attack;
	}

	function getRange() as Number {
		return range;
	}
	

}