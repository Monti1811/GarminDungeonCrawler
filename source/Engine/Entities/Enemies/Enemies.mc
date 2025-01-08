import Toybox.Lang;

module Enemies {

    var enemies as Array<Symbol> = [
        :createFrog
    ];


    function createFrog() as Enemy {
        return new Frog();
    }


    function createRandomEnemy() as Enemy {
        var rand = MathUtil.random(0, enemies.size() - 1);
        var method = new Method(self, enemies[rand]);
        return method.invoke() as Enemy;
    }
}