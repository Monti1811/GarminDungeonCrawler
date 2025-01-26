import Toybox.Lang;


class GreaterManaPotion extends ConsumableItem {

	function initialize() {
		ConsumableItem.initialize();
		id = 2003;
		name = "Mana Potion";
		description = "A greater mana potion";
		effect_description = "Restores 80 mana";
		value = 80;
		weight = 0.5;
	}

	function onUseItem(player as Player) as Void {
		ConsumableItem.onUseItem(player);
		player.doManaDelta(80);
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
		return $.Rez.Drawables.potion_mana_greater;
	}
	

	function deepcopy() as Item {
		var potion = new GreaterManaPotion();
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