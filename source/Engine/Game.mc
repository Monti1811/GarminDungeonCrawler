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


	function save() as Dictionary {
		return {
			"difficulty" => difficulty,
			"game_mode" => game_mode,
		};
	}

	function load(data as Dictionary?) {
		if (data == null) {
			return;
		}
		difficulty = data["difficulty"];
		game_mode = data["game_mode"];
	}
}