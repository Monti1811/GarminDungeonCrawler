import Toybox.Lang;

module Items {

    var items as Dictionary<Number, Symbol> = {
            // Weapons

            // Steel Weapons
            0 => :createSteelAxe,
            1 => :createSteelBow,
            2 => :createSteelDagger,
            3 => :createSteelGreatsword,
            4 => :createSteelKatana,
            5 => :createSteelLance,
            6 => :createSteelSpell,
            7 => :createSteelStaff,
            8 => :createSteelSword,

            // Bronze Weapons
            10 => :createBronzeAxe,
            11 => :createBronzeBow,
            12 => :createBronzeDagger,
            13 => :createBronzeGreatsword,
            14 => :createBronzeKatana,
            15 => :createBronzeLance,
            16 => :createBronzeSpell,
            17 => :createBronzeStaff,
            18 => :createBronzeSword,

            // Fire Weapons
            20 => :createFireAxe,
            21 => :createFireBow,
            22 => :createFireDagger,
            23 => :createFireGreatsword,
            24 => :createFireKatana,
            25 => :createFireLance,
            26 => :createFireSpell,
            27 => :createFireStaff,
            28 => :createFireSword,

            // Ice Weapons
            30 => :createIceAxe,
            31 => :createIceBow,
            32 => :createIceDagger,
            33 => :createIceGreatsword,
            34 => :createIceKatana,
            35 => :createIceLance,
            36 => :createIceSpell,
            37 => :createIceStaff,
            38 => :createIceSword,

            // Grass Weapons
            40 => :createGrassAxe,
            41 => :createGrassBow,
            42 => :createGrassDagger,
            43 => :createGrassGreatsword,
            44 => :createGrassKatana,
            45 => :createGrassLance,
            46 => :createGrassSpell,
            47 => :createGrassStaff,
            48 => :createGrassSword,

            // Water Weapons
            50 => :createWaterAxe,
            51 => :createWaterBow,
            52 => :createWaterDagger,
            53 => :createWaterGreatsword,
            54 => :createWaterKatana,
            55 => :createWaterLance,
            56 => :createWaterSpell,
            57 => :createWaterStaff,
            58 => :createWaterSword,

            9 => :createArrow,
            10 => :createCrossBow,

            // Steel Armor
            1000 => :createSteelHelmet,
            1001 => :createSteelBreastPlate,
            1002 => :createSteelGauntlets,
            1003 => :createSteelShoes,
            1004 => :createSteelRing1,
            1005 => :createSteelRing2,

            // Bronze Armor
            1010 => :createBronzeHelmet,
            1011 => :createBronzeBreastPlate,
            1012 => :createBronzeGauntlets,
            1013 => :createBronzeShoes,
            1014 => :createBronzeRing1,
            1015 => :createBronzeRing2,
            // Fire Armor
            1020 => :createFireHelmet,
            1021 => :createFireBreastPlate,
            1022 => :createFireGauntlets,
            1023 => :createFireShoes,
            1024 => :createFireRing1,
            1025 => :createFireRing2,
            // Ice Armor
            1030 => :createIceHelmet,
            1031 => :createIceBreastPlate,
            1032 => :createIceGauntlets,
            1033 => :createIceShoes,
            1034 => :createIceRing1,
            1035 => :createIceRing2,
            // Grass Armor
            1040 => :createGrassHelmet,
            1041 => :createGrassBreastPlate,
            1042 => :createGrassGauntlets,
            1043 => :createGrassShoes,
            1044 => :createGrassRing1,
            1045 => :createGrassRing2,
            // Water Armor
            1050 => :createWaterHelmet,
            1051 => :createWaterBreastPlate,
            1052 => :createWaterGauntlets,
            1053 => :createWaterShoes,
            1054 => :createWaterRing1,
            1055 => :createWaterRing2,
            // Gold Armor
            1060 => :createGoldHelmet,
            1061 => :createGoldBreastPlate,
            1062 => :createGoldGauntlets,
            1063 => :createGoldShoes,
            1064 => :createGoldRing1,
            1065 => :createGoldRing2,
            // Demon Armor
            1070 => :createDemonHelmet,
            1071 => :createDemonBreastPlate,
            1072 => :createDemonGauntlets,
            1073 => :createDemonShoes,
            1074 => :createDemonRing1,
            1075 => :createDemonRing2,
            // Blood Armor
            1080 => :createBloodHelmet,
            1081 => :createBloodBreastPlate,
            1082 => :createBloodGauntlets,
            1083 => :createBloodShoes,
            1084 => :createBloodRing1,
            1085 => :createBloodRing2,

            // Shields
            1200 => :createWoodShield,
            1201 => :createSteelShield,
            1202 => :createSilverShield,
            1203 => :createGoldShield,

            // Backpacks
            1250 => :createGreenBackpack,
            1251 => :createPurpleBackpack,
            1252 => :createGoldBackpack,

            // Accessories
            1301 => :createManaCrystal,


            // Potions
            2000 => :createHealthPotion,
            2001 => :createManaPotion,
            2002 => :createGreaterHealthPotion,
            2003 => :createGreaterManaPotion,
            2004 => :createMaxHealthPotion,
            2005 => :createMaxManaPotion,

            // Gold
            5000 => :createGold,
        };

    var weights as Array<Dictionary<Number, Numeric>>?;
    var total_weight as Array<Numeric> = [0, 0, 0, 0, 0];

    function init(player_id as Number) as Void {
        
        var item_specific_values = new ItemSpecificValues(player_id);
        var values = item_specific_values.getDungeonItemWeights();
        weights = values[0];
        total_weight = values[1];
    }


// Weapons

    // Steel weapons
    function createSteelAxe() as Item {
        return new SteelAxe();
    }

    function createSteelBow() as Item {
        return new SteelBow();
    }

    function createSteelDagger() as Item {
        return new SteelDagger();
    }
    
    function createSteelGreatsword() as Item {
        return new SteelGreatsword();
    }

    function createSteelKatana() as Item {
        return new SteelKatana();
    }

    function createSteelLance() as Item {
        return new SteelLance();
    }

    function createSteelSpell() as Item {
        return new SteelSpell();
    }

    function createSteelStaff() as Item {
        return new SteelStaff();
    }

    function createSteelSword() as Item {
        return new SteelSword();
    }

     // Bronze Weapons
    function createBronzeAxe() as Item {
        return new BronzeAxe();
    }

    function createBronzeBow() as Item {
        return new BronzeBow();
    }

    function createBronzeDagger() as Item {
        return new BronzeDagger();
    }

    function createBronzeGreatsword() as Item {
        return new BronzeGreatsword();
    }

    function createBronzeKatana() as Item {
        return new BronzeKatana();
    }

    function createBronzeLance() as Item {
        return new BronzeLance();
    }

    function createBronzeSpell() as Item {
        return new BronzeSpell();
    }

    function createBronzeStaff() as Item {
        return new BronzeStaff();
    }

    function createBronzeSword() as Item {
        return new BronzeSword();
    }

    // Fire Weapons
    function createFireAxe() as Item {
        return new FireAxe();
    }

    function createFireBow() as Item {
        return new FireBow();
    }

    function createFireDagger() as Item {
        return new FireDagger();
    }

    function createFireGreatsword() as Item {
        return new FireGreatsword();
    }

    function createFireKatana() as Item {
        return new FireKatana();
    }

    function createFireLance() as Item {
        return new FireLance();
    }

    function createFireSpell() as Item {
        return new FireSpell();
    }

    function createFireStaff() as Item {
        return new FireStaff();
    }

    function createFireSword() as Item {
        return new FireSword();
    }

    // Ice Weapons
    function createIceAxe() as Item {
        return new IceAxe();
    }

    function createIceBow() as Item {
        return new IceBow();
    }

    function createIceDagger() as Item {
        return new IceDagger();
    }

    function createIceGreatsword() as Item {
        return new IceGreatsword();
    }

    function createIceKatana() as Item {
        return new IceKatana();
    }

    function createIceLance() as Item {
        return new IceLance();
    }

    function createIceSpell() as Item {
        return new IceSpell();
    }

    function createIceStaff() as Item {
        return new IceStaff();
    }

    function createIceSword() as Item {
        return new IceSword();
    }

    // Grass Weapons
    function createGrassAxe() as Item {
        return new GrassAxe();
    }

    function createGrassBow() as Item {
        return new GrassBow();
    }

    function createGrassDagger() as Item {
        return new GrassDagger();
    }

    function createGrassGreatsword() as Item {
        return new GrassGreatsword();
    }

    function createGrassKatana() as Item {
        return new GrassKatana();
    }

    function createGrassLance() as Item {
        return new GrassLance();
    }

    function createGrassSpell() as Item {
        return new GrassSpell();
    }

    function createGrassStaff() as Item {
        return new GrassStaff();
    }

    function createGrassSword() as Item {
        return new GrassSword();
    }

    // Water Weapons
    function createWaterAxe() as Item {
        return new WaterAxe();
    }

    function createWaterBow() as Item {
        return new WaterBow();
    }

    function createWaterDagger() as Item {
        return new WaterDagger();
    }

    function createWaterGreatsword() as Item {
        return new WaterGreatsword();
    }

    function createWaterKatana() as Item {
        return new WaterKatana();
    }

    function createWaterLance() as Item {
        return new WaterLance();
    }

    function createWaterSpell() as Item {
        return new WaterSpell();
    }

    function createWaterStaff() as Item {
        return new WaterStaff();
    }

    function createWaterSword() as Item {
        return new WaterSword();
    }

    function createArrow() as Item {
        var arrow = new Arrow();
        arrow.setAmount(MathUtil.random(1, 10));
        return arrow;
    }

    function createCrossBow() as Item {
        return new CrossBow();
    }

   

// Armors

    // Steel Armors
    function createSteelHelmet() as Item {
        return new SteelHelmet();
    }

    function createSteelBreastPlate() as Item {
        return new SteelBreastPlate();
    }

    function createSteelGauntlets() as Item {
        return new SteelGauntlets();
    }

    function createSteelShoes() as Item {
        return new SteelShoes();
    }

    function createSteelRing1() as Item {
        return new SteelRing1();
    }

    function createSteelRing2() as Item {
        return new SteelRing2();
    }
    

    // Bronze Armor
    function createBronzeHelmet() as Item {
        return new BronzeHelmet();
    }

    function createBronzeBreastPlate() as Item {
        return new BronzeBreastPlate();
    }

    function createBronzeGauntlets() as Item {
        return new BronzeGauntlets();
    }

    function createBronzeShoes() as Item {
        return new BronzeShoes();
    }

    function createBronzeRing1() as Item {
        return new BronzeRing1();
    }

    function createBronzeRing2() as Item {
        return new BronzeRing2();
    }

    // Fire Armor
    function createFireHelmet() as Item {
        return new FireHelmet();
    }

    function createFireBreastPlate() as Item {
        return new FireBreastPlate();
    }

    function createFireGauntlets() as Item {
        return new FireGauntlets();
    }

    function createFireShoes() as Item {
        return new FireShoes();
    }

    function createFireRing1() as Item {
        return new FireRing1();
    }

    function createFireRing2() as Item {
        return new FireRing2();
    }

    // Ice Armor
    function createIceHelmet() as Item {
        return new IceHelmet();
    }

    function createIceBreastPlate() as Item {
        return new IceBreastPlate();
    }

    function createIceGauntlets() as Item {
        return new IceGauntlets();
    }

    function createIceShoes() as Item {
        return new IceShoes();
    }

    function createIceRing1() as Item {
        return new IceRing1();
    }

    function createIceRing2() as Item {
        return new IceRing2();
    }

    // Grass Armor
    function createGrassHelmet() as Item {
        return new GrassHelmet();
    }

    function createGrassBreastPlate() as Item {
        return new GrassBreastPlate();
    }

    function createGrassGauntlets() as Item {
        return new GrassGauntlets();
    }

    function createGrassShoes() as Item {
        return new GrassShoes();
    }

    function createGrassRing1() as Item {
        return new GrassRing1();
    }

    function createGrassRing2() as Item {
        return new GrassRing2();
    }

    // Water Armor
    function createWaterHelmet() as Item {
        return new WaterHelmet();
    }

    function createWaterBreastPlate() as Item {
        return new WaterBreastPlate();
    }

    function createWaterGauntlets() as Item {
        return new WaterGauntlets();
    }

    function createWaterShoes() as Item {
        return new WaterShoes();
    }

    function createWaterRing1() as Item {
        return new WaterRing1();
    }

    function createWaterRing2() as Item {
        return new WaterRing2();
    }

    // Gold Armor
    function createGoldHelmet() as Item {
        return new GoldHelmet();
    }

    function createGoldBreastPlate() as Item {
        return new GoldBreastPlate();
    }

    function createGoldGauntlets() as Item {
        return new GoldGauntlets();
    }

    function createGoldShoes() as Item {
        return new GoldShoes();
    }

    function createGoldRing1() as Item {
        return new GoldRing1();
    }

    function createGoldRing2() as Item {
        return new GoldRing2();
    }

    // Demon Armor
    function createDemonHelmet() as Item {
        return new DemonHelmet();
    }

    function createDemonBreastPlate() as Item {
        return new DemonBreastPlate();
    }

    function createDemonGauntlets() as Item {
        return new DemonGauntlets();
    }

    function createDemonShoes() as Item {
        return new DemonShoes();
    }

    function createDemonRing1() as Item {
        return new DemonRing1();
    }

    function createDemonRing2() as Item {
        return new DemonRing2();
    }

    // Blood Armor
    function createBloodHelmet() as Item {
        return new BloodHelmet();
    }

    function createBloodBreastPlate() as Item {
        return new BloodBreastPlate();
    }

    function createBloodGauntlets() as Item {
        return new BloodGauntlets();
    }

    function createBloodShoes() as Item {
        return new BloodShoes();
    }

    function createBloodRing1() as Item {
        return new BloodRing1();
    }

    function createBloodRing2() as Item {
        return new BloodRing2();
    }

    // Shields
    function createWoodShield() as Item {
        return new WoodShield();
    }

    function createSteelShield() as Item {
        return new SteelShield();
    }

    function createSilverShield() as Item {
        return new SilverShield();
    }

    function createGoldShield() as Item {
        return new GoldShield();
    }

    // Backpacks
    function createGreenBackpack() as Item {
        return new GreenBackpack();
    }

    function createPurpleBackpack() as Item {
        return new PurpleBackpack();
    }

    function createGoldBackpack() as Item {
        return new GoldBackpack();
    }

    // Accessories
    function createLifeAmulet() as Item {
        return new LifeAmulet();
    }

    function createManaCrystal() as Item {
        return new ManaCrystal();
    }

    // Consumables
    function createHealthPotion() as Item {
        return new HealthPotion();
    }

    function createGreaterHealthPotion() as Item {
        return new GreaterHealthPotion();
    }

    function createMaxHealthPotion() as Item {
        return new MaxHealthPotion();
    }

    function createManaPotion() as Item {
        return new ManaPotion();
    }

    function createGreaterManaPotion() as Item {
        return new GreaterManaPotion();
    }

    function createMaxManaPotion() as Item {
        return new MaxManaPotion();
    }

    function createGold() as Item {
        return new Gold();
    }

    function createItemFromId(id as Number) as Item? {
        var symbol = items[id] as Symbol;
        var method = new Lang.Method(self, symbol);
        if (method == null) {
            Toybox.System.println("Error: No item found for id " + id);
            return null;
        }
        return method.invoke() as Item;
    }

    function createRandomItem() as Item {
        var item_keys = items.keys();
        // Remove gold from random items
        item_keys.remove(5000);
        var rand = MathUtil.random(0, item_keys.size() - 1);
        var method = new Lang.Method(self, items[item_keys[rand]]);
        return method.invoke() as Item;
    }

    function createRandomWeightedItem(type as Number) as Item? {
        var rand = MathUtil.random(0, total_weight[type] - 1);
        var current_weight = 0;
        var weight_keys = weights[type].keys();
        for (var i = 0; i < weight_keys.size(); i++) {
            current_weight += weights[type][weight_keys[i]];
            if (rand < current_weight) {
                var method = new Lang.Method(self, items[weight_keys[i]]);
                return method.invoke() as Item;
            }
        }
        Toybox.System.println("Error: No item found for type " + type);
        Toybox.System.println("Rand: " + rand + " Current Weight: " + current_weight + " Total Weight: " + total_weight[type]);
        return null;
    }
}