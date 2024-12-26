import Toybox.Lang;

class ConsumableItem extends Item {
	
	function initialize() {
		Item.initialize();
	}

	function onUseItem(player as Player) as Void {
		Item.onUseItem(player);
		player.removeInventoryItem(self);
	}
	
}