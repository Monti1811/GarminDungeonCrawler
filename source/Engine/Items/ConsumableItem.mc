import Toybox.Lang;

class ConsumableItem extends Item {

	var effect_description as String = "No effect";
	
	function initialize() {
		Item.initialize();
		type = CONSUMABLE;
	}

	function onUseItem(player as Player) as Void {
		Item.onUseItem(player);
		player.removeInventoryItem(self);
	}

	function getEffectDescription() as String {
		return self.effect_description;
	}
	
}