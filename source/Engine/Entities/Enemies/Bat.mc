import Toybox.Lang;

class Bat extends Enemy {

	var name as String = "Bat";

	function initialize() {
		Enemy.initialize();
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_bat;
	}

	function findNextMove(map as Array<Array<Object?>>) as Point2D {
		var next_pos = Pathfinder.findNextMove(map, pos, $.getApp().getPlayer().getPos());
		if (next_pos != null) {
			return next_pos;
		}
		return pos;
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}