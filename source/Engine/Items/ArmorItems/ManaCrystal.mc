import Toybox.Lang;

class ManaCrystal extends ArmorItem {

	var remaining_mana as Number = 200;
	
	function initialize() {
		ArmorItem.initialize();
		id = 1301;
		name = "Mana Crystal";
		description = "Restores mana when equipped, will break after some time.";
		value = 100;
		weight = 0.5;
		slot = ACCESSORY;
		attribute_bonus = {
			:constitution => 1
		};

		defense = 0;

	}

	function onTurnDone() as Void {
		var player = $.getApp().getPlayer();
		var diff = player.getMaxMana() - player.getCurrentMana();
		if (diff > 0) {
			player.doManaDelta(1);
			remaining_mana -= 1;
			if (remaining_mana <= 0) {
				player.equipped.remove(ACCESSORY);
				WatchUi.showToast("Your Mana Crystal has shattered!", {:icon=>$.Rez.Drawables.aboutToastIcon});
			}
		}
	}


	function getSprite() as ResourceId {
		return $.Rez.Drawables.mana_crystal;
	}

	function save() as Dictionary {
		var data = ArmorItem.save();
		data["remaining_mana"] = remaining_mana;
		return data;
	}

	function onLoad(save_data as Dictionary) as Void {
		ArmorItem.onLoad(save_data);
		remaining_mana = save_data["remaining_mana"];
	}

	function deepcopy() as Item {
		var crystal = new ManaCrystal();
		return crystal;
	}
}