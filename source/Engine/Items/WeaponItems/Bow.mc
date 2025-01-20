import Toybox.Lang;


class Bow extends WeaponItem {

	var ammunition_type as AmmunitionType = ARROW;

	function initialize() {
		WeaponItem.initialize();
	}

	function onEquipItem(player as Player) as Void {
		WeaponItem.onEquipItem(player);
	}
	function onUnequipItem(player as Player) as Void {
		WeaponItem.onUnequipItem(player);
	}

	function onUseItem(player as Player) as Void {
		WeaponItem.onUseItem(player);
	}
	function onPickupItem(player as Player) as Void {
		WeaponItem.onPickupItem(player);
	}

	function onDropItem(player as Player) as Void {
		WeaponItem.onDropItem(player);
	}

	function onSellItem(player as Player) as Void {
		WeaponItem.onSellItem(player);
	}

	function onBuyItem(player as Player) as Void {
		WeaponItem.onBuyItem(player);
	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_bow;
	}

	function canAttack(enemy as Enemy?) as Boolean {
		var player = getApp().getPlayer();
		var ammunition = player.getEquip(AMMUNITION) as Ammunition?;
		return ammunition != null && ammunition.isType(self.ammunition_type);
	}

	function onDamageDone(damage as Number, enemy as Enemy?) as Void {
		var player = getApp().getPlayer();
		var ammunition = player.getEquip(AMMUNITION) as Ammunition?;
		if (ammunition != null) {
			ammunition.amount -= 1;
			if (ammunition.amount <= 0) {
				player.equipped.remove(AMMUNITION);
			}
		}
	}

	function deepcopy() as Item {
		var bow = new Bow();
		bow.name = name;
		bow.description = description;
		bow.value = value;
		bow.amount = amount;
		bow.attribute_bonus = attribute_bonus;
		bow.pos = pos;
		bow.equipped = equipped;
		bow.in_inventory = in_inventory;
		bow.attack = attack;
		bow.range = range;
		return bow;
	}

	function toString() as String {
		return name;
	}

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
	}

}