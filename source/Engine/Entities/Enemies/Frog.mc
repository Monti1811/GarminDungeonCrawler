import Toybox.Lang;

class Frog extends Enemy {

	private var move_up = false;

	var name as String = "Frog";

	function initialize() {
		Enemy.initialize();
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.Frog;
	}

	function findNextMove(map as Array<Array<Object?>>) as Point2D {
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
}