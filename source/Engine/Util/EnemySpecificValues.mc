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
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Imp
			{:id => 5, :cost => 10, :weight => depth <= 10 ? 8 : 8 / log_depth },  // Skeleton
			{:id => 6, :cost => 20, :weight => depth <= 10 ? 4 : 4 / log_depth },  // Necromancer
			{:id => 7, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth }, // ZombieSmall
			{:id => 8, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Zombie
			{:id => 9, :cost => 15, :weight => depth <= 10 ? 8 : 8 / log_depth },  // Wogol
			{:id => 10, :cost => 20, :weight => depth <= 10 ? 4 : 4 / log_depth }, // Ogre
			{:id => 11, :cost => 25, :weight => depth <= 10 ? 2 : 2 / log_depth }, // DarkKnight
			{:id => 12, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalAirSmall
			{:id => 13, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalEarthSmall
			{:id => 14, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalFireSmall
			{:id => 15, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGoldSmall
			{:id => 16, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGooSmall
			{:id => 30, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalPlantSmall
			{:id => 17, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalWaterSmall
			{:id => 18, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalAir
			{:id => 19, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalEarth
			{:id => 20, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalFire
			{:id => 21, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGold
			{:id => 22, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGoo
			{:id => 23, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalPlant
			{:id => 24, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalWater
		];

		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsGod() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var enemy_weights = [
			{:id => 0, :cost => 3, :weight => 10 + log_depth }, // Frog
			{:id => 1, :cost => 7, :weight => 10 + log_depth }, // Bat
			{:id => 2, :cost => 25, :weight => 10 + log_depth }, // Demon
			{:id => 3, :cost => 5, :weight => 10 + log_depth }, // Orc
			{:id => 4, :cost => 5, :weight => 10 + log_depth }, // Imp
			{:id => 5, :cost => 10, :weight => 10 + log_depth }, // Skeleton
			{:id => 6, :cost => 20, :weight => 10 + log_depth }, // Necromancer
			{:id => 7, :cost => 3, :weight => 10 + log_depth }, // ZombieSmall
			{:id => 8, :cost => 5, :weight => 10 + log_depth }, // Zombie
			{:id => 9, :cost => 15, :weight => 10 + log_depth }, // Wogol
			{:id => 10, :cost => 20, :weight => 10 + log_depth }, // Ogre
			{:id => 11, :cost => 25, :weight => 10 + log_depth }, // DarkKnight
			{:id => 12, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalAirSmall
			{:id => 13, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalEarthSmall
			{:id => 14, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalFireSmall
			{:id => 15, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGoldSmall
			{:id => 16, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGooSmall
			{:id => 30, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalPlantSmall
			{:id => 17, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalWaterSmall
			{:id => 18, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalAir
			{:id => 19, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalEarth
			{:id => 20, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalFire
			{:id => 21, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGold
			{:id => 22, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGoo
			{:id => 23, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalPlant
			{:id => 24, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalWater
			{:id => 25, :cost => 10, :weight => 10 + log_depth }, // Goblin
			{:id => 26, :cost => 20, :weight => 10 + log_depth }, // Tentackle
			{:id => 27, :cost => 30, :weight => 10 + log_depth }, // Demonolog
			{:id => 28, :cost => 40, :weight => 10 + log_depth }, // Chort
			{:id => 29, :cost => 50, :weight => 10 + log_depth }, // Bies
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
			{:id => 2, :cost => 100, :weight => depth <= 10 ? 0 : 0 + log_depth },		// Demon
			{:id => 3, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth },		// Orc
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth },		// Imp
			{:id => 6, :cost => 20, :weight => depth <= 10 ? 4 : 4 / log_depth },		// Necromancer
			{:id => 7, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth },		// ZombieSmall
			{:id => 8, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth },		// Zombie
			{:id => 12, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalAirSmall
			{:id => 13, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalEarthSmall
			{:id => 14, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalFireSmall
			{:id => 15, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGoldSmall
			{:id => 16, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGooSmall
			{:id => 30, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalPlantSmall
			{:id => 17, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalWaterSmall
			{:id => 18, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalAir
			{:id => 19, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalEarth
			{:id => 20, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalFire
			{:id => 21, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGold
			{:id => 22, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGoo
			{:id => 23, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalPlant
			{:id => 24, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalWater
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
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Imp
			{:id => 5, :cost => 10, :weight => depth <= 10 ? 8 : 8 / log_depth },  // Skeleton
			{:id => 7, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth }, // ZombieSmall
			{:id => 8, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Zombie
			{:id => 9, :cost => 15, :weight => depth <= 10 ? 8 : 8 / log_depth },  // Wogol
			{:id => 10, :cost => 20, :weight => depth <= 10 ? 4 : 4 / log_depth }, // Ogre
			{:id => 25, :cost => 10, :weight => depth <= 10 ? 8 : 8 / log_depth }, // Goblin
			{:id => 12, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalAirSmall
			{:id => 13, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalEarthSmall
			{:id => 14, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalFireSmall
			{:id => 15, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGoldSmall
			{:id => 16, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalGooSmall
			{:id => 30, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalPlantSmall
			{:id => 17, :cost => 5, :weight => depth <= 10 ? 4 : 4 / log_depth },		// ElementalWaterSmall
			{:id => 18, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalAir
			{:id => 19, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalEarth
			{:id => 20, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalFire
			{:id => 21, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGold
			{:id => 22, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalGoo
			{:id => 23, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalPlant
			{:id => 24, :cost => 20, :weight => depth <= 10 ? 2 : 2 / log_depth },		// ElementalWater
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
			{:id => 4, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Imp
			{:id => 5, :cost => 10, :weight => depth <= 10 ? 8 : 8 / log_depth },  // Skeleton
			{:id => 6, :cost => 20, :weight => depth <= 10 ? 4 : 4 / log_depth },  // Necromancer
			{:id => 7, :cost => 3, :weight => depth <= 10 ? 16 : 16 / log_depth }, // ZombieSmall
			{:id => 8, :cost => 5, :weight => depth <= 10 ? 16 : 16 / log_depth }, // Zombie
			{:id => 9, :cost => 15, :weight => depth <= 10 ? 8 : 8 / log_depth },  // Wogol
			{:id => 10, :cost => 20, :weight => depth <= 10 ? 4 : 4 / log_depth }, // Ogre
			{:id => 11, :cost => 25, :weight => depth <= 10 ? 2 : 2 / log_depth }, // DarkKnight
			{:id => 12, :cost => 30, :weight => depth <= 10 ? 4 : 4 / log_depth }, // ElementalAirSmall
			{:id => 13, :cost => 30, :weight => depth <= 10 ? 4 : 4 / log_depth }, // ElementalEarthSmall
			{:id => 14, :cost => 30, :weight => depth <= 10 ? 4 : 4 / log_depth }, // ElementalFireSmall
			{:id => 15, :cost => 30, :weight => depth <= 10 ? 4 : 4 / log_depth }, // ElementalGoldSmall
			{:id => 16, :cost => 30, :weight => depth <= 10 ? 4 : 4 / log_depth }, // ElementalGooSmall
			{:id => 30, :cost => 30, :weight => depth <= 10 ? 4 : 4 / log_depth }, // ElementalPlantSmall
			{:id => 17, :cost => 30, :weight => depth <= 10 ? 4 : 4 / log_depth }, // ElementalWaterSmall
			{:id => 18, :cost => 50, :weight => depth <= 10 ? 2 : 2 / log_depth }, // ElementalAir
			{:id => 19, :cost => 50, :weight => depth <= 10 ? 2 : 2 / log_depth }, // ElementalEarth
			{:id => 20, :cost => 50, :weight => depth <= 10 ? 2 : 2 / log_depth }, // ElementalFire
			{:id => 21, :cost => 50, :weight => depth <= 10 ? 2 : 2 / log_depth }, // ElementalGold
			{:id => 22, :cost => 50, :weight => depth <= 10 ? 2 : 2 / log_depth }, // ElementalGoo
			{:id => 23, :cost => 50, :weight => depth <= 10 ? 2 : 2 / log_depth }, // ElementalPlant
			{:id => 24, :cost => 50, :weight => depth <= 10 ? 2 : 2 / log_depth }, // ElementalWater
			{:id => 25, :cost => 10, :weight => depth <= 10 ? 8 : 8 / log_depth }, // Goblin
			{:id => 26, :cost => 20, :weight => depth <= 10 ? 4 : 4 / log_depth }, // Tentackle
		];

		return [enemy_weights, enemy_weights];
	}
}