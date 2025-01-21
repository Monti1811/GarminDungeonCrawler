import Toybox.Lang;


class Spell extends WeaponItem {

	var active as Boolean = false;
    var mana_loss as Number = 5;
	
	function initialize() {
		WeaponItem.initialize();
	}

	function activateSpell() as Void {
        active = true;
	}

    function deactivateSpell() as Void {
        active = false;
    }

	function onEquipItem(player as Player) as Void {
		WeaponItem.onEquipItem(player);
        if (!active && player.getCurrentMana() >= mana_loss) {
            activateSpell();
        }
	}
	function onUnequipItem(player as Player) as Void {
		WeaponItem.onUnequipItem(player);
        if (active) {
            deactivateSpell();
        }
	}

	function onTurnDone() as Void {
		WeaponItem.onTurnDone();
        var player = $.getApp().getPlayer();
        if (active && player.getCurrentMana() < mana_loss) {
            deactivateSpell();
        } else if (!active && player.getCurrentMana() >= mana_loss) {
			activateSpell();
		}
    }

	function onDamageDone(damage as Number, enemy as Enemy?) {
		WeaponItem.onDamageDone(damage, enemy);
		var player = $.getApp().getPlayer();
		player.doManaDelta(-mana_loss);
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
                activateSpell();
            } else {
                deactivateSpell();
            }
        }
	}

}