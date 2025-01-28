import Toybox.Lang;

class ItemSpecificValues {

	var _player_id as Number;

	function initialize(player_id as Number) {
		_player_id = player_id;
	}

	function getDungeonItemWeights() as [Array, Array] {
		switch (_player_id) {
			case 0:
				return getDungeonItemWeightsWarrior();
			case 1:
				return getDungeonItemWeightsMage();
			case 999:
				return getDungeonItemWeightsGod();
			default:
				return [[], []];
		}
	}

	private function isBetweenDepth(depth as Number, min as Number, max as Number) as Boolean {
		return depth >= min && depth <= max;
	}

	function getDungeonItemWeightsWarrior() as [Array, Array] {
		return [[], []]; 
	}

	function getDungeonItemWeightsGod() as [Array, Array] {
		return [[], []];
	}

	function getDungeonItemWeightsMage() as [Array, Array] {
		var depth = $.Game.depth;
		
		// Scaling functions
		var log_depth = Math.log(depth + 1, 2);       // Logarithmic scaling
		var sqrt_depth = Math.sqrt(depth);         // Square root scaling

		var weapon_weights = {
			// Weapons (mage priority)
			6 => 5 + log_depth,                    // Steel Spell (main mage weapon, scales moderately)
			7 => 5 + log_depth,                    // Steel Staff (main mage weapon, scales moderately)
			
			// Other weapons (phased out as depth increases)
			0 => depth <= 10 ? 1 : 1 / log_depth,  // Steel Axe (low priority, fades out)
			1 => depth <= 10 ? 1 : 1 / log_depth,  // Steel Bow
			2 => depth <= 10 ? 1 : 1 / sqrt_depth, // Steel Dagger (remains slightly relevant)
			3 => 0,                                // Steel Greatsword (irrelevant for mages)
			4 => 0,                                // Steel Katana (irrelevant for mages)
			5 => depth <= 10 ? 1 : 1 / log_depth,  // Steel Lance
			8 => depth <= 10 ? 1 : 1 / log_depth,  // Steel Sword
		};

		var armor_weights = {	
			// Armor
			1000 => 1 + sqrt_depth,               // Steel Helmet (moderate scaling)
			1001 => 1 + sqrt_depth,               // Steel Breastplate
			1002 => 1 + sqrt_depth,               // Steel Gauntlets
			1003 => 1 + sqrt_depth,               // Steel Shoes
			1004 => 3 + log_depth,                // Steel Ring1 (useful for mages, scales well)
			1005 => 3 + log_depth,                // Steel Ring2
			1006 => depth <= 20 ? 1 : 1 / depth,  // Wood Shield (phased out)
			1007 => 2,                            // Green Backpack (utility, constant)
			1008 => depth <= 10 ? 1 : 2 + sqrt_depth, // Life Amulet (increasingly useful at high depth)
		};

		var consumable_weights = {		
			// Consumables
			2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion (phased out as depth increases)
			2001 => 5 + log_depth,                    // Mana Potion (scales well with mage needs)
			2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion (appears at mid-depth)
			2003 => depth >= 10 ? 5 + sqrt_depth : 0, // Greater Mana Potion (important for mages)
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion (rare, late-game only)
			2005 => depth >= 50 ? 4 + log_depth : 0,  // Max Mana Potion (critical for mages)
		};

		// High-Quality weights
		var high_quality_weights = {
			6 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Spell (early-game only)
			7 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Staff (early-game only)
			1004 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring1 (early-game only)
			1005 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring2 (early-game only)
			1008 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Life Amulet (early-game only)
			2003 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Greater Mana Potion (early-game only)
		};

		var weights = [
			weapon_weights,
			armor_weights,
			consumable_weights,
			high_quality_weights
		];

		// Calculate total weights for each category
		var total_weight = [0, 0, 0, 0];
		var weight_keys = [
			weapon_weights.keys(),
			armor_weights.keys(),
			consumable_weights.keys(),
			high_quality_weights.keys()
		];
		
		for (var i = 0; i < 4; i++) {
			var keys = weight_keys[i];
			for (var j = 0; j < keys.size(); j++) {
				total_weight[i] += weights[i][keys[j]];
			}
		}

		return [weights, total_weight];
	}

}