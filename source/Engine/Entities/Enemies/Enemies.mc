import Toybox.Lang;

module Enemies {

    var enemies as Dictionary<Number, Symbol> = {
        0 => :createFrog, 
    };


    function createFrog() as Enemy {
        return new Frog();
    }

    function createEnemyFromId(id as Number) as Enemy {
        var method = new Method(self, enemies[id]);
        return method.invoke() as Enemy;
    }

    function createRandomEnemy() as Enemy {
        var enemy_keys = enemies.keys();
        var rand = MathUtil.random(0, enemy_keys.size() - 1);
        var method = new Method(self, enemies[rand]);
        return method.invoke() as Enemy;
    }
}