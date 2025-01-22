import Toybox.Lang;


class GreaterHealthPotion extends ConsumableItem {

	function initialize() {
		ConsumableItem.initialize();
		self.id = 2002;
		self.name = "Greater Health Potion";
		self.description = "A big health potion";
		self.effect_description = "Restores 80 health";
		self.value = 80;
		self.weight = 1;
	}

	function onUseItem(player as Player) as Void {
		ConsumableItem.onUseItem(player);
		player.onGainHealth(80);
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
		return $.Rez.Drawables.potion_health_greater;
	}
	

	function deepcopy() as Item {
		var potion = new GreaterHealthPotion();
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