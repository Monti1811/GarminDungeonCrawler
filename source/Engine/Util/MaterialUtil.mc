import Toybox.Lang;
import Toybox.Math;

module MaterialUtil {

	public const MATERIAL_STEEL = 4000;
	public const MATERIAL_BRONZE = 4001;
	public const MATERIAL_FIRE = 4002;
	public const MATERIAL_ICE = 4003;
	public const MATERIAL_GRASS = 4004;
	public const MATERIAL_WATER = 4005;
	public const MATERIAL_GOLD = 4006;
	public const MATERIAL_DEMON = 4007;
	public const MATERIAL_BLOOD = 4008;

	// Depth at which each regular tier becomes available
	// (matches the weapon weight tiers in ItemSpecificValues)
	public const MATERIAL_OTHER_STARTS = [0, 11, 21, 31, 41, 51, 61] as Array<Number>;

	// Picks a material tier for the given depth.
	// Demon/blood use fixed growing chances, all other tiers share
	// the rest with the current tier being the most likely.
	function pickMaterialForDepth(depth as Number) as Number {
		var demon_chance = 0;
		var blood_chance = 0;
		if (depth >= $.Constants.MATERIAL_DEMON_START_DEPTH) {
			demon_chance = $.Constants.MATERIAL_DEMON_BASE_CHANCE;
		}
		if (depth >= $.Constants.MATERIAL_BLOOD_START_DEPTH) {
			blood_chance = $.Constants.MATERIAL_BLOOD_BASE_CHANCE;
			if (depth >= $.Constants.MATERIAL_SPECIAL_RAMP_DEPTH) {
				demon_chance = $.Constants.MATERIAL_DEMON_MAX_CHANCE;
				blood_chance = $.Constants.MATERIAL_BLOOD_MAX_CHANCE;
			} else {
				var steps = depth - $.Constants.MATERIAL_BLOOD_START_DEPTH;
				demon_chance = MathUtil.min(demon_chance + steps, $.Constants.MATERIAL_DEMON_MAX_CHANCE - 1);
				blood_chance = MathUtil.min(blood_chance + steps * 2, $.Constants.MATERIAL_BLOOD_MAX_CHANCE - 2);
			}
		}

		var roll = MathUtil.random(1, 100);
		if (roll <= demon_chance) {
			return MATERIAL_DEMON;
		}
		if (roll <= demon_chance + blood_chance) {
			return MATERIAL_BLOOD;
		}

		var total = 0;
		for (var i = 0; i < MATERIAL_OTHER_STARTS.size(); i++) {
			if (depth >= MATERIAL_OTHER_STARTS[i]) {
				total += i + 1;
			}
		}
		if (total <= 0) {
			return MATERIAL_STEEL;
		}
		var pick = MathUtil.random(1, total);
		for (var j = 0; j < MATERIAL_OTHER_STARTS.size(); j++) {
			if (depth >= MATERIAL_OTHER_STARTS[j]) {
				pick -= j + 1;
				if (pick <= 0) {
					return MATERIAL_STEEL + j;
				}
			}
		}
		return MATERIAL_STEEL;
	}

	// Returns the material id required to upgrade the given item,
	// or -1 if the item cannot be upgraded.
	function getMaterialForItem(item as Item) as Number {
		var item_id = item.id;

		// Crossbows follow their own tier order
		if (item_id == 300) {
			return MATERIAL_STEEL;
		}
		if (item_id == 301) {
			return MATERIAL_BRONZE;
		}
		if (item_id == 302 || item_id == 303) {
			return MATERIAL_DEMON;
		}
		// Ammunition is never upgradeable
		if (item_id >= 200 && item_id < 300) {
			return -1;
		}
		// Weapons: tier blocks of 10 (0-8 Steel ... 80-88 Blood)
		if (item_id >= 0 && item_id < 1000) {
			var tier = Math.floor(item_id / 10).toNumber();
			if (tier >= 0 && tier <= 8) {
				return MATERIAL_STEEL + tier;
			}
			return -1;
		}
		// Armors: tier blocks of 10 (1000-1008 Steel ... 1080-1088 Blood)
		if (item_id >= 1000 && item_id < 1100) {
			var tier = Math.floor((item_id - 1000) / 10).toNumber();
			if (tier >= 0 && tier <= 8) {
				return MATERIAL_STEEL + tier;
			}
			return -1;
		}
		// Shields
		if (item_id == 1200 || item_id == 1201) {
			return MATERIAL_STEEL;
		}
		if (item_id == 1202 || item_id == 1203) {
			return MATERIAL_GOLD;
		}
		// Backpacks, amulets and everything else
		return -1;
	}
}
