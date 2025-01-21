import Toybox.Lang;

class Enemy extends Entity {

	var id as Number = 0;

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

	function hashCode() {
		return id;
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

	function getHealthPercent() as Float {
		return current_health.toFloat() / maxHealth.toFloat();
	}

	function takeDamage(damage as Number, enemy as Player) as Boolean {
		current_health -= damage;
		if (current_health < 0) {
			current_health = 0;
			return true;
		}
		return false;
	}

	function getAttack(enemy as Player?) as Number {
		return damage;
	}

	function getDefense(enemy as Player?) as Number {
		return armor;
	}

	function getKillExperience() as Number {
		return kill_experience;
	}

	function getLoot() as Item? {
		if (MathUtil.random(0, 100) < 50) {
			var gold = new Gold();
			gold.amount = MathUtil.random(1, 10);
			return gold;
		}
		return null;
	}

	function findNextMove(map as Array<Array<Tile>>) as Point2D {
		self.next_pos = pos;
		return pos;
	}

	function attackNearbyPlayer(map as Array<Array<Tile>>, player_pos as Point2D) as Boolean {
		if (curr_attack_cooldown > 0) {
			curr_attack_cooldown -= 1;
			return false;
		}
		if (!MathUtil.isPointDirectAdjacent(pos, player_pos)) {
			return false;
		}
		var player = null as Player?;
		if (map[player_pos[0]][player_pos[1]].player) {
			player = getApp().getPlayer();
		}
		if (player != null) {
			Battle.attackPlayer(self, player);
			curr_attack_cooldown = attack_cooldown;
		}
		return true;
	}

	function save() as Dictionary {
		var data = {};
		data["id"] = id;
		data["pos"] = pos;
		data["next_pos"] = next_pos;
		data["has_moved"] = has_moved;
		data["damage"] = damage;
		data["armor"] = armor;
		data["current_health"] = current_health;
		data["maxHealth"] = maxHealth;
		data["kill_experience"] = kill_experience;
		data["name"] = name;
		data["level"] = level;
		data["experience"] = experience;
		data["attack_cooldown"] = attack_cooldown;
		data["curr_attack_cooldown"] = curr_attack_cooldown;
		return data;
	}

	static function load(data as Dictionary) as Enemy {
		// TODO remove that once correct save data is provided
		if (data["id"] == null) {
			data["id"] = 0;
		}
		var enemy = Enemies.createEnemyFromId(data["id"] as Number);
		enemy.onLoad(data);
		return enemy;
		
	}

	function onLoad(data as Dictionary) as Void {
		if (data["pos"] != null) {
			pos = data["pos"] as Point2D;
		}
		if (data["next_pos"] != null) {
			next_pos = data["next_pos"] as Point2D;
		}
		if (data["has_moved"] != null) {
			has_moved = data["has_moved"] as Boolean;
		}
		if (data["damage"] != null) {
			damage = data["damage"] as Number;
		}
		if (data["armor"] != null) {
			armor = data["armor"] as Number;
		}
		if (data["current_health"] != null) {
			current_health = data["current_health"] as Number;
		}
		if (data["maxHealth"] != null) {
			maxHealth = data["maxHealth"] as Number;
		}
		if (data["kill_experience"] != null) {
			kill_experience = data["kill_experience"] as Number;
		}
		if (data["name"] != null) {
			name = data["name"] as String;
		}
		if (data["level"] != null) {
			level = data["level"] as Number;
		}
		if (data["experience"] != null) {
			experience = data["experience"] as Number;
		}
		if (data["attack_cooldown"] != null) {
			attack_cooldown = data["attack_cooldown"] as Number;
		}
		if (data["curr_attack_cooldown"] != null) {
			curr_attack_cooldown = data["curr_attack_cooldown"] as Number;
		}
	}


}