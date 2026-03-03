import Toybox.Lang;

class Frog extends Enemy {

	private var move_up = false;

	function initialize() {
		Enemy.initialize();
		id = 0;
		name = "Frog";
		energy_per_turn = 50; // every 2 turns
		damage = 10;
		current_health = 35;
		maxHealth = current_health;
		armor = 0;
        kill_experience = 10;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.Frog;
	}

	function getPassablePosOrOpposite(map as Map, direction as Number) as Point2D {
		var preferred_pos = [pos[0], pos[1] + direction];
		if (MapUtil.canMoveToPoint(map, preferred_pos)) {
			return preferred_pos;
		}

		var opposite_pos = [pos[0], pos[1] - direction];
		if (MapUtil.canMoveToPoint(map, opposite_pos)) {
			return opposite_pos;
		}

		return pos;
	}

	function findNextMove(map as Map) as Point2D {
		var direction = move_up ? -1 : 1;
		var new_pos = getPassablePosOrOpposite(map, direction);
		self.next_pos = new_pos;
		return new_pos;
	}

	function onTurnDone() as Void {
		if (has_moved) {
			move_up = !move_up;
		}
		Enemy.onTurnDone();
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
		if (save_data["move_up"] != null) {
			move_up = save_data["move_up"] as Boolean;
		}
	}
}