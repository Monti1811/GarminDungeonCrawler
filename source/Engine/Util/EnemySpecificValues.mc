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
		var enemy_weights = getEnemyWeightsForDepthAndClass(depth, 0);
		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsGod() as [Array, Array] {
		var depth = $.Game.depth;
		var enemy_weights = getEnemyWeightsForDepthAndClass(depth, 999);
		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsMage() as [Array, Array] {
		var depth = $.Game.depth;
		var enemy_weights = getEnemyWeightsForDepthAndClass(depth, 1);
		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsArcher() as [Array, Array] {
		var depth = $.Game.depth;
		var enemy_weights = getEnemyWeightsForDepthAndClass(depth, 2);
		return [enemy_weights, enemy_weights];
	}

	function getDungeonEnemyWeightsNameless() as [Array, Array] {
		var depth = $.Game.depth;
		var enemy_weights = getEnemyWeightsForDepthAndClass(depth, 3);
		return [enemy_weights, enemy_weights];
	}

	private function getEnemyWeightsForDepthAndClass(depth as Number, class_id as Number) as Array {
		var base_weights = getEnemyWeightsForDepth(depth);
		var multipliers = getClassWeightMultipliers(class_id);
		return applyClassMultipliers(base_weights, multipliers);
	}

	private function getEnemyWeightsForDepth(depth as Number) as Array
	<Dictionary<Symbol, Number>> {
		var enemy_weights = [
			{:id => 0, :cost => 3, :weight => tieredWeight(depth, [ {:max => 4, :weight => 18}, {:max => 9, :weight => 12}, {:max => 16, :weight => 6}, {:max => 999, :weight => 2} ])}, // Frog
			{:id => 1, :cost => 7, :weight => tieredWeight(depth, [ {:max => 4, :weight => 18}, {:max => 9, :weight => 12}, {:max => 16, :weight => 6}, {:max => 999, :weight => 2} ])}, // Bat
			{:id => 4, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 16}, {:max => 10, :weight => 12}, {:max => 18, :weight => 6}, {:max => 999, :weight => 3} ])}, // Imp
			{:id => 7, :cost => 3, :weight => tieredWeight(depth, [ {:max => 4, :weight => 18}, {:max => 9, :weight => 12}, {:max => 16, :weight => 6}, {:max => 999, :weight => 3} ])}, // ZombieSmall
			{:id => 8, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 16}, {:max => 10, :weight => 12}, {:max => 18, :weight => 6}, {:max => 999, :weight => 3} ])}, // Zombie
			{:id => 3, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 10}, {:max => 18, :weight => 8}, {:max => 999, :weight => 5} ])}, // Orc
			{:id => 5, :cost => 10, :weight => tieredWeight(depth, [ {:max => 5, :weight => 0}, {:max => 10, :weight => 6}, {:max => 18, :weight => 8}, {:max => 999, :weight => 6} ])}, // Skeleton
			{:id => 25, :cost => 10, :weight => tieredWeight(depth, [ {:max => 3, :weight => 0}, {:max => 9, :weight => 8}, {:max => 16, :weight => 10}, {:max => 999, :weight => 6} ])}, // Goblin
			{:id => 9, :cost => 15, :weight => tieredWeight(depth, [ {:max => 5, :weight => 0}, {:max => 10, :weight => 6}, {:max => 16, :weight => 8}, {:max => 999, :weight => 6} ])}, // Wogol
			{:id => 10, :cost => 20, :weight => tieredWeight(depth, [ {:max => 7, :weight => 0}, {:max => 12, :weight => 4}, {:max => 18, :weight => 7}, {:max => 999, :weight => 7} ])}, // Ogre
			{:id => 6, :cost => 20, :weight => tieredWeight(depth, [ {:max => 7, :weight => 0}, {:max => 12, :weight => 3}, {:max => 18, :weight => 6}, {:max => 999, :weight => 6} ])}, // Necromancer
			{:id => 11, :cost => 25, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 3}, {:max => 22, :weight => 6}, {:max => 999, :weight => 5} ])}, // DarkKnight
			{:id => 12, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 5}, {:max => 16, :weight => 7}, {:max => 999, :weight => 4} ])}, // ElementalAirSmall
			{:id => 13, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 5}, {:max => 16, :weight => 7}, {:max => 999, :weight => 4} ])}, // ElementalEarthSmall
			{:id => 14, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 5}, {:max => 16, :weight => 7}, {:max => 999, :weight => 4} ])}, // ElementalFireSmall
			{:id => 15, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 5}, {:max => 16, :weight => 7}, {:max => 999, :weight => 4} ])}, // ElementalGoldSmall
			{:id => 16, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 5}, {:max => 16, :weight => 7}, {:max => 999, :weight => 4} ])}, // ElementalGooSmall
			{:id => 30, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 5}, {:max => 16, :weight => 7}, {:max => 999, :weight => 4} ])}, // ElementalPlantSmall
			{:id => 17, :cost => 5, :weight => tieredWeight(depth, [ {:max => 4, :weight => 0}, {:max => 10, :weight => 5}, {:max => 16, :weight => 7}, {:max => 999, :weight => 4} ])}, // ElementalWaterSmall
			{:id => 18, :cost => 20, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 6} ])}, // ElementalAir
			{:id => 19, :cost => 20, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 6} ])}, // ElementalEarth
			{:id => 20, :cost => 20, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 6} ])}, // ElementalFire
			{:id => 21, :cost => 20, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 6} ])}, // ElementalGold
			{:id => 22, :cost => 20, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 6} ])}, // ElementalGoo
			{:id => 23, :cost => 20, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 6} ])}, // ElementalPlant
			{:id => 24, :cost => 20, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 16, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 6} ])}, // ElementalWater
			{:id => 26, :cost => 20, :weight => tieredWeight(depth, [ {:max => 6, :weight => 0}, {:max => 12, :weight => 6}, {:max => 18, :weight => 7}, {:max => 999, :weight => 6} ])}, // Tentackle
			{:id => 2, :cost => 25, :weight => tieredWeight(depth, [ {:max => 9, :weight => 0}, {:max => 14, :weight => 3}, {:max => 20, :weight => 6}, {:max => 999, :weight => 7} ])}, // Demon
			{:id => 27, :cost => 30, :weight => tieredWeight(depth, [ {:max => 13, :weight => 0}, {:max => 18, :weight => 4}, {:max => 24, :weight => 7}, {:max => 999, :weight => 6} ])}, // Demonolog
			{:id => 33, :cost => 20, :weight => tieredWeight(depth, [ {:max => 7, :weight => 0}, {:max => 14, :weight => 5}, {:max => 20, :weight => 7}, {:max => 999, :weight => 6} ])}, // OrcShaman
			{:id => 32, :cost => 20, :weight => tieredWeight(depth, [ {:max => 5, :weight => 0}, {:max => 12, :weight => 6}, {:max => 18, :weight => 7}, {:max => 999, :weight => 5} ])}, // OrcMasked
			{:id => 31, :cost => 50, :weight => tieredWeight(depth, [ {:max => 9, :weight => 0}, {:max => 15, :weight => 4}, {:max => 22, :weight => 7}, {:max => 999, :weight => 7} ])}, // OrcArmored
			{:id => 34, :cost => 50, :weight => tieredWeight(depth, [ {:max => 11, :weight => 0}, {:max => 17, :weight => 4}, {:max => 24, :weight => 7}, {:max => 999, :weight => 7} ])}, // OrcVeteran
			{:id => 28, :cost => 40, :weight => tieredWeight(depth, [ {:max => 15, :weight => 0}, {:max => 20, :weight => 4}, {:max => 26, :weight => 6}, {:max => 999, :weight => 6} ])}, // Chort
			{:id => 29, :cost => 50, :weight => tieredWeight(depth, [ {:max => 17, :weight => 0}, {:max => 22, :weight => 3}, {:max => 999, :weight => 5} ])}, // Bies
			{:id => 35, :cost => 50, :weight => tieredWeight(depth, [ {:max => 19, :weight => 0}, {:max => 24, :weight => 4}, {:max => 999, :weight => 7} ])} // Rokita
		] as Array<Dictionary<Symbol, Number>>;

		return enemy_weights;
	}

	private function getClassWeightMultipliers(class_id as Number) as Dictionary<Number, Numeric> {
		switch (class_id) {
			case 0: // Warrior: more melee and armored threats, fewer fliers
				return {
					1 => 0.9, // Bat
					4 => 0.9, // Imp
					7 => 0.95, // ZombieSmall
					8 => 0.95, // Zombie
					3 => 1.1, // Orc
					5 => 1.1, // Skeleton
					9 => 1.1, // Wogol
					10 => 1.2, // Ogre
					11 => 1.25, // DarkKnight
					25 => 1.1, // Goblin
					31 => 1.2, // OrcArmored
					32 => 1.1, // OrcMasked
					33 => 1.1, // OrcShaman
					34 => 1.25, // OrcVeteran
					35 => 1.2  // Rokita
				};
			case 1: // Mage: more undead/elementals, fewer heavy brutes
				return {
					3 => 0.9, // Orc
					9 => 0.9, // Wogol
					10 => 0.85, // Ogre
					25 => 0.9, // Goblin
					31 => 0.85, // OrcArmored
					34 => 0.85, // OrcVeteran
					35 => 0.85, // Rokita
					5 => 1.15, // Skeleton
					6 => 1.25, // Necromancer
					7 => 1.1, // ZombieSmall
					8 => 1.1, // Zombie
					12 => 1.2, // ElementalAirSmall
					13 => 1.2, // ElementalEarthSmall
					14 => 1.2, // ElementalFireSmall
					15 => 1.2, // ElementalGoldSmall
					16 => 1.2, // ElementalGooSmall
					30 => 1.2, // ElementalPlantSmall
					17 => 1.2, // ElementalWaterSmall
					18 => 1.1, // ElementalAir
					19 => 1.1, // ElementalEarth
					20 => 1.1, // ElementalFire
					21 => 1.1, // ElementalGold
					22 => 1.1, // ElementalGoo
					23 => 1.1, // ElementalPlant
					24 => 1.1  // ElementalWater
				};
			case 2: // Archer: more agile/flying foes, fewer armored bruisers
				return {
					3 => 0.9, // Orc
					10 => 0.85, // Ogre
					11 => 0.85, // DarkKnight
					31 => 0.85, // OrcArmored
					34 => 0.85, // OrcVeteran
					29 => 0.9, // Bies
					1 => 1.25, // Bat
					4 => 1.2, // Imp
					7 => 1.15, // ZombieSmall
					8 => 1.1, // Zombie
					25 => 1.15, // Goblin
					9 => 1.1, // Wogol
					12 => 1.05, // ElementalAirSmall
					14 => 1.05  // ElementalFireSmall
				};
			case 3: // Nameless: balanced
				return {};
			case 999: // God: slightly more high-tier threats
				return {
					2 => 1.1, // Demon
					27 => 1.1, // Demonolog
					28 => 1.1, // Chort
					29 => 1.1, // Bies
					35 => 1.1  // Rokita
				};
			default:
				return {};
		}
	}

	private function applyClassMultipliers(base_weights as Array<Dictionary<Symbol, Number>>, multipliers as Dictionary<Number, Numeric>) as Array {
		var adjusted = [];
		for (var i = 0; i < base_weights.size(); i++) {
			var entry = base_weights[i] as Dictionary<Symbol, Number>;
			var id = entry[:id];
			var factor = multipliers.hasKey(id) ? multipliers[id] : 1;
			adjusted.add({ :id => id, :cost => entry[:cost], :weight => entry[:weight] * factor });
		}
		return adjusted;
	}

	private function tieredWeight(depth as Number, tiers as Array<Dictionary<Symbol, Number>>) as Number {
		var fallback = tiers[tiers.size() - 1][:weight];
		for (var i = 0; i < tiers.size(); i++) {
			var tier = tiers[i];
			if (depth <= tier[:max]) {
				return tier[:weight];
			}
		}
		return fallback;
	}
}