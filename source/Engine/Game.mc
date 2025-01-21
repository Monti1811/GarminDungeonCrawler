import Toybox.Lang;
import Toybox.Time;

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

	function init(player_id as Number) as Void {
		Items.init(player_id);
		Enemies.init(player_id);
		time_played = 0;
		depth = 0;
		difficulty = MEDIUM;
		game_mode = NORMAL;
	}

	function save() as Dictionary {
		return {
			"difficulty" => difficulty,
			"game_mode" => game_mode,
			"depth" => depth,
			"time_played" => time_played,
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