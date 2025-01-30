import Toybox.Lang;

class EnemySpecificValues {

	var _player_id as Number;

	function initialize(player_id as Number) {
		_player_id = player_id;
	}

	function getDungeonEnemyWeights() as [Array, Array] {
		switch (_player_id) {
			case 0:
				return getDungeonEnemyWeightsWarrior();
			case 1:
				return getDungeonEnemyWeightsMage();
			case 2:
				return getDungeonEnemyWeightsArcher();
			case 3:
				return getDungeonEnemyWeightsNameless();
			case 999:
				return getDungeonEnemyWeightsGod();
			default:
				return [[], []];
		}
	}

	private function isBetweenDepth(depth as Number, min as Number, max as Number) as Boolean {
		return depth >= min && depth <= max;
	}

	function getDungeonEnemyWeightsWarrior() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var enemy_weights = [
			{:id => 0, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Frog
			{:id => 1, :cost => 7, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Bat
			{:id => 2, :cost => 25, :weight => depth <= 10 ? 0 : 0 + log_depth },  // Demon
			{:id => 3, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Orc
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }  // Imp
		];

		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsGod() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var enemy_weights = [
			{:id => 0, :cost => 3, :weight => 10 + log_depth }, // Divine Frog
			{:id => 1, :cost => 7, :weight => 10 + log_depth }, // Divine Bat
			{:id => 2, :cost => 25, :weight => 10 + log_depth }, // Divine Demon
			{:id => 3, :cost => 5, :weight => 10 + log_depth }, // Divine Orc
			{:id => 4, :cost => 5, :weight => 10 + log_depth }  // Divine Imp
		];

		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsMage() as [Array, Array] {
		var depth = $.Game.depth;
		
		// Scaling functions
		var log_depth = Math.log(depth + 1, 2);       	// Logarithmic scaling
		var sqrt_depth = Math.sqrt(depth);         		// Square root scaling

		var enemy_weights = [
			{:id => 0, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth }, 		// Frog
			{:id => 1, :cost => 7, :weight => depth <= 10 ? 16 : 16 / log_depth },		// Bat
			{:id => 2, :cost => 25, :weight => depth <= 10 ? 0 : 0 + log_depth },		// Demon
			{:id => 3, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth },		// Orc
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }		// Imp
		];

		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsArcher() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var enemy_weights = [
			{:id => 0, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Frog
			{:id => 1, :cost => 7, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Bat
			{:id => 2, :cost => 25, :weight => depth <= 10 ? 0 : 0 + log_depth },  // Demon
			{:id => 3, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Orc
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }  // Imp
		];

		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsNameless() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var enemy_weights = [
			{:id => 0, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Frog
			{:id => 1, :cost => 7, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Bat
			{:id => 2, :cost => 25, :weight => depth <= 10 ? 0 : 0 + log_depth },  // Demon
			{:id => 3, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Orc
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }  // Imp
		];

		return [enemy_weights, enemy_weights];
	}
}