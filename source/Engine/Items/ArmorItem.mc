import Toybox.Lang;


class ArmorItem extends Item {
	var type as ItemType = ARMOR;
	var slot as ItemSlot = CHEST;
	var defense as Number = 5;

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
	
	function getDefense() as Number {
		return defense;
	}
}