import Toybox.Lang;

class Bat extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 1;
		name = "Bat";
		description = "A swift cave bat with sharp fangs.";
		current_health = 25;
		maxHealth = 141;
		armor = 7;
        kill_experience = 40;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_bat;
	}

	function findNextMove(map) as Point2D {
		return Enemy.followPlayerStrafe(map, true);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}