import Toybox.Lang;


class Helmet extends ArmorItem {
	var id as Number = 1000;
	var name as String = "Helmet";
	var slot as ItemSlot = HEAD;
	var description as String = "A simple helmet";
	var value as Number = 10;
	var weight as Number = 10;

	function initialize() {
		ArmorItem.initialize();
	}

	function onEquipItem(player as Player) as Void {
		Item.onUseItem(player);
		player.addToAttribute(:constitution, 2);
	}
	function onUnequipItem(player as Player) as Void {
		ArmorItem.onUnequipItem(player);
		player.removeFromAttribute(:constitution, 2);
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
		return $.Rez.Drawables.Helmet;
	}
	

}