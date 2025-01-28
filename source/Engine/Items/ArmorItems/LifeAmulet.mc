import Toybox.Lang;

class LifeAmulet extends ArmorItem {
	
	function initialize() {
		ArmorItem.initialize();
		id = 1008;
		name = "Life Amulet";
		description = "An amulet that revives the wearer if equipped.";
		value = 100;
		weight = 0.5;
		slot = ACCESSORY;
		attribute_bonus = {
			:constitution => 1
		};

		defense = 0;

	}

	function onDeath(player as Player) as Void {
		player.onGainHealth(player.getMaxHealth() / 2);
		player.equipped.remove(ACCESSORY);
		WatchUi.showToast("Revived by the Life Amulet!", {:icon=>$.Rez.Drawables.aboutToastIcon});
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.life_amulet;
	}

	function deepcopy() as Item {
		var amulet = new LifeAmulet();
		return amulet;
	}
}