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

module Game {
	var difficulty as Difficulty = MEDIUM;
	var game_mode as GameMode = NORMAL;
	var player as Player?;
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

	function init(player_id as Number) as Void {
		// Set the seed for random number generation
		Math.srand(Time.now().value());
		EntityManager.init();
		Items.init(player_id);
		Enemies.init(player_id);
		time_played = 0;
		depth = 0;
		difficulty = MEDIUM;
		game_mode = NORMAL;
		map = [];
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
		}
	}

	function addRoomToMap(pos as Point2D, room_name as String, connections as Dictionary<WalkDirection, Boolean>, size as Point2D) as Void {
		map[pos[0]][pos[1]] = [room_name, connections, size, false, [null, null, null]];
	}

	function setRoomAsVisited(pos as Point2D) as Void {
		map[pos[0]][pos[1]][3] = true;
	}

	function setRoomWithFlag(pos as Point2D, flag as Number, pos_flag as Point2D) as Void {
		map[pos[0]][pos[1]][4][flag] = pos_flag;
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

}