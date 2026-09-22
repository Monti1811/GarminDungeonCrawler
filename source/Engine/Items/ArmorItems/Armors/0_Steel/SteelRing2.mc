import Toybox.Lang;


class SteelRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1005;
		name = "Amethyst Ring";
		description = "An amethyst-set ring radiating faint arcane energy.";
		value = 5;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 1;
		attribute_bonus = {
			:intelligence => 3,
			:wisdom => 2
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
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
		return $.Rez.Drawables.steel_ring2;
	}
	

	function deepcopy() as Item {
		var ring = new SteelRing2();
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