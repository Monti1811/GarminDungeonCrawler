import Toybox.Lang;

module Items {

    var items as Dictionary<Number, Symbol> = {
        0 => :createSteelAxe,
        1 => :createSteelBow,
        2 => :createSteelDagger,
        3 => :createSteelGreatsword,
        4 => :createSteelKatana,
        5 => :createSteelLance,
        6 => :createSteelSpell,
        7 => :createSteelStaff,
        8 => :createSteelSword,

        1000 => :createSteelHelmet,
        1001 => :createSteelBreastPlate,
        1002 => :createSteelGauntlets,
        1003 => :createSteelShoes,
        1004 => :createSteelRing1,
        1005 => :createSteelRing2,

        2000 => :createHealthPotion,
    };

    var weights as Dictionary<Number, Number> = {
        0 => 1,
        1 => 1,
        2 => 1,
        3 => 1,
        4 => 1,
        5 => 1,
        6 => 1,
        7 => 1,
        8 => 1,
        1000 => 1,
        1001 => 1,
        1002 => 1,
        1003 => 1,
        1004 => 1,
        1005 => 1,
        2000 => 1,
    };
    var total_weight = 16;


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

    function createHealthPotion() as Item {
        return new HealthPotion();
    }

    function createItemFromId(id as Number) as Item {
        var symbol = items[id] as Symbol;
        var method = new Method(self, symbol);
        return method.invoke() as Item;
    }

    function createRandomItem() as Item {
        var item_keys = items.keys();
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