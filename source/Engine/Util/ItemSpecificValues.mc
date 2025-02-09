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
            // Steel Weapons
            0 => 5 + log_depth, // Steel Axe
            3 => 5 + log_depth, // Steel Greatsword
            5 => 5 + log_depth, // Steel Lance
            8 => 3 + log_depth, // Steel Sword
            // ...other steel weapons...
            // Bronze Weapons
            10 => 4 + log_depth, // Bronze Axe
            13 => 4 + log_depth, // Bronze Greatsword
            15 => 4 + log_depth, // Bronze Lance
            18 => 2 + log_depth, // Bronze Sword
            // ...other bronze weapons...
            // Fire Weapons
            20 => 3 + log_depth, // Fire Axe
            23 => 3 + log_depth, // Fire Greatsword
            25 => 3 + log_depth, // Fire Lance
            28 => 1 + log_depth, // Fire Sword
            // ...other fire weapons...
            // Ice Weapons
            30 => 2 + log_depth, // Ice Axe
            33 => 2 + log_depth, // Ice Greatsword
            35 => 2 + log_depth, // Ice Lance
            38 => 1 + log_depth, // Ice Sword
            // ...other ice weapons...
            // Grass Weapons
            40 => 1 + log_depth, // Grass Axe
            43 => 1 + log_depth, // Grass Greatsword
            45 => 1 + log_depth, // Grass Lance
            48 => 1 + log_depth, // Grass Sword
            // ...other grass weapons...
            // Water Weapons
            50 => 1 + log_depth, // Water Axe
            53 => 1 + log_depth, // Water Greatsword
            55 => 1 + log_depth, // Water Lance
            58 => 1 + log_depth, // Water Sword
            // ...other water weapons...
            // Gold Weapons
            60 => 1 + log_depth, // Gold Axe
            63 => 1 + log_depth, // Gold Greatsword
            65 => 1 + log_depth, // Gold Lance
            68 => 1 + log_depth, // Gold Sword
            // ...other gold weapons...
            // Demon Weapons
            70 => 1 + log_depth, // Demon Axe
            73 => 1 + log_depth, // Demon Greatsword
            75 => 1 + log_depth, // Demon Lance
            78 => 1 + log_depth, // Demon Sword
            // ...other demon weapons...
            // Blood Weapons
            80 => 1 + log_depth, // Blood Axe
            83 => 1 + log_depth, // Blood Greatsword
            85 => 1 + log_depth, // Blood Lance
            88 => 1 + log_depth, // Blood Sword
            // ...other blood weapons...
            // Arrows
            200 => 1 + log_depth, // Arrow
            201 => 1 + log_depth, // Fire Arrow
            202 => 1 + log_depth, // Ice Arrow
            203 => 1 + log_depth, // Gold Arrow
            // Bolts
            250 => 1 + log_depth, // Bolt
            251 => 1 + log_depth, // Fire Bolt
            252 => 1 + log_depth, // Ice Bolt
            253 => 1 + log_depth, // Gold Bolt
            // Crossbows
            300 => 1 + log_depth, // CrossBow
            301 => 1 + log_depth, // Oak CrossBow
            302 => 1 + log_depth, // Hell CrossBow
        };

        var armor_weights = {
            // Steel Armor
            1000 => 1 + sqrt_depth, // Steel Helmet
            1001 => 1 + sqrt_depth, // Steel Breastplate
            1002 => 1 + sqrt_depth, // Steel Gauntlets
            1003 => 1 + sqrt_depth, // Steel Shoes
            1004 => 2 + log_depth,  // Steel Ring1
            1005 => 2 + log_depth,  // Steel Ring2
            // ...other steel armor...
            // Bronze Armor
            1010 => 1 + sqrt_depth, // Bronze Helmet
            1011 => 1 + sqrt_depth, // Bronze Breastplate
            1012 => 1 + sqrt_depth, // Bronze Gauntlets
            1013 => 1 + sqrt_depth, // Bronze Shoes
            1014 => 2 + log_depth,  // Bronze Ring1
            1015 => 2 + log_depth,  // Bronze Ring2
            // ...other bronze armor...
            // Fire Armor
            1020 => 1 + sqrt_depth, // Fire Helmet
            1021 => 1 + sqrt_depth, // Fire Breastplate
            1022 => 1 + sqrt_depth, // Fire Gauntlets
            1023 => 1 + sqrt_depth, // Fire Shoes
            1024 => 2 + log_depth,  // Fire Ring1
            1025 => 2 + log_depth,  // Fire Ring2
            // ...other fire armor...
            // Ice Armor
            1030 => 1 + sqrt_depth, // Ice Helmet
            1031 => 1 + sqrt_depth, // Ice Breastplate
            1032 => 1 + sqrt_depth, // Ice Gauntlets
            1033 => 1 + sqrt_depth, // Ice Shoes
            1034 => 2 + log_depth,  // Ice Ring1
            1035 => 2 + log_depth,  // Ice Ring2
            // ...other ice armor...
            // Grass Armor
            1040 => 1 + sqrt_depth, // Grass Helmet
            1041 => 1 + sqrt_depth, // Grass Breastplate
            1042 => 1 + sqrt_depth, // Grass Gauntlets
            1043 => 1 + sqrt_depth, // Grass Shoes
            1044 => 2 + log_depth,  // Grass Ring1
            1045 => 2 + log_depth,  // Grass Ring2
            // ...other grass armor...
            // Water Armor
            1050 => 1 + sqrt_depth, // Water Helmet
            1051 => 1 + sqrt_depth, // Water Breastplate
            1052 => 1 + sqrt_depth, // Water Gauntlets
            1053 => 1 + sqrt_depth, // Water Shoes
            1054 => 2 + log_depth,  // Water Ring1
            1055 => 2 + log_depth,  // Water Ring2
            // ...other water armor...
            // Gold Armor
            1060 => 1 + sqrt_depth, // Gold Helmet
            1061 => 1 + sqrt_depth, // Gold Breastplate
            1062 => 1 + sqrt_depth, // Gold Gauntlets
            1063 => 1 + sqrt_depth, // Gold Shoes
            1064 => 2 + log_depth,  // Gold Ring1
            1065 => 2 + log_depth,  // Gold Ring2
            // ...other gold armor...
            // Demon Armor
            1070 => 1 + sqrt_depth, // Demon Helmet
            1071 => 1 + sqrt_depth, // Demon Breastplate
            1072 => 1 + sqrt_depth, // Demon Gauntlets
            1073 => 1 + sqrt_depth, // Demon Shoes
            1074 => 2 + log_depth,  // Demon Ring1
            1075 => 2 + log_depth,  // Demon Ring2
            // ...other demon armor...
            // Blood Armor
            1080 => 1 + sqrt_depth, // Blood Helmet
            1081 => 1 + sqrt_depth, // Blood Breastplate
            1082 => 1 + sqrt_depth, // Blood Gauntlets
            1083 => 1 + sqrt_depth, // Blood Shoes
            1084 => 2 + log_depth,  // Blood Ring1
            1085 => 2 + log_depth,  // Blood Ring2
            // ...other blood armor...
        };

        var consumable_weights = {
            // Potions
            2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
            2001 => 2 + log_depth,                    // Mana Potion
            2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
            2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
            2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
            2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
        };

        var high_quality_weights = {
            // High-Quality Items
            0 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Lance
            1004 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
            1008 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Life Amulet
            2002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
        };

        var merchant_weights = {
            // Merchant Items
            0 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Lance
            8 => isBetweenDepth(depth, 0, 10) ? 2 + sqrt_depth : 0, // Steel Sword
            1004 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
            1000 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
            1001 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
            1002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
            1003 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
            1006 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Wood Shield
            1007 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Green Backpack
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
            // Steel Weapons
            0 => 5 + log_depth, // Steel Axe
            3 => 5 + log_depth, // Steel Greatsword
            5 => 5 + log_depth, // Steel Lance
            8 => 3 + log_depth, // Steel Sword
            // ...other steel weapons...
            // Bronze Weapons
            10 => 4 + log_depth, // Bronze Axe
            13 => 4 + log_depth, // Bronze Greatsword
            15 => 4 + log_depth, // Bronze Lance
            18 => 2 + log_depth, // Bronze Sword
            // ...other bronze weapons...
            // Fire Weapons
            20 => 3 + log_depth, // Fire Axe
            23 => 3 + log_depth, // Fire Greatsword
            25 => 3 + log_depth, // Fire Lance
            28 => 1 + log_depth, // Fire Sword
            // ...other fire weapons...
            // Ice Weapons
            30 => 2 + log_depth, // Ice Axe
            33 => 2 + log_depth, // Ice Greatsword
            35 => 2 + log_depth, // Ice Lance
            38 => 1 + log_depth, // Ice Sword
            // ...other ice weapons...
            // Grass Weapons
            40 => 1 + log_depth, // Grass Axe
            43 => 1 + log_depth, // Grass Greatsword
            45 => 1 + log_depth, // Grass Lance
            48 => 1 + log_depth, // Grass Sword
            // ...other grass weapons...
            // Water Weapons
            50 => 1 + log_depth, // Water Axe
            53 => 1 + log_depth, // Water Greatsword
            55 => 1 + log_depth, // Water Lance
            58 => 1 + log_depth, // Water Sword
            // ...other water weapons...
            // Gold Weapons
            60 => 1 + log_depth, // Gold Axe
            63 => 1 + log_depth, // Gold Greatsword
            65 => 1 + log_depth, // Gold Lance
            68 => 1 + log_depth, // Gold Sword
            // ...other gold weapons...
            // Demon Weapons
            70 => 1 + log_depth, // Demon Axe
            73 => 1 + log_depth, // Demon Greatsword
            75 => 1 + log_depth, // Demon Lance
            78 => 1 + log_depth, // Demon Sword
            // ...other demon weapons...
            // Blood Weapons
            80 => 1 + log_depth, // Blood Axe
            83 => 1 + log_depth, // Blood Greatsword
            85 => 1 + log_depth, // Blood Lance
            88 => 1 + log_depth, // Blood Sword
            // ...other blood weapons...
            // Arrows
            200 => 1 + log_depth, // Arrow
            201 => 1 + log_depth, // Fire Arrow
            202 => 1 + log_depth, // Ice Arrow
            203 => 1 + log_depth, // Gold Arrow
            // Bolts
            250 => 1 + log_depth, // Bolt
            251 => 1 + log_depth, // Fire Bolt
            252 => 1 + log_depth, // Ice Bolt
            253 => 1 + log_depth, // Gold Bolt
            // Crossbows
            300 => 1 + log_depth, // CrossBow
            301 => 1 + log_depth, // Oak CrossBow
            302 => 1 + log_depth, // Hell CrossBow
        };

        var armor_weights = {
            // Steel Armor
            1000 => 1 + sqrt_depth, // Steel Helmet
            1001 => 1 + sqrt_depth, // Steel Breastplate
            1002 => 1 + sqrt_depth, // Steel Gauntlets
            1003 => 1 + sqrt_depth, // Steel Shoes
            1004 => 2 + log_depth,  // Steel Ring1
            1005 => 2 + log_depth,  // Steel Ring2
            // ...other steel armor...
            // Bronze Armor
            1010 => 1 + sqrt_depth, // Bronze Helmet
            1011 => 1 + sqrt_depth, // Bronze Breastplate
            1012 => 1 + sqrt_depth, // Bronze Gauntlets
            1013 => 1 + sqrt_depth, // Bronze Shoes
            1014 => 2 + log_depth,  // Bronze Ring1
            1015 => 2 + log_depth,  // Bronze Ring2
            // ...other bronze armor...
            // Fire Armor
            1020 => 1 + sqrt_depth, // Fire Helmet
            1021 => 1 + sqrt_depth, // Fire Breastplate
            1022 => 1 + sqrt_depth, // Fire Gauntlets
            1023 => 1 + sqrt_depth, // Fire Shoes
            1024 => 2 + log_depth,  // Fire Ring1
            1025 => 2 + log_depth,  // Fire Ring2
            // ...other fire armor...
            // Ice Armor
            1030 => 1 + sqrt_depth, // Ice Helmet
            1031 => 1 + sqrt_depth, // Ice Breastplate
            1032 => 1 + sqrt_depth, // Ice Gauntlets
            1033 => 1 + sqrt_depth, // Ice Shoes
            1034 => 2 + log_depth,  // Ice Ring1
            1035 => 2 + log_depth,  // Ice Ring2
            // ...other ice armor...
            // Grass Armor
            1040 => 1 + sqrt_depth, // Grass Helmet
            1041 => 1 + sqrt_depth, // Grass Breastplate
            1042 => 1 + sqrt_depth, // Grass Gauntlets
            1043 => 1 + sqrt_depth, // Grass Shoes
            1044 => 2 + log_depth,  // Grass Ring1
            1045 => 2 + log_depth,  // Grass Ring2
            // ...other grass armor...
            // Water Armor
            1050 => 1 + sqrt_depth, // Water Helmet
            1051 => 1 + sqrt_depth, // Water Breastplate
            1052 => 1 + sqrt_depth, // Water Gauntlets
            1053 => 1 + sqrt_depth, // Water Shoes
            1054 => 2 + log_depth,  // Water Ring1
            1055 => 2 + log_depth,  // Water Ring2
            // ...other water armor...
            // Gold Armor
            1060 => 1 + sqrt_depth, // Gold Helmet
            1061 => 1 + sqrt_depth, // Gold Breastplate
            1062 => 1 + sqrt_depth, // Gold Gauntlets
            1063 => 1 + sqrt_depth, // Gold Shoes
            1064 => 2 + log_depth,  // Gold Ring1
            1065 => 2 + log_depth,  // Gold Ring2
            // ...other gold armor...
            // Demon Armor
            1070 => 1 + sqrt_depth, // Demon Helmet
            1071 => 1 + sqrt_depth, // Demon Breastplate
            1072 => 1 + sqrt_depth, // Demon Gauntlets
            1073 => 1 + sqrt_depth, // Demon Shoes
            1074 => 2 + log_depth,  // Demon Ring1
            1075 => 2 + log_depth,  // Demon Ring2
            // ...other demon armor...
            // Blood Armor
            1080 => 1 + sqrt_depth, // Blood Helmet
            1081 => 1 + sqrt_depth, // Blood Breastplate
            1082 => 1 + sqrt_depth, // Blood Gauntlets
            1083 => 1 + sqrt_depth, // Blood Shoes
            1084 => 2 + log_depth,  // Blood Ring1
            1085 => 2 + log_depth,  // Blood Ring2
            // ...other blood armor...
        };

        var consumable_weights = {
            // Potions
            2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
            2001 => 2 + log_depth,                    // Mana Potion
            2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
            2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
            2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
            2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
        };

        var high_quality_weights = {
            // High-Quality Items
            0 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Lance
            1004 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
            1008 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Life Amulet
            2002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
        };

        var merchant_weights = {
            // Merchant Items
            0 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Lance
            8 => isBetweenDepth(depth, 0, 10) ? 2 + sqrt_depth : 0, // Steel Sword
            1004 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
            1000 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
            1001 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
            1002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
            1003 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
            1200 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Wood Shield
            1250 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Green Backpack
            1300 => depth >= 20 ? 1 + sqrt_depth : 0, // Life Amulet
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

    function getDungeonItemWeightsNameless() as [Array, Array] {
        var depth = $.Game.depth;
        var log_depth = Math.log(depth + 1, 2);
        var sqrt_depth = Math.sqrt(depth);

        var weapon_weights = {
            // Steel Weapons
            0 => 5 + log_depth, // Steel Axe
            3 => 5 + log_depth, // Steel Greatsword
            5 => 5 + log_depth, // Steel Lance
            8 => 3 + log_depth, // Steel Sword
            // ...other steel weapons...
            // Bronze Weapons
            10 => 4 + log_depth, // Bronze Axe
            13 => 4 + log_depth, // Bronze Greatsword
            15 => 4 + log_depth, // Bronze Lance
            18 => 2 + log_depth, // Bronze Sword
            // ...other bronze weapons...
            // Fire Weapons
            20 => 3 + log_depth, // Fire Axe
            23 => 3 + log_depth, // Fire Greatsword
            25 => 3 + log_depth, // Fire Lance
            28 => 1 + log_depth, // Fire Sword
            // ...other fire weapons...
            // Ice Weapons
            30 => 2 + log_depth, // Ice Axe
            33 => 2 + log_depth, // Ice Greatsword
            35 => 2 + log_depth, // Ice Lance
            38 => 1 + log_depth, // Ice Sword
            // ...other ice weapons...
            // Grass Weapons
            40 => 1 + log_depth, // Grass Axe
            43 => 1 + log_depth, // Grass Greatsword
            45 => 1 + log_depth, // Grass Lance
            48 => 1 + log_depth, // Grass Sword
            // ...other grass weapons...
            // Water Weapons
            50 => 1 + log_depth, // Water Axe
            53 => 1 + log_depth, // Water Greatsword
            55 => 1 + log_depth, // Water Lance
            58 => 1 + log_depth, // Water Sword
            // ...other water weapons...
            // Gold Weapons
            60 => 1 + log_depth, // Gold Axe
            63 => 1 + log_depth, // Gold Greatsword
            65 => 1 + log_depth, // Gold Lance
            68 => 1 + log_depth, // Gold Sword
            // ...other gold weapons...
            // Demon Weapons
            70 => 1 + log_depth, // Demon Axe
            73 => 1 + log_depth, // Demon Greatsword
            75 => 1 + log_depth, // Demon Lance
            78 => 1 + log_depth, // Demon Sword
            // ...other demon weapons...
            // Blood Weapons
            80 => 1 + log_depth, // Blood Axe
            83 => 1 + log_depth, // Blood Greatsword
            85 => 1 + log_depth, // Blood Lance
            88 => 1 + log_depth, // Blood Sword
            // ...other blood weapons...
            // Arrows
            200 => 1 + log_depth, // Arrow
            201 => 1 + log_depth, // Fire Arrow
            202 => 1 + log_depth, // Ice Arrow
            203 => 1 + log_depth, // Gold Arrow
            // Bolts
            250 => 1 + log_depth, // Bolt
            251 => 1 + log_depth, // Fire Bolt
            252 => 1 + log_depth, // Ice Bolt
            253 => 1 + log_depth, // Gold Bolt
            // Crossbows
            300 => 1 + log_depth, // CrossBow
            301 => 1 + log_depth, // Oak CrossBow
            302 => 1 + log_depth, // Hell CrossBow
        };

        var armor_weights = {
            // Steel Armor
            1000 => 1 + sqrt_depth, // Steel Helmet
            1001 => 1 + sqrt_depth, // Steel Breastplate
            1002 => 1 + sqrt_depth, // Steel Gauntlets
            1003 => 1 + sqrt_depth, // Steel Shoes
            1004 => 2 + log_depth,  // Steel Ring1
            1005 => 2 + log_depth,  // Steel Ring2
            // ...other steel armor...
            // Bronze Armor
            1010 => 1 + sqrt_depth, // Bronze Helmet
            1011 => 1 + sqrt_depth, // Bronze Breastplate
            1012 => 1 + sqrt_depth, // Bronze Gauntlets
            1013 => 1 + sqrt_depth, // Bronze Shoes
            1014 => 2 + log_depth,  // Bronze Ring1
            1015 => 2 + log_depth,  // Bronze Ring2
            // ...other bronze armor...
            // Fire Armor
            1020 => 1 + sqrt_depth, // Fire Helmet
            1021 => 1 + sqrt_depth, // Fire Breastplate
            1022 => 1 + sqrt_depth, // Fire Gauntlets
            1023 => 1 + sqrt_depth, // Fire Shoes
            1024 => 2 + log_depth,  // Fire Ring1
            1025 => 2 + log_depth,  // Fire Ring2
            // ...other fire armor...
            // Ice Armor
            1030 => 1 + sqrt_depth, // Ice Helmet
            1031 => 1 + sqrt_depth, // Ice Breastplate
            1032 => 1 + sqrt_depth, // Ice Gauntlets
            1033 => 1 + sqrt_depth, // Ice Shoes
            1034 => 2 + log_depth,  // Ice Ring1
            1035 => 2 + log_depth,  // Ice Ring2
            // ...other ice armor...
            // Grass Armor
            1040 => 1 + sqrt_depth, // Grass Helmet
            1041 => 1 + sqrt_depth, // Grass Breastplate
            1042 => 1 + sqrt_depth, // Grass Gauntlets
            1043 => 1 + sqrt_depth, // Grass Shoes
            1044 => 2 + log_depth,  // Grass Ring1
            1045 => 2 + log_depth,  // Grass Ring2
            // ...other grass armor...
            // Water Armor
            1050 => 1 + sqrt_depth, // Water Helmet
            1051 => 1 + sqrt_depth, // Water Breastplate
            1052 => 1 + sqrt_depth, // Water Gauntlets
            1053 => 1 + sqrt_depth, // Water Shoes
            1054 => 2 + log_depth,  // Water Ring1
            1055 => 2 + log_depth,  // Water Ring2
            // ...other water armor...
            // Gold Armor
            1060 => 1 + sqrt_depth, // Gold Helmet
            1061 => 1 + sqrt_depth, // Gold Breastplate
            1062 => 1 + sqrt_depth, // Gold Gauntlets
            1063 => 1 + sqrt_depth, // Gold Shoes
            1064 => 2 + log_depth,  // Gold Ring1
            1065 => 2 + log_depth,  // Gold Ring2
            // ...other gold armor...
            // Demon Armor
            1070 => 1 + sqrt_depth, // Demon Helmet
            1071 => 1 + sqrt_depth, // Demon Breastplate
            1072 => 1 + sqrt_depth, // Demon Gauntlets
            1073 => 1 + sqrt_depth, // Demon Shoes
            1074 => 2 + log_depth,  // Demon Ring1
            1075 => 2 + log_depth,  // Demon Ring2
            // ...other demon armor...
            // Blood Armor
            1080 => 1 + sqrt_depth, // Blood Helmet
            1081 => 1 + sqrt_depth, // Blood Breastplate
            1082 => 1 + sqrt_depth, // Blood Gauntlets
            1083 => 1 + sqrt_depth, // Blood Shoes
            1084 => 2 + log_depth,  // Blood Ring1
            1085 => 2 + log_depth,  // Blood Ring2
            // ...other blood armor...
        };

        var consumable_weights = {
            // Potions
            2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
            2001 => 2 + log_depth,                    // Mana Potion
            2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
            2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
            2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
            2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
        };

        var high_quality_weights = {
            // High-Quality Items
            0 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Lance
            1004 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
            1008 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Life Amulet
            2002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
        };

        var merchant_weights = {
            // Merchant Items
            0 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Lance
            8 => isBetweenDepth(depth, 0, 10) ? 2 + sqrt_depth : 0, // Steel Sword
            1004 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
            1000 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
            1001 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
            1002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
            1003 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
            1200 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Wood Shield
            1250 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Green Backpack
            1300 => depth >= 20 ? 1 + sqrt_depth : 0, // Life Amulet
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
            // Steel Weapons
            0 => 5 + log_depth, // Steel Axe
            3 => 5 + log_depth, // Steel Greatsword
            5 => 5 + log_depth, // Steel Lance
            8 => 3 + log_depth, // Steel Sword
            // ...other steel weapons...
            // Bronze Weapons
            10 => 4 + log_depth, // Bronze Axe
            13 => 4 + log_depth, // Bronze Greatsword
            15 => 4 + log_depth, // Bronze Lance
            18 => 2 + log_depth, // Bronze Sword
            // ...other bronze weapons...
            // Fire Weapons
            20 => 3 + log_depth, // Fire Axe
            23 => 3 + log_depth, // Fire Greatsword
            25 => 3 + log_depth, // Fire Lance
            28 => 1 + log_depth, // Fire Sword
            // ...other fire weapons...
            // Ice Weapons
            30 => 2 + log_depth, // Ice Axe
            33 => 2 + log_depth, // Ice Greatsword
            35 => 2 + log_depth, // Ice Lance
            38 => 1 + log_depth, // Ice Sword
            // ...other ice weapons...
            // Grass Weapons
            40 => 1 + log_depth, // Grass Axe
            43 => 1 + log_depth, // Grass Greatsword
            45 => 1 + log_depth, // Grass Lance
            48 => 1 + log_depth, // Grass Sword
            // ...other grass weapons...
            // Water Weapons
            50 => 1 + log_depth, // Water Axe
            53 => 1 + log_depth, // Water Greatsword
            55 => 1 + log_depth, // Water Lance
            58 => 1 + log_depth, // Water Sword
            // ...other water weapons...
            // Gold Weapons
            60 => 1 + log_depth, // Gold Axe
            63 => 1 + log_depth, // Gold Greatsword
            65 => 1 + log_depth, // Gold Lance
            68 => 1 + log_depth, // Gold Sword
            // ...other gold weapons...
            // Demon Weapons
            70 => 1 + log_depth, // Demon Axe
            73 => 1 + log_depth, // Demon Greatsword
            75 => 1 + log_depth, // Demon Lance
            78 => 1 + log_depth, // Demon Sword
            // ...other demon weapons...
            // Blood Weapons
            80 => 1 + log_depth, // Blood Axe
            83 => 1 + log_depth, // Blood Greatsword
            85 => 1 + log_depth, // Blood Lance
            88 => 1 + log_depth, // Blood Sword
            // ...other blood weapons...
            // Arrows
            200 => 1 + log_depth, // Arrow
            201 => 1 + log_depth, // Fire Arrow
            202 => 1 + log_depth, // Ice Arrow
            203 => 1 + log_depth, // Gold Arrow
            // Bolts
            250 => 1 + log_depth, // Bolt
            251 => 1 + log_depth, // Fire Bolt
            252 => 1 + log_depth, // Ice Bolt
            253 => 1 + log_depth, // Gold Bolt
            // Crossbows
            300 => 1 + log_depth, // CrossBow
            301 => 1 + log_depth, // Oak CrossBow
            302 => 1 + log_depth, // Hell CrossBow
        };

        var armor_weights = {
            // Steel Armor
            1000 => 1 + sqrt_depth, // Steel Helmet
            1001 => 1 + sqrt_depth, // Steel Breastplate
            1002 => 1 + sqrt_depth, // Steel Gauntlets
            1003 => 1 + sqrt_depth, // Steel Shoes
            1004 => 2 + log_depth,  // Steel Ring1
            1005 => 2 + log_depth,  // Steel Ring2
            // ...other steel armor...
            // Bronze Armor
            1010 => 1 + sqrt_depth, // Bronze Helmet
            1011 => 1 + sqrt_depth, // Bronze Breastplate
            1012 => 1 + sqrt_depth, // Bronze Gauntlets
            1013 => 1 + sqrt_depth, // Bronze Shoes
            1014 => 2 + log_depth,  // Bronze Ring1
            1015 => 2 + log_depth,  // Bronze Ring2
            // ...other bronze armor...
            // Fire Armor
            1020 => 1 + sqrt_depth, // Fire Helmet
            1021 => 1 + sqrt_depth, // Fire Breastplate
            1022 => 1 + sqrt_depth, // Fire Gauntlets
            1023 => 1 + sqrt_depth, // Fire Shoes
            1024 => 2 + log_depth,  // Fire Ring1
            1025 => 2 + log_depth,  // Fire Ring2
            // ...other fire armor...
            // Ice Armor
            1030 => 1 + sqrt_depth, // Ice Helmet
            1031 => 1 + sqrt_depth, // Ice Breastplate
            1032 => 1 + sqrt_depth, // Ice Gauntlets
            1033 => 1 + sqrt_depth, // Ice Shoes
            1034 => 2 + log_depth,  // Ice Ring1
            1035 => 2 + log_depth,  // Ice Ring2
            // ...other ice armor...
            // Grass Armor
            1040 => 1 + sqrt_depth, // Grass Helmet
            1041 => 1 + sqrt_depth, // Grass Breastplate
            1042 => 1 + sqrt_depth, // Grass Gauntlets
            1043 => 1 + sqrt_depth, // Grass Shoes
            1044 => 2 + log_depth,  // Grass Ring1
            1045 => 2 + log_depth,  // Grass Ring2
            // ...other grass armor...
            // Water Armor
            1050 => 1 + sqrt_depth, // Water Helmet
            1051 => 1 + sqrt_depth, // Water Breastplate
            1052 => 1 + sqrt_depth, // Water Gauntlets
            1053 => 1 + sqrt_depth, // Water Shoes
            1054 => 2 + log_depth,  // Water Ring1
            1055 => 2 + log_depth,  // Water Ring2
            // ...other water armor...
            // Gold Armor
            1060 => 1 + sqrt_depth, // Gold Helmet
            1061 => 1 + sqrt_depth, // Gold Breastplate
            1062 => 1 + sqrt_depth, // Gold Gauntlets
            1063 => 1 + sqrt_depth, // Gold Shoes
            1064 => 2 + log_depth,  // Gold Ring1
            1065 => 2 + log_depth,  // Gold Ring2
            // ...other gold armor...
            // Demon Armor
            1070 => 1 + sqrt_depth, // Demon Helmet
            1071 => 1 + sqrt_depth, // Demon Breastplate
            1072 => 1 + sqrt_depth, // Demon Gauntlets
            1073 => 1 + sqrt_depth, // Demon Shoes
            1074 => 2 + log_depth,  // Demon Ring1
            1075 => 2 + log_depth,  // Demon Ring2
            // ...other demon armor...
            // Blood Armor
            1080 => 1 + sqrt_depth, // Blood Helmet
            1081 => 1 + sqrt_depth, // Blood Breastplate
            1082 => 1 + sqrt_depth, // Blood Gauntlets
            1083 => 1 + sqrt_depth, // Blood Shoes
            1084 => 2 + log_depth,  // Blood Ring1
            1085 => 2 + log_depth,  // Blood Ring2
            // ...other blood armor...
        };

        var consumable_weights = {
            // Potions
            2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
            2001 => 2 + log_depth,                    // Mana Potion
            2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
            2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
            2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
            2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
        };

        var high_quality_weights = {
            // High-Quality Items
            0 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Lance
            1004 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
            1008 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Life Amulet
            2002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
        };

        var merchant_weights = {
            // Merchant Items
            0 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Lance
            8 => isBetweenDepth(depth, 0, 10) ? 2 + sqrt_depth : 0, // Steel Sword
            1004 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
            1000 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
            1001 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
            1002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
            1003 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
            1006 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Wood Shield
            1007 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Green Backpack
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
        var log_depth = Math.log(depth + 1, 2);
        var sqrt_depth = Math.sqrt(depth);

        var weapon_weights = {
            // Steel Weapons
            0 => 5 + log_depth, // Steel Axe
            3 => 5 + log_depth, // Steel Greatsword
            5 => 5 + log_depth, // Steel Lance
            8 => 3 + log_depth, // Steel Sword
            // ...other steel weapons...
            // Bronze Weapons
            10 => 4 + log_depth, // Bronze Axe
            13 => 4 + log_depth, // Bronze Greatsword
            15 => 4 + log_depth, // Bronze Lance
            18 => 2 + log_depth, // Bronze Sword
            // ...other bronze weapons...
            // Fire Weapons
            20 => 3 + log_depth, // Fire Axe
            23 => 3 + log_depth, // Fire Greatsword
            25 => 3 + log_depth, // Fire Lance
            28 => 1 + log_depth, // Fire Sword
            // ...other fire weapons...
            // Ice Weapons
            30 => 2 + log_depth, // Ice Axe
            33 => 2 + log_depth, // Ice Greatsword
            35 => 2 + log_depth, // Ice Lance
            38 => 1 + log_depth, // Ice Sword
            // ...other ice weapons...
            // Grass Weapons
            40 => 1 + log_depth, // Grass Axe
            43 => 1 + log_depth, // Grass Greatsword
            45 => 1 + log_depth, // Grass Lance
            48 => 1 + log_depth, // Grass Sword
            // ...other grass weapons...
            // Water Weapons
            50 => 1 + log_depth, // Water Axe
            53 => 1 + log_depth, // Water Greatsword
            55 => 1 + log_depth, // Water Lance
            58 => 1 + log_depth, // Water Sword
            // ...other water weapons...
            // Gold Weapons
            60 => 1 + log_depth, // Gold Axe
            63 => 1 + log_depth, // Gold Greatsword
            65 => 1 + log_depth, // Gold Lance
            68 => 1 + log_depth, // Gold Sword
            // ...other gold weapons...
            // Demon Weapons
            70 => 1 + log_depth, // Demon Axe
            73 => 1 + log_depth, // Demon Greatsword
            75 => 1 + log_depth, // Demon Lance
            78 => 1 + log_depth, // Demon Sword
            // ...other demon weapons...
            // Blood Weapons
            80 => 1 + log_depth, // Blood Axe
            83 => 1 + log_depth, // Blood Greatsword
            85 => 1 + log_depth, // Blood Lance
            88 => 1 + log_depth, // Blood Sword
            // ...other blood weapons...
            // Arrows
            200 => 1 + log_depth, // Arrow
            201 => 1 + log_depth, // Fire Arrow
            202 => 1 + log_depth, // Ice Arrow
            203 => 1 + log_depth, // Gold Arrow
            // Bolts
            250 => 1 + log_depth, // Bolt
            251 => 1 + log_depth, // Fire Bolt
            252 => 1 + log_depth, // Ice Bolt
            253 => 1 + log_depth, // Gold Bolt
            // Crossbows
            300 => 1 + log_depth, // CrossBow
            301 => 1 + log_depth, // Oak CrossBow
            302 => 1 + log_depth, // Hell CrossBow
        };

        var armor_weights = {
            // Steel Armor
            1000 => 1 + sqrt_depth, // Steel Helmet
            1001 => 1 + sqrt_depth, // Steel Breastplate
            1002 => 1 + sqrt_depth, // Steel Gauntlets
            1003 => 1 + sqrt_depth, // Steel Shoes
            1004 => 2 + log_depth,  // Steel Ring1
            1005 => 2 + log_depth,  // Steel Ring2
            // ...other steel armor...
            // Bronze Armor
            1010 => 1 + sqrt_depth, // Bronze Helmet
            1011 => 1 + sqrt_depth, // Bronze Breastplate
            1012 => 1 + sqrt_depth, // Bronze Gauntlets
            1013 => 1 + sqrt_depth, // Bronze Shoes
            1014 => 2 + log_depth,  // Bronze Ring1
            1015 => 2 + log_depth,  // Bronze Ring2
            // ...other bronze armor...
            // Fire Armor
            1020 => 1 + sqrt_depth, // Fire Helmet
            1021 => 1 + sqrt_depth, // Fire Breastplate
            1022 => 1 + sqrt_depth, // Fire Gauntlets
            1023 => 1 + sqrt_depth, // Fire Shoes
            1024 => 2 + log_depth,  // Fire Ring1
            1025 => 2 + log_depth,  // Fire Ring2
            // ...other fire armor...
            // Ice Armor
            1030 => 1 + sqrt_depth, // Ice Helmet
            1031 => 1 + sqrt_depth, // Ice Breastplate
            1032 => 1 + sqrt_depth, // Ice Gauntlets
            1033 => 1 + sqrt_depth, // Ice Shoes
            1034 => 2 + log_depth,  // Ice Ring1
            1035 => 2 + log_depth,  // Ice Ring2
            // ...other ice armor...
            // Grass Armor
            1040 => 1 + sqrt_depth, // Grass Helmet
            1041 => 1 + sqrt_depth, // Grass Breastplate
            1042 => 1 + sqrt_depth, // Grass Gauntlets
            1043 => 1 + sqrt_depth, // Grass Shoes
            1044 => 2 + log_depth,  // Grass Ring1
            1045 => 2 + log_depth,  // Grass Ring2
            // ...other grass armor...
            // Water Armor
            1050 => 1 + sqrt_depth, // Water Helmet
            1051 => 1 + sqrt_depth, // Water Breastplate
            1052 => 1 + sqrt_depth, // Water Gauntlets
            1053 => 1 + sqrt_depth, // Water Shoes
            1054 => 2 + log_depth,  // Water Ring1
            1055 => 2 + log_depth,  // Water Ring2
            // ...other water armor...
            // Gold Armor
            1060 => 1 + sqrt_depth, // Gold Helmet
            1061 => 1 + sqrt_depth, // Gold Breastplate
            1062 => 1 + sqrt_depth, // Gold Gauntlets
            1063 => 1 + sqrt_depth, // Gold Shoes
            1064 => 2 + log_depth,  // Gold Ring1
            1065 => 2 + log_depth,  // Gold Ring2
            // ...other gold armor...
            // Demon Armor
            1070 => 1 + sqrt_depth, // Demon Helmet
            1071 => 1 + sqrt_depth, // Demon Breastplate
            1072 => 1 + sqrt_depth, // Demon Gauntlets
            1073 => 1 + sqrt_depth, // Demon Shoes
            1074 => 2 + log_depth,  // Demon Ring1
            1075 => 2 + log_depth,  // Demon Ring2
            // ...other demon armor...
            // Blood Armor
            1080 => 1 + sqrt_depth, // Blood Helmet
            1081 => 1 + sqrt_depth, // Blood Breastplate
            1082 => 1 + sqrt_depth, // Blood Gauntlets
            1083 => 1 + sqrt_depth, // Blood Shoes
            1084 => 2 + log_depth,  // Blood Ring1
            1085 => 2 + log_depth,  // Blood Ring2
            // ...other blood armor...
        };

        var consumable_weights = {
            // Potions
            2000 => depth <= 20 ? 3 : 1 / sqrt_depth, // Health Potion
            2001 => 2 + log_depth,                    // Mana Potion
            2002 => depth >= 10 ? 4 + sqrt_depth : 0, // Greater Health Potion
            2003 => depth >= 10 ? 2 + sqrt_depth : 0, // Greater Mana Potion
            2004 => depth >= 50 ? 3 + log_depth : 0,  // Max Health Potion
            2005 => depth >= 50 ? 2 + log_depth : 0,  // Max Mana Potion
        };

        var high_quality_weights = {
            // High-Quality Items
            0 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Lance
            1004 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Ring2
            1008 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Life Amulet
            2002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Greater Health Potion
        };

        var merchant_weights = {
            // Merchant Items
            0 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Axe
            3 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Greatsword
            5 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Lance
            8 => isBetweenDepth(depth, 0, 10) ? 2 + sqrt_depth : 0, // Steel Sword
            1004 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring1
            1005 => isBetweenDepth(depth, 0, 10) ? 3 + sqrt_depth : 0, // Steel Ring2
            1000 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Helmet
            1001 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Breastplate
            1002 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Gauntlets
            1003 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Steel Shoes
            1006 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Wood Shield
            1007 => isBetweenDepth(depth, 0, 10) ? 1 + sqrt_depth : 0, // Green Backpack
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

}