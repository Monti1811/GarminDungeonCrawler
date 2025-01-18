import Toybox.Lang;


class ManaPotion extends ConsumableItem {
	var id as Number = 2001;
	var name as String = "Mana Potion";
	var description as String = "A simple mana potion";
	var effect_description as String = "Restores 20 mana";
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
		return $.Rez.Drawables.potion_mana;
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