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
			case 2:
				return getDungeonItemWeightsArcher();
			case 3:
				return getDungeonItemWeightsNameless();
			case 999:
				return getDungeonItemWeightsGod();
			default:
				return [[{},{},{},{}], []];
		}
	}

	private function isBetweenDepth(depth as Number, min as Number, max as Number) as Boolean {
		return depth >= min && depth <= max;
	}

	function getDungeonItemWeightsWarrior() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var weapon_weights = {
			0 => 5 + log_depth, // Steel Axe
			3 => 5 + log_depth, // Steel Greatsword
			5 => 5 + log_depth, // Steel Lance
			8 => 3 + log_depth, // Steel Sword
			1 => depth <= 10 ? 1 : 1 / log_depth, // Steel Bow
			2 => depth <= 10 ? 1 : 1 / sqrt_depth, // Steel Dagger
			4 => depth <= 10 ? 1 : 1 / log_depth, // Steel Katana
			6 => depth <= 10 ? 1 : 1 / log_depth, // Steel Spell
			7 => depth <= 10 ? 1 : 1 / log_depth, // Steel Staff
		};

		var armor_weights = {
			1000 => 1 + sqrt_depth, // Steel Helmet
			1001 => 1 + sqrt_depth, // Steel Breastplate
			1002 => 1 + sqrt_depth, // Steel Gauntlets
			1003 => 1 + sqrt_depth, // Steel Shoes
			1004 => 2 + log_depth,  // Steel Ring1
			1005 => 2 + log_depth,  // Steel Ring2
			1006 => 1 + sqrt_depth, // Wood Shield
			1007 => 2,              // Green Backpack
			1008 => 1 + sqrt_depth, // Life Amulet
		};

		var consumable_weights = {
			2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
			2001 => 2 + log_depth,                    // Mana Potion
			2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
			2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
			2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
		};

		var high_quality_weights = {
			0 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Axe
			3 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Greatsword
			5 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Lance
			1004 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
			1008 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Life Amulet
			2002 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
		};

		var merchant_weights = {
			0 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Axe
			3 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Greatsword
			5 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Lance
			8 => isBetweenDepth(depth, 1, 10) ? 2 + sqrt_depth : 0, // Steel Sword
			1004 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
			1000 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
			1001 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
			1002 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
			1003 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
			1006 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Wood Shield
			1007 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Green Backpack
			1008 => depth >= 20 ? 1 + sqrt_depth : 0, // Life Amulet
			2000 => depth <= 20 ? 6 : 2 / sqrt_depth, // Health Potion
			2001 => 4 + log_depth,                    // Mana Potion
			2002 => depth >= 20 ? 4 + sqrt_depth : 0, // Greater Health Potion
			2003 => depth >= 20 ? 2 + sqrt_depth : 0, // Greater Mana Potion
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
			2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
		};

		var weights = [
			weapon_weights,
			armor_weights,
			consumable_weights,
			high_quality_weights,
			merchant_weights
		];

		var total_weight = [0, 0, 0, 0, 0];
		var weight_keys = [
			weapon_weights.keys(),
			armor_weights.keys(),
			consumable_weights.keys(),
			high_quality_weights.keys(),
			merchant_weights.keys()
		];

		for (var i = 0; i < weight_keys.size(); i++) {
			var keys = weight_keys[i];
			for (var j = 0; j < keys.size(); j++) {
				total_weight[i] += weights[i][keys[j]];
			}
		}

		return [weights, total_weight];
	}

	function getDungeonItemWeightsGod() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var weapon_weights = {
			0 => 10 + log_depth, // Divine Axe
			3 => 10 + log_depth, // Divine Greatsword
			5 => 10 + log_depth, // Divine Lance
			8 => 10 + log_depth, // Divine Sword
			1 => 10 + log_depth, // Divine Bow
			2 => 10 + log_depth, // Divine Dagger
			4 => 10 + log_depth, // Divine Katana
			6 => 10 + log_depth, // Divine Spell
			7 => 10 + log_depth, // Divine Staff
		};

		var armor_weights = {
			1000 => 5 + sqrt_depth, // Divine Helmet
			1001 => 5 + sqrt_depth, // Divine Breastplate
			1002 => 5 + sqrt_depth, // Divine Gauntlets
			1003 => 5 + sqrt_depth, // Divine Shoes
			1004 => 5 + log_depth,  // Divine Ring1
			1005 => 5 + log_depth,  // Divine Ring2
			1006 => 5 + sqrt_depth, // Divine Shield
			1007 => 5,              // Divine Backpack
			1008 => 5 + sqrt_depth, // Divine Amulet
		};

		var consumable_weights = {
			2000 => 10 + log_depth, // Divine Health Potion
			2001 => 10 + log_depth, // Divine Mana Potion
			2002 => 10 + sqrt_depth, // Greater Divine Health Potion
			2003 => 10 + sqrt_depth, // Greater Divine Mana Potion
			2004 => 10 + log_depth,  // Max Divine Health Potion
			2005 => 10 + log_depth,  // Max Divine Mana Potion
		};

		var high_quality_weights = {
			0 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Axe
			3 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Greatsword
			5 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Lance
			1004 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Ring2
			1008 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Amulet
			2002 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Greater Divine Health Potion
		};

		var merchant_weights = {
			0 => isBetweenDepth(depth, 1, 10) ? 10 + sqrt_depth : 0, // Divine Axe
			3 => isBetweenDepth(depth, 1, 10) ? 10 + sqrt_depth : 0, // Divine Greatsword
			5 => isBetweenDepth(depth, 1, 10) ? 10 + sqrt_depth : 0, // Divine Lance
			8 => isBetweenDepth(depth, 1, 10) ? 10 + sqrt_depth : 0, // Divine Sword
			1004 => isBetweenDepth(depth, 1, 10) ? 10 + sqrt_depth : 0, // Divine Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 10 + sqrt_depth : 0, // Divine Ring2
			1000 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Helmet
			1001 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Breastplate
			1002 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Gauntlets
			1003 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Shoes
			1006 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Shield
			1007 => isBetweenDepth(depth, 1, 10) ? 5 + sqrt_depth : 0, // Divine Backpack
			1008 => depth >= 20 ? 5 + sqrt_depth : 0, // Divine Amulet
			2000 => depth <= 20 ? 10 : 5 / sqrt_depth, // Divine Health Potion
			2001 => 10 + log_depth,                    // Divine Mana Potion
			2002 => depth >= 20 ? 10 + sqrt_depth : 0, // Greater Divine Health Potion
			2003 => depth >= 20 ? 10 + sqrt_depth : 0, // Greater Divine Mana Potion
			2004 => depth >= 50 ? 10 + log_depth : 0,  // Max Divine Health Potion
			2005 => depth >= 50 ? 10 + log_depth : 0,  // Max Divine Mana Potion
		};

		var weights = [
			weapon_weights,
			armor_weights,
			consumable_weights,
			high_quality_weights,
			merchant_weights
		];

		var total_weight = [0, 0, 0, 0, 0];
		var weight_keys = [
			weapon_weights.keys(),
			armor_weights.keys(),
			consumable_weights.keys(),
			high_quality_weights.keys(),
			merchant_weights.keys()
		];

		for (var i = 0; i < weight_keys.size(); i++) {
			var keys = weight_keys[i];
			for (var j = 0; j < keys.size(); j++) {
				total_weight[i] += weights[i][keys[j]];
			}
		}

		return [weights, total_weight];
	}

	function getDungeonItemWeightsNameless() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var weapon_weights = {
			// ...nameless-specific weapon weights...
			4 => 5 + log_depth, // Steel Katana
			0 => depth <= 10 ? 1 : 1 / log_depth, // Steel Axe
			1 => depth <= 10 ? 1 : 1 / log_depth, // Steel Bow
			2 => depth <= 10 ? 1 : 1 / sqrt_depth, // Steel Dagger
			3 => depth <= 10 ? 1 : 1 / log_depth, // Steel Greatsword
			5 => depth <= 10 ? 1 : 1 / log_depth, // Steel Lance
			6 => depth <= 10 ? 1 : 1 / log_depth, // Steel Spell
			7 => depth <= 10 ? 1 : 1 / log_depth, // Steel Staff
			8 => depth <= 10 ? 1 : 1 / log_depth, // Steel Sword
		};

		var armor_weights = {
			// ...nameless-specific armor weights...
			1000 => 1 + sqrt_depth, // Steel Helmet
			1001 => 1 + sqrt_depth, // Steel Breastplate
			1002 => 1 + sqrt_depth, // Steel Gauntlets
			1003 => 1 + sqrt_depth, // Steel Shoes
			1004 => 2 + log_depth,  // Steel Ring1
			1005 => 2 + log_depth,  // Steel Ring2
			1006 => 1 + sqrt_depth, // Wood Shield
			1007 => 2,              // Green Backpack
			1008 => 1 + sqrt_depth, // Life Amulet
		};

		var consumable_weights = {
			// ...nameless-specific consumable weights...
			2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
			2001 => 2 + log_depth,                    // Mana Potion
			2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
			2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
			2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
		};

		var high_quality_weights = {
			// ...nameless-specific high-quality weights...
			4 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Katana
			1004 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
			1008 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Life Amulet
			2002 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
		};

		var merchant_weights = {
			// ...nameless-specific merchant weights...
			4 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Katana
			1004 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
			1000 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
			1001 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
			1002 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
			1003 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
			1006 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Wood Shield
			1007 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Green Backpack
			1008 => depth >= 20 ? 1 + sqrt_depth : 0, // Life Amulet
			2000 => depth <= 20 ? 6 : 2 / sqrt_depth, // Health Potion
			2001 => 4 + log_depth,                    // Mana Potion
			2002 => depth >= 20 ? 4 + sqrt_depth : 0, // Greater Health Potion
			2003 => depth >= 20 ? 2 + sqrt_depth : 0, // Greater Mana Potion
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
			2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
		};

		var weights = [
			weapon_weights,
			armor_weights,
			consumable_weights,
			high_quality_weights,
			merchant_weights
		];

		var total_weight = [0, 0, 0, 0, 0];
		var weight_keys = [
			weapon_weights.keys(),
			armor_weights.keys(),
			consumable_weights.keys(),
			high_quality_weights.keys(),
			merchant_weights.keys()
		];

		for (var i = 0; i < weight_keys.size(); i++) {
			var keys = weight_keys[i];
			for (var j = 0; j < keys.size(); j++) {
				total_weight[i] += weights[i][keys[j]];
			}
		}

		return [weights, total_weight];
	}

	function getDungeonItemWeightsArcher() as [Array, Array] {
		var depth = $.Game.depth;
		var log_depth = Math.log(depth + 1, 2);
		var sqrt_depth = Math.sqrt(depth);

		var weapon_weights = {
			1 => 5 + log_depth, // Steel Bow
			2 => 5 + log_depth, // Steel Dagger
			0 => depth <= 10 ? 1 : 1 / log_depth, // Steel Axe
			3 => depth <= 10 ? 1 : 1 / log_depth, // Steel Greatsword
			4 => depth <= 10 ? 1 : 1 / log_depth, // Steel Katana
			5 => depth <= 10 ? 1 : 1 / log_depth, // Steel Lance
			6 => depth <= 10 ? 1 : 1 / log_depth, // Steel Spell
			7 => depth <= 10 ? 1 : 1 / log_depth, // Steel Staff
			8 => depth <= 10 ? 1 : 1 / log_depth, // Steel Sword
		};

		var armor_weights = {
			1000 => 1 + sqrt_depth, // Steel Helmet
			1001 => 1 + sqrt_depth, // Steel Breastplate
			1002 => 1 + sqrt_depth, // Steel Gauntlets
			1003 => 1 + sqrt_depth, // Steel Shoes
			1004 => 2 + log_depth,  // Steel Ring1
			1005 => 2 + log_depth,  // Steel Ring2
			1006 => 1 + sqrt_depth, // Wood Shield
			1007 => 2,              // Green Backpack
			1008 => 1 + sqrt_depth, // Life Amulet
		};

		var consumable_weights = {
			2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
			2001 => 2 + log_depth,                    // Mana Potion
			2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
			2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
			2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
		};

		var high_quality_weights = {
			1 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Bow
			2 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Dagger
			1004 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
			1008 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Life Amulet
			2002 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
		};

		var merchant_weights = {
			1 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Bow
			2 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Dagger
			1004 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
			1005 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
			1000 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
			1001 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
			1002 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
			1003 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
			1006 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Wood Shield
			1007 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Green Backpack
			1008 => depth >= 20 ? 1 + sqrt_depth : 0, // Life Amulet
			2000 => depth <= 20 ? 6 : 2 / sqrt_depth, // Health Potion
			2001 => 4 + log_depth,                    // Mana Potion
			2002 => depth >= 20 ? 4 + sqrt_depth : 0, // Greater Health Potion
			2003 => depth >= 20 ? 2 + sqrt_depth : 0, // Greater Mana Potion
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
			2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
		};

		var weights = [
			weapon_weights,
			armor_weights,
			consumable_weights,
			high_quality_weights,
			merchant_weights
		];

		var total_weight = [0, 0, 0, 0, 0];
		var weight_keys = [
			weapon_weights.keys(),
			armor_weights.keys(),
			consumable_weights.keys(),
			high_quality_weights.keys(),
			merchant_weights.keys()
		];

		for (var i = 0; i < weight_keys.size(); i++) {
			var keys = weight_keys[i];
			for (var j = 0; j < keys.size(); j++) {
				total_weight[i] += weights[i][keys[j]];
			}
		}

		return [weights, total_weight];
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

		// Merchant weights
		var merchant_weights = {
			// Weapons
			6 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Spell (early-game only)
			7 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Staff (early-game only)
			0 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Axe (early-game only)
			1 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Bow (early-game only)
			2 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Dagger (early-game only)
			5 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Lance (early-game only)
			8 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Sword (early-game only)


			// Armor
			1004 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring1 (early-game only)
			1005 => isBetweenDepth(depth, 1, 10) ? 3 + sqrt_depth : 0, // Steel Ring2 (early-game only)
			1000 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Helmet (early-game only)
			1001 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate (early-game only)
			1002 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets (early-game only)
			1003 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Steel Shoes (early-game only)
			1006 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Wood Shield (early-game only)
			1007 => isBetweenDepth(depth, 1, 10) ? 1 + sqrt_depth : 0, // Green Backpack (early-game only)

			1008 => depth >= 20 ? 1 + sqrt_depth : 0, // Life Amulet 
			// Consumables
			2000 => depth <= 20 ? 6 : 2 / sqrt_depth, // Health Potion (phased out as depth increases)
			2001 => 9 + log_depth,                    // Mana Potion (scales well with mage needs)
			2002 => depth >= 20 ? 4 + sqrt_depth : 0, // Greater Health Potion (appears at mid-depth)
			2003 => depth >= 20 ? 5 + sqrt_depth : 0, // Greater Mana Potion (important for mages)
			2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion (rare, late-game only)
			2005 => depth >= 50 ? 4 + log_depth : 0,  // Max Mana Potion (critical for mages)
		};

		var weights = [
			weapon_weights,
			armor_weights,
			consumable_weights,
			high_quality_weights,
			merchant_weights
		];

		// Calculate total weights for each category
		var total_weight = [0, 0, 0, 0, 0];
		var weight_keys = [
			weapon_weights.keys(),
			armor_weights.keys(),
			consumable_weights.keys(),
			high_quality_weights.keys(),
			merchant_weights.keys()
		];
		
		for (var i = 0; i < weight_keys.size(); i++) {
			var keys = weight_keys[i];
			for (var j = 0; j < keys.size(); j++) {
				total_weight[i] += weights[i][keys[j]];
			}
		}

		return [weights, total_weight];
	}

}