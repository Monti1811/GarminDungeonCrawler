import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
}

enum GameMode {
	NORMAL,
	HARDMODE,
}

enum GameFlag {
	HAS_STAIRS,
	HAS_MERCHANT,
	HAS_BOSS,
	HAS_QUEST_GIVER,
}

module Game {
	const FLAG_SLOTS as Number = 4;
	var difficulty as Difficulty = MEDIUM;
	var game_mode as GameMode = NORMAL;
	var player as Player?;
	var dungeon as Dungeon?;
	var depth as Number = 0;
	var time_played as Number = 0;
	var time_started as Time.Moment?;
	var turns as Turn?;
	// Room name, connections, size, visited
	var map as Array<Array<[
		String, 							// Room name
		Dictionary<WalkDirection, Boolean>, // Connections
		Point2D, 							// Size of room
		Boolean, 							// Visited
		Array<Point2D?>]>> = []; 			// Special flags 
		// [0] = Has stairs
		// [1] = Has merchant
		// [2] = Has boss
		// [3] = Has quest giver

	function init(player_id as Number) as Void {
		// Set the seed for random number generation
		Math.srand(Time.now().value());
		self.initModules(player_id);
		Quests.init();
		player = null;
		dungeon = null;
		turns = null;
		time_played = 0;
		depth = 0;
		difficulty = MEDIUM;
		game_mode = NORMAL;
		map = [];
	}

	function initModules(player_id as Number) as Void {
		EntityManager.init();
		Items.init(player_id);
		Enemies.init(player_id);
	}

	function initMap(x as Number, y as Number) as Void {
		map = new [x];
		for (var i = 0; i < x; i++) {
			map[i] = new [y];
		}
	}

	function save() as Dictionary {
		return {
			"difficulty" => difficulty,
			"game_mode" => game_mode,
			"depth" => depth,
			"time_played" => time_played,
			"map" => map,
		};
	}

	function load(data as Dictionary?) {
		if (data == null) {
			return;
		}
		difficulty = data["difficulty"];
		game_mode = data["game_mode"];
		if (data["depth"] != null) {
			depth = data["depth"];
		}
		if (data["time_played"] != null) {
			time_played = data["time_played"];
		}
		if (data["map"] != null) {
			map = data["map"];
			normalizeFlags();
		}
	}

	function addRoomToMap(pos as Point2D, room_name as String, connections as Dictionary<WalkDirection, Boolean>, size as Point2D) as Void {
		map[pos[0]][pos[1]] = [room_name, connections, size, false, createEmptyFlags()];
	}

	function setRoomAsVisited(pos as Point2D) as Void {
		map[pos[0]][pos[1]][3] = true;
	}

	function setRoomWithFlag(pos as Point2D, flag as GameFlag, pos_flag as Point2D) as Void {
		var flags = map[pos[0]][pos[1]][4] as Array<Point2D?>;
		while (flags.size() < FLAG_SLOTS) {
			flags.add(null);
		}
		flags[flag] = pos_flag;
		map[pos[0]][pos[1]][4] = flags;
	}

	function addToDepth(amount as Number) as Void {
		depth += amount;
	}

	function getTimePlayed() as Number {
		return time_played;
	}

	function setTimePlayed(time as Number) as Void {
		time_played = time;
	}

	function addToTimePlayed(time as Number) as Void {
		time_played += time;
	}
	
	function setTimeStarted(time as Time.Moment) as Void {
		time_started = time;
	}

	function updateTimePlayed(time as Time.Moment) as Void {
		Toybox.System.println("Time started: " + time_started.value());
		Toybox.System.println("Time ended: " + time.value());
		var diff = time.subtract(time_started);
		time_played += diff.value();
		time_started = time;
	}

	function createEmptyFlags() as Array<Point2D?> {
		var flags = [] as Array<Point2D?>;
		for (var i = 0; i < FLAG_SLOTS; i++) {
			flags.add(null);
		}
		return flags;
	}

	function normalizeFlags() as Void {
		for (var i = 0; i < map.size(); i++) {
			for (var j = 0; j < map[i].size(); j++) {
				var room = map[i][j];
				var flags = room[4] as Array<Point2D?>?;
				if (flags == null) {
					flags = createEmptyFlags();
				} else {
					while (flags.size() < FLAG_SLOTS) {
						flags.add(null);
					}
				}
				room[4] = flags;
			}
		}
	}

	// Centralized accessors for dungeon/room state
	function getCurrentRoom() as Room {
		if (dungeon == null) {
			throw new Lang.Exception();
		}
		return dungeon.getCurrentRoom();
	}

	function getCurrentRoomPosition() as Point2D {
		if (dungeon == null) {
			throw new Lang.Exception();
		}
		return dungeon.getCurrentRoomPosition();
	}

	function setCurrentRoom(room_name as String?) as Void {
		if (dungeon == null) {
			return;
		}
		dungeon.setCurrentRoom(room_name);
	}

	function setCurrentRoomFromIndex(index as Point2D) as Void {
		if (dungeon == null) {
			return;
		}
		dungeon.setCurrentRoomFromIndex(index);
	}

	// Centralized ownership helpers to avoid circular references across modules.
	function setPlayer(p as Player?) as Void {
		player = p;
	}

	function getPlayer() as Player? {
		return player;
	}

	function setDungeon(d as Dungeon?) as Void {
		dungeon = d;
	}

	function getDungeon() as Dungeon? {
		return dungeon;
	}

	function setTurns(t as Turn?) as Void {
		turns = t;
	}

	function getTurns() as Turn? {
		return turns;
	}

	function clearSession() as Void {
		player = null;
		dungeon = null;
		turns = null;
	}

}