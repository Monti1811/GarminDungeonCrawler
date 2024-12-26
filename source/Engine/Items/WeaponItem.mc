import Toybox.Lang;


class WeaponItem extends Item {
	var id as Number = 0;
	var name as String = "Weapon";
	var description as String = "";
	var type as ItemType = WEAPON;
	var slot as ItemSlot = RIGHT_HAND;
	var value as Number = 10;
	var weight as Number = 20;
	var attack as Number = 10;

	function initialize() {
		Item.initialize();
	}

	function onEquipItem(player as Player) as Void {
		Item.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		Item.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		Item.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		Item.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		Item.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		Item.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		Item.onBuyItem(player);
	}

	function getAttack() as Number {
		return attack;
	}
	

}