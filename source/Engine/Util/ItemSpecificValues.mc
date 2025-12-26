import Toybox.Lang;

class ItemSpecificValues {

    var _player_id as Number;

    function initialize(player_id as Number) {
        _player_id = player_id;
    }

    function getDungeonItemWeights() as [Array, Array] {
        return getDungeonItemWeightsForClass(_player_id);
    }

    function getDungeonItemWeightsForClass(class_id as Number) as [Array, Array] {
        var depth = $.Game.depth;
        var base = getBaseItemWeights(depth);
        var multipliers = getClassItemMultipliers(class_id);
        var adjusted = applyItemMultipliers(base, multipliers);
        var totals = computeTotals(adjusted);
        return [adjusted, totals];
    }

    private function getBaseItemWeights(depth as Number) as Array<Dictionary<Number, Numeric>> {
        var weapon_weights = buildWeaponWeights(depth);
        var armor_weights = buildArmorWeights(depth);
        var consumable_weights = buildConsumableWeights(depth);
        var high_quality_weights = buildHighQualityWeights(depth, consumable_weights);
        var merchant_weights = buildMerchantWeights(depth);

        var itemWeights = new Array<Dictionary<Number, Numeric>>[5];
        itemWeights[0] = weapon_weights;
        itemWeights[1] = armor_weights;
        itemWeights[2] = consumable_weights;
        itemWeights[3] = high_quality_weights;
        itemWeights[4] = merchant_weights;
        return itemWeights;
    }

    private function buildWeaponWeights(depth as Number) as Dictionary<Number, Numeric> {
        var steel_weight = tieredWeight(depth, [ { :max => 6, :weight => 12 }, { :max => 12, :weight => 9 }, { :max => 18, :weight => 5 }, { :max => 999, :weight => 2 } ]);
        var bronze_weight = tieredWeight(depth, [ { :max => 4, :weight => 6 }, { :max => 10, :weight => 10 }, { :max => 18, :weight => 7 }, { :max => 999, :weight => 3 } ]);
        var fire_weight = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 7 }, { :max => 22, :weight => 8 }, { :max => 999, :weight => 6 } ]);
        var ice_weight = fire_weight;
        var grass_weight = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 6 }, { :max => 22, :weight => 7 }, { :max => 999, :weight => 5 } ]);
        var water_weight = grass_weight;
        var gold_weight = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 26, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var demon_weight = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 7 } ]);
        var blood_weight = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 4 }, { :max => 999, :weight => 7 } ]);

        var arrow_weight = tieredWeight(depth, [ { :max => 5, :weight => 8 }, { :max => 12, :weight => 10 }, { :max => 999, :weight => 12 } ]);
        var elemental_arrow_weight = tieredWeight(depth, [ { :max => 7, :weight => 0 }, { :max => 14, :weight => 6 }, { :max => 22, :weight => 8 }, { :max => 999, :weight => 8 } ]);
        var bolt_weight = arrow_weight;
        var elemental_bolt_weight = elemental_arrow_weight;

        var crossbow_weight = tieredWeight(depth, [ { :max => 6, :weight => 0 }, { :max => 12, :weight => 6 }, { :max => 20, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var oak_crossbow_weight = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 6 }, { :max => 24, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var hell_crossbow_weight = tieredWeight(depth, [ { :max => 14, :weight => 0 }, { :max => 22, :weight => 5 }, { :max => 999, :weight => 7 } ]);

        return {
            // Steel Weapons
            0 => steel_weight,
            1 => steel_weight,
            2 => steel_weight,
            3 => steel_weight,
            4 => steel_weight,
            5 => steel_weight,
            6 => steel_weight,
            7 => steel_weight,
            8 => steel_weight,
            // Bronze Weapons
            10 => bronze_weight,
            11 => bronze_weight,
            12 => bronze_weight,
            13 => bronze_weight,
            14 => bronze_weight,
            15 => bronze_weight,
            16 => bronze_weight,
            17 => bronze_weight,
            18 => bronze_weight,
            // Fire Weapons
            20 => fire_weight,
            21 => fire_weight,
            22 => fire_weight,
            23 => fire_weight,
            24 => fire_weight,
            25 => fire_weight,
            26 => fire_weight,
            27 => fire_weight,
            28 => fire_weight,
            // Ice Weapons
            30 => ice_weight,
            31 => ice_weight,
            32 => ice_weight,
            33 => ice_weight,
            34 => ice_weight,
            35 => ice_weight,
            36 => ice_weight,
            37 => ice_weight,
            38 => ice_weight,
            // Grass Weapons
            40 => grass_weight,
            41 => grass_weight,
            42 => grass_weight,
            43 => grass_weight,
            44 => grass_weight,
            45 => grass_weight,
            46 => grass_weight,
            47 => grass_weight,
            48 => grass_weight,
            // Water Weapons
            50 => water_weight,
            51 => water_weight,
            52 => water_weight,
            53 => water_weight,
            54 => water_weight,
            55 => water_weight,
            56 => water_weight,
            57 => water_weight,
            58 => water_weight,
            // Gold Weapons
            60 => gold_weight,
            61 => gold_weight,
            62 => gold_weight,
            63 => gold_weight,
            64 => gold_weight,
            65 => gold_weight,
            66 => gold_weight,
            67 => gold_weight,
            68 => gold_weight,
            // Demon Weapons
            70 => demon_weight,
            71 => demon_weight,
            72 => demon_weight,
            73 => demon_weight,
            74 => demon_weight,
            75 => demon_weight,
            76 => demon_weight,
            77 => demon_weight,
            78 => demon_weight,
            // Blood Weapons
            80 => blood_weight,
            81 => blood_weight,
            82 => blood_weight,
            83 => blood_weight,
            84 => blood_weight,
            85 => blood_weight,
            86 => blood_weight,
            87 => blood_weight,
            88 => blood_weight,
            // Arrows
            200 => arrow_weight,
            201 => elemental_arrow_weight,
            202 => elemental_arrow_weight,
            203 => elemental_arrow_weight,
            // Bolts
            250 => bolt_weight,
            251 => elemental_bolt_weight,
            252 => elemental_bolt_weight,
            253 => elemental_bolt_weight,
            // Crossbows
            300 => crossbow_weight,
            301 => oak_crossbow_weight,
            302 => hell_crossbow_weight
        } as Dictionary<Number, Numeric>;
    }

    private function buildArmorWeights(depth as Number) as Dictionary<Number, Numeric> {
        var steel_armor = tieredWeight(depth, [ { :max => 6, :weight => 10 }, { :max => 12, :weight => 8 }, { :max => 18, :weight => 5 }, { :max => 999, :weight => 3 } ]);
        var steel_ring = tieredWeight(depth, [ { :max => 6, :weight => 8 }, { :max => 12, :weight => 7 }, { :max => 18, :weight => 6 }, { :max => 999, :weight => 4 } ]);
        var bronze_armor = tieredWeight(depth, [ { :max => 4, :weight => 6 }, { :max => 10, :weight => 9 }, { :max => 18, :weight => 7 }, { :max => 999, :weight => 3 } ]);
        var bronze_ring = tieredWeight(depth, [ { :max => 4, :weight => 6 }, { :max => 10, :weight => 7 }, { :max => 18, :weight => 6 }, { :max => 999, :weight => 3 } ]);
        var elemental_armor = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 6 }, { :max => 22, :weight => 8 }, { :max => 999, :weight => 6 } ]);
        var elemental_ring = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 5 }, { :max => 22, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var gold_armor = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 5 }, { :max => 26, :weight => 8 }, { :max => 999, :weight => 7 } ]);
        var gold_ring = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 26, :weight => 7 }, { :max => 999, :weight => 7 } ]);
        var demon_armor = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 5 }, { :max => 999, :weight => 8 } ]);
        var demon_ring = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 7 } ]);
        var blood_armor = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 5 }, { :max => 999, :weight => 8 } ]);
        var blood_ring = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 4 }, { :max => 999, :weight => 7 } ]);

        var armor_weights = {
            // Steel Armor
            1000 => steel_armor,
            1001 => steel_armor,
            1002 => steel_armor,
            1003 => steel_armor,
            1004 => steel_ring,
            1005 => steel_ring,
            // Bronze Armor
            1010 => bronze_armor,
            1011 => bronze_armor,
            1012 => bronze_armor,
            1013 => bronze_armor,
            1014 => bronze_ring,
            1015 => bronze_ring,
            // Fire Armor
            1020 => elemental_armor,
            1021 => elemental_armor,
            1022 => elemental_armor,
            1023 => elemental_armor,
            1024 => elemental_ring,
            1025 => elemental_ring,
            // Ice Armor
            1030 => elemental_armor,
            1031 => elemental_armor,
            1032 => elemental_armor,
            1033 => elemental_armor,
            1034 => elemental_ring,
            1035 => elemental_ring,
            // Grass Armor
            1040 => elemental_armor,
            1041 => elemental_armor,
            1042 => elemental_armor,
            1043 => elemental_armor,
            1044 => elemental_ring,
            1045 => elemental_ring,
            // Water Armor
            1050 => elemental_armor,
            1051 => elemental_armor,
            1052 => elemental_armor,
            1053 => elemental_armor,
            1054 => elemental_ring,
            1055 => elemental_ring,
            // Gold Armor
            1060 => gold_armor,
            1061 => gold_armor,
            1062 => gold_armor,
            1063 => gold_armor,
            1064 => gold_ring,
            1065 => gold_ring,
            // Demon Armor
            1070 => demon_armor,
            1071 => demon_armor,
            1072 => demon_armor,
            1073 => demon_armor,
            1074 => demon_ring,
            1075 => demon_ring,
            // Blood Armor
            1080 => blood_armor,
            1081 => blood_armor,
            1082 => blood_armor,
            1083 => blood_armor,
            1084 => blood_ring,
            1085 => blood_ring,
            // Shields
            1200 => tieredWeight(depth, [ { :max => 6, :weight => 6 }, { :max => 12, :weight => 3 }, { :max => 999, :weight => 0 } ]),
            1201 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 6 }, { :max => 22, :weight => 5 }, { :max => 999, :weight => 3 } ]),
            1202 => tieredWeight(depth, [ { :max => 10, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 999, :weight => 4 } ]),
            1203 => tieredWeight(depth, [ { :max => 14, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 5 } ]),
            // Backpacks
            1250 => tieredWeight(depth, [ { :max => 8, :weight => 6 }, { :max => 999, :weight => 3 } ]),
            1251 => tieredWeight(depth, [ { :max => 10, :weight => 0 }, { :max => 18, :weight => 5 }, { :max => 999, :weight => 6 } ]),
            1252 => tieredWeight(depth, [ { :max => 14, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 6 } ]),
            // Accessories
            1300 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 4 }, { :max => 999, :weight => 6 } ]),
            1301 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 6 }, { :max => 999, :weight => 7 } ])
        };
        return armor_weights;
    }

    private function buildConsumableWeights(depth as Number) as Dictionary<Number, Numeric> {
        return {
            2000 => tieredWeight(depth, [ { :max => 8, :weight => 8 }, { :max => 18, :weight => 6 }, { :max => 30, :weight => 4 }, { :max => 999, :weight => 3 } ]),
            2001 => tieredWeight(depth, [ { :max => 8, :weight => 5 }, { :max => 18, :weight => 7 }, { :max => 30, :weight => 6 }, { :max => 999, :weight => 5 } ]),
            2002 => tieredWeight(depth, [ { :max => 9, :weight => 0 }, { :max => 18, :weight => 6 }, { :max => 30, :weight => 7 }, { :max => 999, :weight => 6 } ]),
            2003 => tieredWeight(depth, [ { :max => 9, :weight => 0 }, { :max => 18, :weight => 5 }, { :max => 30, :weight => 6 }, { :max => 999, :weight => 6 } ]),
            2004 => tieredWeight(depth, [ { :max => 39, :weight => 0 }, { :max => 60, :weight => 5 }, { :max => 999, :weight => 6 } ]),
            2005 => tieredWeight(depth, [ { :max => 39, :weight => 0 }, { :max => 60, :weight => 5 }, { :max => 999, :weight => 6 } ]),
            3000 => tieredWeight(depth, [ { :max => 8, :weight => 7 }, { :max => 20, :weight => 6 }, { :max => 999, :weight => 5 } ]),
            5000 => 8 + Math.log(depth + 1, 2)
        } as Dictionary<Number, Numeric>;
    }

    private function buildHighQualityWeights(depth as Number, consumable_weights as Dictionary<Number, Numeric>) as Dictionary<Number, Numeric> {
        var fire_weight = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 7 }, { :max => 22, :weight => 8 }, { :max => 999, :weight => 6 } ]);
        var ice_weight = fire_weight;
        var gold_weight = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 26, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var demon_weight = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 7 } ]);
        var blood_weight = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 4 }, { :max => 999, :weight => 7 } ]);

        var steel_ring = tieredWeight(depth, [ { :max => 6, :weight => 8 }, { :max => 12, :weight => 7 }, { :max => 18, :weight => 6 }, { :max => 999, :weight => 4 } ]);
        var elemental_ring = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 5 }, { :max => 22, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var gold_ring = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 26, :weight => 7 }, { :max => 999, :weight => 7 } ]);
        var demon_ring = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 7 } ]);
        var blood_ring = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 4 }, { :max => 999, :weight => 7 } ]);

        return {
            23 => fire_weight / 2,
            25 => fire_weight / 2,
            28 => fire_weight / 2,
            33 => ice_weight / 2,
            35 => ice_weight / 2,
            38 => ice_weight / 2,
            63 => gold_weight / 2,
            65 => gold_weight / 2,
            68 => gold_weight / 2,
            73 => demon_weight / 2,
            75 => demon_weight / 2,
            78 => demon_weight / 2,
            83 => blood_weight / 2,
            85 => blood_weight / 2,
            88 => blood_weight / 2,
            1004 => steel_ring / 2,
            1005 => steel_ring / 2,
            1024 => elemental_ring / 2,
            1025 => elemental_ring / 2,
            1034 => elemental_ring / 2,
            1035 => elemental_ring / 2,
            1064 => gold_ring / 2,
            1065 => gold_ring / 2,
            1074 => demon_ring / 2,
            1075 => demon_ring / 2,
            1084 => blood_ring / 2,
            1085 => blood_ring / 2,
            1300 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 2 }, { :max => 999, :weight => 3 } ]),
            1301 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 3 }, { :max => 999, :weight => 4 } ]),
            2003 => consumable_weights[2003] / 2,
            2004 => consumable_weights[2004] / 2,
            2005 => consumable_weights[2005] / 2
        } as Dictionary<Number, Numeric>;
    }

    private function buildMerchantWeights(depth as Number) as Dictionary<Number, Numeric> {
        var steel_weight = tieredWeight(depth, [ { :max => 6, :weight => 12 }, { :max => 12, :weight => 9 }, { :max => 18, :weight => 5 }, { :max => 999, :weight => 2 } ]);
        var bronze_weight = tieredWeight(depth, [ { :max => 4, :weight => 6 }, { :max => 10, :weight => 10 }, { :max => 18, :weight => 7 }, { :max => 999, :weight => 3 } ]);
        var fire_weight = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 7 }, { :max => 22, :weight => 8 }, { :max => 999, :weight => 6 } ]);
        var ice_weight = fire_weight;
        var grass_weight = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 6 }, { :max => 22, :weight => 7 }, { :max => 999, :weight => 5 } ]);
        var water_weight = grass_weight;
        var gold_weight = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 26, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var demon_weight = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 7 } ]);
        var blood_weight = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 4 }, { :max => 999, :weight => 7 } ]);

        var arrow_weight = tieredWeight(depth, [ { :max => 5, :weight => 8 }, { :max => 12, :weight => 10 }, { :max => 999, :weight => 12 } ]);
        var elemental_arrow_weight = tieredWeight(depth, [ { :max => 7, :weight => 0 }, { :max => 14, :weight => 6 }, { :max => 22, :weight => 8 }, { :max => 999, :weight => 8 } ]);
        var bolt_weight = arrow_weight;
        var elemental_bolt_weight = elemental_arrow_weight;

        var crossbow_weight = tieredWeight(depth, [ { :max => 6, :weight => 0 }, { :max => 12, :weight => 6 }, { :max => 20, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var oak_crossbow_weight = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 6 }, { :max => 24, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var hell_crossbow_weight = tieredWeight(depth, [ { :max => 14, :weight => 0 }, { :max => 22, :weight => 5 }, { :max => 999, :weight => 7 } ]);

        var steel_armor = tieredWeight(depth, [ { :max => 6, :weight => 10 }, { :max => 12, :weight => 8 }, { :max => 18, :weight => 5 }, { :max => 999, :weight => 3 } ]);
        var steel_ring = tieredWeight(depth, [ { :max => 6, :weight => 8 }, { :max => 12, :weight => 7 }, { :max => 18, :weight => 6 }, { :max => 999, :weight => 4 } ]);
        var bronze_armor = tieredWeight(depth, [ { :max => 4, :weight => 6 }, { :max => 10, :weight => 9 }, { :max => 18, :weight => 7 }, { :max => 999, :weight => 3 } ]);
        var bronze_ring = tieredWeight(depth, [ { :max => 4, :weight => 6 }, { :max => 10, :weight => 7 }, { :max => 18, :weight => 6 }, { :max => 999, :weight => 3 } ]);
        var elemental_armor = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 6 }, { :max => 22, :weight => 8 }, { :max => 999, :weight => 6 } ]);
        var elemental_ring = tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 5 }, { :max => 22, :weight => 7 }, { :max => 999, :weight => 6 } ]);
        var gold_armor = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 5 }, { :max => 26, :weight => 8 }, { :max => 999, :weight => 7 } ]);
        var gold_ring = tieredWeight(depth, [ { :max => 12, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 26, :weight => 7 }, { :max => 999, :weight => 7 } ]);
        //var demon_armor = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 5 }, { :max => 999, :weight => 8 } ]);
        //var demon_ring = tieredWeight(depth, [ { :max => 16, :weight => 0 }, { :max => 22, :weight => 4 }, { :max => 999, :weight => 7 } ]);
        //var blood_armor = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 5 }, { :max => 999, :weight => 8 } ]);
        //var blood_ring = tieredWeight(depth, [ { :max => 18, :weight => 0 }, { :max => 24, :weight => 4 }, { :max => 999, :weight => 7 } ]);

        return {
            0 => steel_weight,
            3 => steel_weight,
            8 => steel_weight,
            10 => bronze_weight,
            13 => bronze_weight,
            18 => bronze_weight,
            23 => fire_weight,
            28 => fire_weight,
            33 => ice_weight,
            38 => ice_weight,
            43 => grass_weight,
            48 => grass_weight,
            53 => water_weight,
            58 => water_weight,
            63 => gold_weight,
            68 => gold_weight,
            73 => demon_weight,
            78 => demon_weight,
            83 => blood_weight,
            88 => blood_weight,
            300 => crossbow_weight,
            301 => oak_crossbow_weight,
            302 => hell_crossbow_weight,
            200 => arrow_weight,
            201 => elemental_arrow_weight,
            202 => elemental_arrow_weight,
            203 => elemental_arrow_weight,
            250 => bolt_weight,
            251 => elemental_bolt_weight,
            252 => elemental_bolt_weight,
            253 => elemental_bolt_weight,
            1000 => steel_armor,
            1001 => steel_armor,
            1002 => steel_armor,
            1003 => steel_armor,
            1004 => steel_ring,
            1005 => steel_ring,
            1010 => bronze_armor,
            1011 => bronze_armor,
            1012 => bronze_armor,
            1013 => bronze_armor,
            1014 => bronze_ring,
            1015 => bronze_ring,
            1020 => elemental_armor,
            1021 => elemental_armor,
            1022 => elemental_armor,
            1023 => elemental_armor,
            1024 => elemental_ring,
            1025 => elemental_ring,
            1030 => elemental_armor,
            1031 => elemental_armor,
            1032 => elemental_armor,
            1033 => elemental_armor,
            1034 => elemental_ring,
            1035 => elemental_ring,
            1040 => elemental_armor,
            1041 => elemental_armor,
            1042 => elemental_armor,
            1043 => elemental_armor,
            1044 => elemental_ring,
            1045 => elemental_ring,
            1050 => elemental_armor,
            1051 => elemental_armor,
            1052 => elemental_armor,
            1053 => elemental_armor,
            1054 => elemental_ring,
            1055 => elemental_ring,
            1060 => gold_armor,
            1061 => gold_armor,
            1062 => gold_armor,
            1063 => gold_armor,
            1064 => gold_ring,
            1065 => gold_ring,
            1200 => tieredWeight(depth, [ { :max => 6, :weight => 4 }, { :max => 12, :weight => 2 }, { :max => 999, :weight => 0 } ]),
            1201 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 14, :weight => 4 }, { :max => 22, :weight => 3 }, { :max => 999, :weight => 2 } ]),
            1202 => tieredWeight(depth, [ { :max => 10, :weight => 0 }, { :max => 18, :weight => 3 }, { :max => 999, :weight => 3 } ]),
            1203 => tieredWeight(depth, [ { :max => 14, :weight => 0 }, { :max => 22, :weight => 3 }, { :max => 999, :weight => 4 } ]),
            1250 => tieredWeight(depth, [ { :max => 8, :weight => 4 }, { :max => 999, :weight => 2 } ]),
            1251 => tieredWeight(depth, [ { :max => 10, :weight => 0 }, { :max => 18, :weight => 4 }, { :max => 999, :weight => 4 } ]),
            1252 => tieredWeight(depth, [ { :max => 14, :weight => 0 }, { :max => 22, :weight => 3 }, { :max => 999, :weight => 4 } ]),
            1300 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 3 }, { :max => 999, :weight => 4 } ]),
            1301 => tieredWeight(depth, [ { :max => 8, :weight => 0 }, { :max => 16, :weight => 4 }, { :max => 999, :weight => 5 } ]),
            2000 => tieredWeight(depth, [ { :max => 8, :weight => 10 }, { :max => 18, :weight => 8 }, { :max => 30, :weight => 6 }, { :max => 999, :weight => 4 } ]),
            2001 => tieredWeight(depth, [ { :max => 8, :weight => 6 }, { :max => 18, :weight => 8 }, { :max => 30, :weight => 7 }, { :max => 999, :weight => 6 } ]),
            2002 => tieredWeight(depth, [ { :max => 9, :weight => 0 }, { :max => 18, :weight => 6 }, { :max => 30, :weight => 6 }, { :max => 999, :weight => 6 } ]),
            2003 => tieredWeight(depth, [ { :max => 9, :weight => 0 }, { :max => 18, :weight => 5 }, { :max => 30, :weight => 6 }, { :max => 999, :weight => 6 } ]),
            2004 => tieredWeight(depth, [ { :max => 39, :weight => 0 }, { :max => 60, :weight => 4 }, { :max => 999, :weight => 4 } ]),
            2005 => tieredWeight(depth, [ { :max => 39, :weight => 0 }, { :max => 60, :weight => 4 }, { :max => 999, :weight => 4 } ]),
            5000 => 4 + Math.log(depth + 1, 2)
        } as Dictionary<Number, Numeric>;
    }

    private function getClassItemMultipliers(class_id as Number) as Dictionary<Number, Numeric> {
        var m = {} as Dictionary<Number, Numeric>;
        switch (class_id) {
            case 0: // Warrior
                addMultipliers(
                    m, 
                    [0,3,5,8,10,13,15,18,20,23,25,28,30,33,35,38,40,43,45,48,50,53,55,58,60,63,65,68,70,73,75,78,80,83,85,88], 
                    1.1
                );
                addMultipliers(
                    m, 
                    [1,2,4,6,7,11,12,14,16,17,21,22,24,26,27,31,32,34,36,37,41,42,44,46,47,51,52,54,56,57,61,62,64,66,67,71,72,74,76,77,81,82,84,86,87], 
                    0.95
                );
                addMultipliers(
                    m, 
                    [1200,1201,1202,1203,1000,1001,1002,1003,1010,1011,1012,1013,1020,1021,1022,1023,1030,1031,1032,1033,1040,1041,1042,1043,1050,1051,1052,1053,1060,1061,1062,1063,1070,1071,1072,1073,1080,1081,1082,1083], 
                    1.15
                );
                addMultipliers(m, [1004,1005,1014,1015,1024,1025,1034,1035,1044,1045,1054,1055,1064,1065,1074,1075,1084,1085], 1.05);
                addMultipliers(m, [2000,2002,2004], 1.1);
                addMultipliers(m, [2001,2003,2005], 0.9);
                break;
            case 1: // Mage
                addMultipliers(m, [6,7,16,17,26,27,36,37,46,47,56,57,66,67,76,77,86,87], 1.25); // Spells/Staffs
                addMultipliers(m, [4,14,24,34,44,54,64,74,84], 1.1); // Katanas mid
                addMultipliers(m, [0,3,5,8,10,13,15,18,20,23,25,28,30,33,35,38,40,43,45,48,50,53,55,58,60,63,65,68,70,73,75,78,80,83,85,88], 0.9);
                addMultipliers(m, [1004,1005,1014,1015,1024,1025,1034,1035,1044,1045,1054,1055,1064,1065,1074,1075,1084,1085,1300,1301], 1.2);
                addMultipliers(m, [2001,2003,2005], 1.25);
                addMultipliers(m, [2000,2002,2004], 0.85);
                break;
            case 2: // Archer
                addMultipliers(m, [1,4,7,8,11,14,17,18,21,24,27,28,31,34,37,38,41,44,47,48,51,54,57,58,61,64,67,68,71,74,77,78,81,84,87,88], 1.25);
                addMultipliers(m, [201,202,203,250,251,252,253,300,301,302], 1.3);
                // Much more arrows/bolts
                addMultipliers(m, [200,250], 3);
                addMultipliers(m, [0,3,5,10,13,15,20,23,25,30,33,35,40,43,45,50,53,55,60,63,65,70,73,75,80,83,85], 0.9);
                addMultipliers(m, [1200,1201,1202,1203], 0.9);
                addMultipliers(m, [1250,1251,1252], 1.2);
                addMultipliers(m, [2000,2002], 0.9);
                break;
            case 3: // Nameless balanced
                break;
            case 999: // God
                addMultipliers(m, [60,63,65,68,70,73,75,78,80,83,85,88,1060,1061,1062,1063,1070,1071,1072,1073,1080,1081,1082,1083,2004,2005], 1.15);
                break;
            default:
                break;
        }
        return m;
    }

    private function applyItemMultipliers(base_weights as Array<Dictionary<Number, Numeric>>, multipliers as Dictionary<Number, Numeric>) as Array<Dictionary<Number, Numeric>> {
        var adjusted = [] as Array<Dictionary<Number, Numeric>>;
        for (var i = 0; i < base_weights.size(); i++) {
            var src = base_weights[i] as Dictionary<Number, Numeric>;
            var keys = src.keys();
            var dst = {} as Dictionary<Number, Numeric>;
            for (var k = 0; k < keys.size(); k++) {
                var id = keys[k];
                var factor = multipliers.hasKey(id) ? multipliers[id] : 1;
                dst[id] = src[id] * factor;
            }
            adjusted.add(dst);
        }
        return adjusted;
    }

    private function computeTotals(weights as Array<Dictionary<Number, Numeric>>) as Array<Numeric> {
        var totals = [] as Array<Numeric>;
        for (var i = 0; i < weights.size(); i++) {
            var sum = 0;
            var weight = weights[i] as Dictionary<Number, Numeric>;
            var keys = weight.keys();
            for (var k = 0; k < keys.size(); k++) {
                sum += weight[keys[k]];
            }
            totals.add(sum);
        }
        return totals;
    }

    private function addMultipliers(dict as Dictionary<Number, Numeric>, ids as Array<Number>, factor as Numeric) as Void {
        for (var i = 0; i < ids.size(); i++) {
            dict[ids[i]] = factor;
        }
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