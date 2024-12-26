import Toybox.Lang;


class Axe extends WeaponItem {
	var id as Number = 0;
	var name as String = "Axe";
	var description as String = "A simple axe";
	var slot as ItemSlot = RIGHT_HAND;
	var value as Number = 10;
	var weight as Number = 10;

	function initialize() {
		WeaponItem.initialize();
		attack = 10;
	}

	function onEquipItem(player as Player) as Void {
		Item.onUseItem(player);
		player.addToAttribute(:strength, 2);
	}
	function onUnequipItem(player as Player) as Void {
		Item.onUnequipItem(player);
		player.removeFromAttribute(:strength, 2);
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
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.Axe;
	}

}