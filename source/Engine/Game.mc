import Toybox.Lang;

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
		depth = data["depth"];
		time_played = data["time_played"];
	}

	function addToCurrentRun(amount as Number) as Void {
		current_run += amount;
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
		Toybox.System.println("Time started: " + time_started);
		Toybox.System.println("Time ended: " + time);
		var diff = time.subtract(time_started);
		time_played += diff.value();
		time_started = time;
	}

}