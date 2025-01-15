import Toybox.Lang;

class Demon extends Enemy {

	var name as String = "Demon";

	function initialize() {
		Enemy.initialize();
        id = 2;
        attack_cooldown = 0;
        damage = 25;
        armor = 10;
        current_health = 250;
        maxHealth = 250;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_demon;
	}

	function getSpriteOffset() as Point2D {
		return [8, 16];
	}

	function findNextMove(map as Array<Array<Tile>>) as Point2D {
		var next_pos = Pathfinder.findSimplePathToPos(map, pos, $.getApp().getPlayer().getPos());
		if (next_pos != null) {
            Toybox.System.println("Demon moving to " + next_pos);
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