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

        1000 => :createSteelHelmet
    };


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
}