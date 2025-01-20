import Toybox.Lang;


class ArmorItem extends EquippableItem {

	var defense as Number = 5;

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
	
	function getDefense(enemy as Enemy?) as Number {
		return defense;
	}

}