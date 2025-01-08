import Toybox.Lang;

class Enemy extends Entity {

	var pos as Point2D = [0, 0];
	var next_pos as Point2D = [0, 0];
	var has_moved as Boolean = false;

	var damage as Number = 10;
	var armor as Number = 0;
	var current_health as Number = 100;
	var maxHealth as Number = 100;
	var kill_experience as Number = 10;
	var name as String = "Enemy";
	var level as Number = 1;
	var experience as Number = 0;

	var attack_cooldown as Number = 2;
	var curr_attack_cooldown as Number = 0;

	function initialize() {
		Entity.initialize();
	}

	function setLevel(level as Number) as Void {
		self.level = level;
		self.maxHealth = 100 * level;
		self.current_health = self.maxHealth;
		self.damage = 10 * level/2;
		self.armor = 5 * level/2;
	}

	function getPos() as Point2D {
		return pos;
	}

	function setPos(pos as Point2D) as Void {
		self.pos = pos;
	}

	function getNextPos() as Point2D {
		return next_pos;
	}

	function getHasMoved() as Boolean {
		return has_moved;
	}

	function setHasMoved(has_moved as Boolean) as Void {
		self.has_moved = has_moved;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.LauncherIcon;
	}

	function takeDamage(damage as Number) as Boolean {
		current_health -= damage;
		if (current_health < 0) {
			current_health = 0;
			return true;
		}
		return false;
	}

	function getAttack() as Number {
		return damage;
	}

	function getDefense() as Number {
		return armor;
	}

	function getKillExperience() as Number {
		return kill_experience;
	}

	function getLoot() as Item? {
		return null;
	}

	function findNextMove(map as Array<Array<Object?>>) as Point2D {
		self.next_pos = pos;
		return pos;
	}

	function attackNearbyPlayer(view as DCGameView, map as Array<Array<Object?>>, player_pos as Point2D) as Boolean {
		if (curr_attack_cooldown > 0) {
			curr_attack_cooldown -= 1;
			return false;
		}
		if (!MathUtil.isPointDirectAdjacent(pos, player_pos)) {
			return false;
		}
		var player = map[player_pos[0]][player_pos[1]] as Player?;
		if (player != null) {
			Battle.attackPlayer(view, self, player, player_pos);
			curr_attack_cooldown = attack_cooldown;
		}
		return true;
	}

	static function onLoad(data as Dictionary) as Enemy {
		var enemy = new Enemy();
		enemy.pos = data["pos"] as Point2D;
		enemy.next_pos = data["next_pos"] as Point2D;
		enemy.has_moved = data["has_moved"] as Boolean;
		enemy.damage = data["damage"] as Number;
		enemy.armor = data["armor"] as Number;
		enemy.current_health = data["current_health"] as Number;
		enemy.maxHealth = data["maxHealth"] as Number;
		enemy.kill_experience = data["kill_experience"] as Number;
		enemy.name = data["name"] as String;
		enemy.level = data["level"] as Number;
		enemy.experience = data["experience"] as Number;
		enemy.attack_cooldown = data["attack_cooldown"] as Number;
		enemy.curr_attack_cooldown = data["curr_attack_cooldown"] as Number;
		return enemy;
		
	}


}