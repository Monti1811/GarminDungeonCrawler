import Toybox.Lang;

class Bat extends Enemy {

	var name as String = "Bat";

	function initialize() {
		Enemy.initialize();
		id = 1;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_bat;
	}

	function findNextMove(map as Array<Array<Object?>>) as Point2D {
		var next_pos = Pathfinder.findSimplePathToPos(map, pos, $.getApp().getPlayer().getPos());
		if (next_pos != null) {
			Toybox.System.println("Bat moving to " + next_pos);
			self.next_pos = next_pos;
			return next_pos;
		}
		self.next_pos = self.pos;
		return self.next_pos;
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}