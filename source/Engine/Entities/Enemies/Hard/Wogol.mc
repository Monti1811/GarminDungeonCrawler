import Toybox.Lang;

class Wogol extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 9;
		name = "Wogol";
		damage = 60;
		current_health = 250;
		maxHealth = 250;
		armor = 15;
        kill_experience = 250;
		energy_per_turn = 50;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_wogol;
	}

	function findNextMove(map) as Point2D {
		if (Enemy.canUseTeleportMove()) {
			return Enemy.followPlayerTeleportBehind(map);
		}
		return Enemy.followPlayerFlankSafe(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}