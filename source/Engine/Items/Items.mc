import Toybox.Lang;

module Items {

    var items as Dictionary<Number, Symbol> = {
        0 => :createSteelAxe,
        1 => :createSteelLance,
        1000 => :createSteelHelmet
    };


    function createSteelAxe() as Item {
        return new SteelAxe();
    }

    function createSteelLance() as Item {
        return new SteelLance();
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