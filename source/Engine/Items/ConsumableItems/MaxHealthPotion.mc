import Toybox.Lang;


class MaxHealthPotion extends ConsumableItem {

	function initialize() {
		ConsumableItem.initialize();
		self.id = 2004;
		self.name = "Max Health Potion";
		self.description = "An enormous health potion";
		self.effect_description = "Restores all health";
		self.value = 200;
		self.weight = 1;
	}

	function onUseItem(player as Player) as Void {
		ConsumableItem.onUseItem(player);
		player.onGainHealth(player.getMaxHealth());
	}
	function onPickupItem(player as Player) as Void {
		ConsumableItem.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		ConsumableItem.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		ConsumableItem.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		ConsumableItem.onBuyItem(player);
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.potion_health_max;
	}
	

	function deepcopy() as Item {
		var potion = new MaxHealthPotion();
		potion.name = name;
		potion.description = description;
		potion.value = value;
		potion.amount = amount;
		potion.pos = pos;
		potion.equipped = equipped;
		potion.in_inventory = in_inventory;
		return potion;
	}

}