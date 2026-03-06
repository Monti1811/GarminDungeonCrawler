import Toybox.Lang;

module Items {

    var item_ids as Array<Number> = [
        0, 1, 2, 3, 4, 5, 6, 7, 8,
        10, 11, 12, 13, 14, 15, 16, 17, 18,
        20, 21, 22, 23, 24, 25, 26, 27, 28,
        30, 31, 32, 33, 34, 35, 36, 37, 38,
        40, 41, 42, 43, 44, 45, 46, 47, 48,
        50, 51, 52, 53, 54, 55, 56, 57, 58,
        60, 61, 62, 63, 64, 65, 66, 67, 68,
        70, 71, 72, 73, 74, 75, 76, 77, 78,
        80, 81, 82, 83, 84, 85, 86, 87, 88,
        200, 201, 202, 203,
        250, 251, 252, 253,
        300, 301, 302,
        1000, 1001, 1002, 1003, 1004, 1005,
        1010, 1011, 1012, 1013, 1014, 1015,
        1020, 1021, 1022, 1023, 1024, 1025,
        1030, 1031, 1032, 1033, 1034, 1035,
        1040, 1041, 1042, 1043, 1044, 1045,
        1050, 1051, 1052, 1053, 1054, 1055,
        1060, 1061, 1062, 1063, 1064, 1065,
        1070, 1071, 1072, 1073, 1074, 1075,
        1080, 1081, 1082, 1083, 1084, 1085,
        1200, 1201, 1202, 1203,
        1250, 1251, 1252,
        1300, 1301,
        2000, 2001, 2002, 2003, 2004, 2005,
        3000,
        5000,
        6000
    ];

    var weights as Array<Dictionary<Number, Numeric>>?;
    var total_weight as Array<Numeric> = [0, 0, 0, 0, 0];

    function init(player_id as Number) as Void {
        var item_specific_values = new ItemSpecificValues(player_id);
        var values = item_specific_values.getDungeonItemWeights();
        weights = values[0];
        total_weight = values[1];
    }

    function createItemFromId(id as Number) as Item? {
        if (id < 1000) {
            switch (id) {
                case 0: return new SteelAxe();
                case 1: return new SteelBow();
                case 2: return new SteelDagger();
                case 3: return new SteelGreatsword();
                case 4: return new SteelKatana();
                case 5: return new SteelLance();
                case 6: return new SteelSpell();
                case 7: return new SteelStaff();
                case 8: return new SteelSword();
                case 10: return new BronzeAxe();
                case 11: return new BronzeBow();
                case 12: return new BronzeDagger();
                case 13: return new BronzeGreatsword();
                case 14: return new BronzeKatana();
                case 15: return new BronzeLance();
                case 16: return new BronzeSpell();
                case 17: return new BronzeStaff();
                case 18: return new BronzeSword();
                case 20: return new FireAxe();
                case 21: return new FireBow();
                case 22: return new FireDagger();
                case 23: return new FireGreatsword();
                case 24: return new FireKatana();
                case 25: return new FireLance();
                case 26: return new FireSpell();
                case 27: return new FireStaff();
                case 28: return new FireSword();
                case 30: return new IceAxe();
                case 31: return new IceBow();
                case 32: return new IceDagger();
                case 33: return new IceGreatsword();
                case 34: return new IceKatana();
                case 35: return new IceLance();
                case 36: return new IceSpell();
                case 37: return new IceStaff();
                case 38: return new IceSword();
                case 40: return new GrassAxe();
                case 41: return new GrassBow();
                case 42: return new GrassDagger();
                case 43: return new GrassGreatsword();
                case 44: return new GrassKatana();
                case 45: return new GrassLance();
                case 46: return new GrassSpell();
                case 47: return new GrassStaff();
                case 48: return new GrassSword();
                case 50: return new WaterAxe();
                case 51: return new WaterBow();
                case 52: return new WaterDagger();
                case 53: return new WaterGreatsword();
                case 54: return new WaterKatana();
                case 55: return new WaterLance();
                case 56: return new WaterSpell();
                case 57: return new WaterStaff();
                case 58: return new WaterSword();
                case 60: return new GoldAxe();
                case 61: return new GoldBow();
                case 62: return new GoldDagger();
                case 63: return new GoldGreatsword();
                case 64: return new GoldKatana();
                case 65: return new GoldLance();
                case 66: return new GoldSpell();
                case 67: return new GoldStaff();
                case 68: return new GoldSword();
                case 70: return new DemonAxe();
                case 71: return new DemonBow();
                case 72: return new DemonDagger();
                case 73: return new DemonGreatsword();
                case 74: return new DemonKatana();
                case 75: return new DemonLance();
                case 76: return new DemonSpell();
                case 77: return new DemonStaff();
                case 78: return new DemonSword();
                case 80: return new BloodAxe();
                case 81: return new BloodBow();
                case 82: return new BloodDagger();
                case 83: return new BloodGreatsword();
                case 84: return new BloodKatana();
                case 85: return new BloodLance();
                case 86: return new BloodSpell();
                case 87: return new BloodStaff();
                case 88: return new BloodSword();
                case 200: return new Arrow();
                case 201: return new FireArrow();
                case 202: return new IceArrow();
                case 203: return new GoldArrow();
                case 250: return new Bolt();
                case 251: return new FireBolt();
                case 252: return new IceBolt();
                case 253: return new GoldBolt();
                case 300: return new CrossBow();
                case 301: return new OakCrossBow();
                case 302: return new HellCrossBow();
                default: return null;
            }
        }

        if (id < 2000) {
            switch (id) {
                case 1000: return new SteelHelmet();
                case 1001: return new SteelBreastPlate();
                case 1002: return new SteelGauntlets();
                case 1003: return new SteelShoes();
                case 1004: return new SteelRing1();
                case 1005: return new SteelRing2();
                case 1010: return new BronzeHelmet();
                case 1011: return new BronzeBreastPlate();
                case 1012: return new BronzeGauntlets();
                case 1013: return new BronzeShoes();
                case 1014: return new BronzeRing1();
                case 1015: return new BronzeRing2();
                case 1020: return new FireHelmet();
                case 1021: return new FireBreastPlate();
                case 1022: return new FireGauntlets();
                case 1023: return new FireShoes();
                case 1024: return new FireRing1();
                case 1025: return new FireRing2();
                case 1030: return new IceHelmet();
                case 1031: return new IceBreastPlate();
                case 1032: return new IceGauntlets();
                case 1033: return new IceShoes();
                case 1034: return new IceRing1();
                case 1035: return new IceRing2();
                case 1040: return new GrassHelmet();
                case 1041: return new GrassBreastPlate();
                case 1042: return new GrassGauntlets();
                case 1043: return new GrassShoes();
                case 1044: return new GrassRing1();
                case 1045: return new GrassRing2();
                case 1050: return new WaterHelmet();
                case 1051: return new WaterBreastPlate();
                case 1052: return new WaterGauntlets();
                case 1053: return new WaterShoes();
                case 1054: return new WaterRing1();
                case 1055: return new WaterRing2();
                case 1060: return new GoldHelmet();
                case 1061: return new GoldBreastPlate();
                case 1062: return new GoldGauntlets();
                case 1063: return new GoldShoes();
                case 1064: return new GoldRing1();
                case 1065: return new GoldRing2();
                case 1070: return new DemonHelmet();
                case 1071: return new DemonBreastPlate();
                case 1072: return new DemonGauntlets();
                case 1073: return new DemonShoes();
                case 1074: return new DemonRing1();
                case 1075: return new DemonRing2();
                case 1080: return new BloodHelmet();
                case 1081: return new BloodBreastPlate();
                case 1082: return new BloodGauntlets();
                case 1083: return new BloodShoes();
                case 1084: return new BloodRing1();
                case 1085: return new BloodRing2();
                case 1200: return new WoodShield();
                case 1201: return new SteelShield();
                case 1202: return new SilverShield();
                case 1203: return new GoldShield();
                case 1250: return new GreenBackpack();
                case 1251: return new PurpleBackpack();
                case 1252: return new GoldBackpack();
                case 1300: return new LifeAmulet();
                case 1301: return new ManaCrystal();
                default: return null;
            }
        }

        if (id < 3000) {
            switch (id) {
                case 2000: return new HealthPotion();
                case 2001: return new ManaPotion();
                case 2002: return new GreaterHealthPotion();
                case 2003: return new GreaterManaPotion();
                case 2004: return new MaxHealthPotion();
                case 2005: return new MaxManaPotion();
                default: return null;
            }
        }

        if (id < 4000) {
            switch (id) {
                case 3000: return new Key();
                default: return null;
            }
        }

        if (id < 6000) {
            switch (id) {
                case 5000: return new Gold();
                default: return null;
            }
        }

        switch (id) {
            case 6000: return new TreasureChest();
            default: return null;
        }
    }

    function createTreasureChestWithLoot(loot as Item?) as TreasureChest {
        var chest = new TreasureChest();
        chest.setContents(loot);
        return chest;
    }

    function createRandomItem() as Item {
		var rand = 9999;
		while (rand > 4000) {
			rand = MathUtil.random(0, item_ids.size() - 1);
		}
        var item = createItemFromId(item_ids[rand]);
        if (item != null) {
            return item;
        }
        return new SteelSword();
    }

    function createRandomWeightedItem(type as Number) as Item? {
        //Toybox.System.println("createRandomWeightedItem: " + type);
        var rand = MathUtil.random(0, total_weight[type] - 1);
        var current_weight = 0;
        var weight_keys = weights[type].keys();
        for (var i = 0; i < weight_keys.size(); i++) {
            current_weight += weights[type][weight_keys[i]];
            if (rand < current_weight) {
                return createItemFromId(weight_keys[i] as Number);
            }
        }

        Toybox.System.println("Error: No item found for type " + type);
        Toybox.System.println("Rand: " + rand + " Current Weight: " + current_weight + " Total Weight: " + total_weight[type]);
        return null;
    }
}
