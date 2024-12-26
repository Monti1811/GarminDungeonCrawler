import Toybox.Lang;

class ConsumableItem extends Item {

	private var effect_description as String = "No effect";
	
	function initialize() {
		Item.initialize();
	}

	function onUseItem(player as Player) as Void {
		Item.onUseItem(player);
		player.removeInventoryItem(self);
	}

	function getEffectDescription() as String {
		return effect_description;
	}
	
}