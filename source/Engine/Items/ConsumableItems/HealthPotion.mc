import Toybox.Lang;


class HealthPotion extends ConsumableItem {

	function initialize() {
		ConsumableItem.initialize();
		self.id = 2000;
		self.name = "Health Potion";
		self.description = "A small health potion";
		self.effect_description = "Restores 20 health";
		self.value = 20;
		self.weight = 0.1;
	}

	function onUseItem(player as Player) as Void {
		ConsumableItem.onUseItem(player);
		player.onGainHealth(20);
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
		return $.Rez.Drawables.potion_health;
	}
	

	function deepcopy() as Item {
		var potion = new HealthPotion();
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