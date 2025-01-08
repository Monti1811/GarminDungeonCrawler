import Toybox.Lang;

module Items {

    var items as Dictionary<Number, Symbol> = {
        0 => :createAxe,
        1 => :createSpear,
        1000 => :createHelmet
    };


    function createAxe() as Item {
        return new Axe();
    }

    function createSpear() as Item {
        return new Spear();
    }

    function createHelmet() as Item {
        return new Helmet();
    }

    function createItemFromId(id as Number) as Item {
        var method = new Method(self, items[id]);
        return method.invoke() as Item;
    }

    function createRandomItem() as Item {
        var item_keys = items.keys();
        var rand = MathUtil.random(0, item_keys.size() - 1);
        var method = new Method(self, items[item_keys[rand]]);
        return method.invoke() as Item;
    }
}