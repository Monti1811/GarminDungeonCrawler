import Toybox.Lang;


class Staff extends WeaponItem {

    var active as Boolean = false;
    var mana_loss as Number = 10;
	
	function initialize() {
		WeaponItem.initialize();
	}

	function activateStaff() as Void {
        active = true;
	}

    function deactivateStaff() as Void {
        active = false;
    }

	function onEquipItem(player as Player) as Void {
		WeaponItem.onEquipItem(player);
        if (!active && player.getCurrentMana() >= mana_loss) {
            activateStaff();
        }
	}
	function onUnequipItem(player as Player) as Void {
		WeaponItem.onUnequipItem(player);
        if (active) {
            deactivateStaff();
        }
	}

	function onDamageDone(damage as Number, enemy as Enemy?) {
		WeaponItem.onDamageDone(damage, enemy);
		var player = $.getApp().getPlayer();
		player.doManaDelta(-mana_loss);
	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_staff;
	}

    function onTurnDone() as Void {
		WeaponItem.onTurnDone();
        var player = $.getApp().getPlayer();
        if (active && player.getCurrentMana() < mana_loss) {
            deactivateStaff();
        } else if (!active && player.getCurrentMana() >= mana_loss) {
			activateStaff();
		}
    }

	function deepcopy() as Item {
		var staff = new SteelStaff();
		staff.name = name;
		staff.description = description;
		staff.value = value;
		staff.amount = amount;
		staff.attribute_bonus = attribute_bonus;
		staff.pos = pos;
		staff.equipped = equipped;
		staff.in_inventory = in_inventory;
		staff.attack = attack;
		staff.range = range;
		return staff;
	}

	function toString() as String {
		return name;
	}

    function save() as Dictionary {
        var data = WeaponItem.save();
        data["active"] = active;
        return data;
    }

	function onLoad(save_data as Dictionary) as Void {
		WeaponItem.onLoad(save_data);
        if (save_data["active"] != null) {
            active = save_data["active"] as Boolean;
            if (active) {
                activateStaff();
            } else {
                deactivateStaff();
            }
        }
	}

}