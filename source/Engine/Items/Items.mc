import Toybox.Lang;

module Items {

    var items as Dictionary<Number, Symbol>?;

    var weights as Dictionary<Number, Numeric>?;
    var total_weight as Numeric = 0;
    var character_items as Dictionary<Number, Dictionary<Number, [Numeric, Symbol]>> = {
        1 => {
            2001 => [4, :createManaPotion],
            2003 => [2, :createGreaterManaPotion],
            2005 => [1, :createMaxManaPotion],
        },
         999 => {
            2001 => [4, :createManaPotion],
            2003 => [2, :createGreaterManaPotion],
            2005 => [1, :createMaxManaPotion],
        },
    };

    function init(player_id as Number) as Void {
        items = {
            0 => :createSteelAxe,
            1 => :createSteelBow,
            2 => :createSteelDagger,
            3 => :createSteelGreatsword,
            4 => :createSteelKatana,
            5 => :createSteelLance,
            6 => :createSteelSpell,
            7 => :createSteelStaff,
            8 => :createSteelSword,
            9 => :createArrow,
            10 => :createCrossBow,

            1000 => :createSteelHelmet,
            1001 => :createSteelBreastPlate,
            1002 => :createSteelGauntlets,
            1003 => :createSteelShoes,
            1004 => :createSteelRing1,
            1005 => :createSteelRing2,
            1006 => :createWoodShield,
            1007 => :createGreenBackpack,
            1008 => :createLifeAmulet,

            2000 => :createHealthPotion,
            2002 => :createGreaterHealthPotion,
            2004 => :createMaxHealthPotion,

            5000 => :createGold,
        };
        weights = {
            0 => 1,
            1 => 1,
            2 => 1,
            3 => 1,
            4 => 1,
            5 => 1,
            6 => 1,
            7 => 1,
            8 => 1,
            9 => 1,
            10 => 1,
            1000 => 1,
            1001 => 1,
            1002 => 1,
            1003 => 1,
            1004 => 1,
            1005 => 1,
            1006 => 1,
            2000 => 4,
            2002 => 2,
            2004 => 1,
        };
        var character_changes = character_items[player_id];
        if (character_changes != null) {
            var item_keys = character_changes.keys();
            for (var j = 0; j < item_keys.size(); j++) {
                var item = character_changes[item_keys[j]];
                items[item_keys[j]] = item[1];
                weights[item_keys[j]] = item[0];
            }
        }
        total_weight = 0;
        var weight_keys = weights.keys();
        for (var i = 0; i < weight_keys.size(); i++) {
            total_weight += weights[weight_keys[i]];
        }
    }


    // Weapons
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

    function createArrow() as Item {
        var arrow = new Arrow();
        arrow.setAmount(MathUtil.random(1, 10));
        return arrow;
    }

    function createCrossBow() as Item {
        return new CrossBow();
    }


    // Armors
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
    
    function createWoodShield() as Item {
        return new WoodShield();
    }

    function createGreenBackpack() as Item {
        return new GreenBackpack();
    }

    function createLifeAmulet() as Item {
        return new LifeAmulet();
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

    function createItemFromId(id as Number) as Item {
        var symbol = items[id] as Symbol;
        var method = new Method(self, symbol);
        return method.invoke() as Item;
    }

    function createRandomItem() as Item {
        var item_keys = items.keys();
        // Remove gold from random items
        item_keys.remove(5000);
        var rand = MathUtil.random(0, item_keys.size() - 1);
        var method = new Method(self, items[item_keys[rand]]);
        return method.invoke() as Item;
    }

    function createRandomWeightedItem() as Item? {
        var rand = MathUtil.random(0, total_weight - 1);
        var current_weight = 0;
        var weight_keys = weights.keys();
        for (var i = 0; i < weight_keys.size(); i++) {
            current_weight += weights[weight_keys[i]];
            if (rand < current_weight) {
                var method = new Method(self, items[weight_keys[i]]);
                return method.invoke() as Item;
            }
        }
        return null;
    }
}