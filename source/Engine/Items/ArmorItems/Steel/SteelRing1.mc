import Toybox.Lang;


class SteelRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1004;
		name = "Steel Ring";
		description = "A simple steel ring";
		slot = ACCESSORY;
		value = 10;
		weight = 10;
		defense = 0;
		attribute_bonus = {
			:constitution => 2
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		ArmorItem.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		ArmorItem.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		ArmorItem.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		ArmorItem.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		ArmorItem.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		ArmorItem.onBuyItem(player);
	}
	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_ring1;
	}
	

	function deepcopy() as Item {
		var ring = new SteelRing1();
		ring.name = name;
		ring.description = description;
		ring.value = value;
		ring.amount = amount;
		ring.attribute_bonus = attribute_bonus;
		ring.pos = pos;
		ring.equipped = equipped;
		ring.in_inventory = in_inventory;
		ring.defense = defense;
		return ring;
	}

}