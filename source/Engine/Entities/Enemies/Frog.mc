import Toybox.Lang;

class Frog extends Enemy {

	private var move_up = false;

	function initialize() {
		Enemy.initialize();
		id = 0;
		name = "Frog";
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.Frog;
	}

	function findNextMove(map as Array<Array<Tile>>) as Point2D {
		var direction = move_up ? -1 : 1;
		var new_pos = [pos[0], pos[1] + direction];
		
		if (MapUtil.canMoveToPoint(map, new_pos)) {
			move_up = !move_up;
			self.next_pos = new_pos;
			return new_pos;
		}

		self.next_pos = pos;
		return pos;
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
		if (save_data["move_up"] != null) {
			move_up = save_data["move_up"] as Boolean;
		}
	}
}