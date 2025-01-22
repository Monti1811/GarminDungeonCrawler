import Toybox.Lang;


class ManaPotion extends ConsumableItem {

	function initialize() {
		ConsumableItem.initialize();
		id = 2001;
		name = "Mana Potion";
		description = "A small mana potion";
		effect_description = "Restores 20 mana";
		value = 20;
		weight = 1;
	}

	function onUseItem(player as Player) as Void {
		ConsumableItem.onUseItem(player);
		player.doManaDelta(20);
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
		var potion = new ManaPotion();
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