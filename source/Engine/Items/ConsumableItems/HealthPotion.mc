import Toybox.Lang;


class HealthPotion extends ConsumableItem {
	var id as Number = 2000;
	var name as String = "Health Potion";
	var description as String = "A simple health potion";
	var effect_description as String = "Restores 20 health";
	var value as Number = 20;
	var weight as Number = 1;

	function initialize() {
		ConsumableItem.initialize();
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
		var ring = new SteelRing1();
		ring.name = name;
		ring.description = description;
		ring.value = value;
		ring.amount = amount;
		ring.pos = pos;
		ring.equipped = equipped;
		ring.in_inventory = in_inventory;
		return ring;
	}

}