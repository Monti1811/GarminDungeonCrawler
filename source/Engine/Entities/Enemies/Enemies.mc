import Toybox.Lang;

module Enemies {

    var enemies as Dictionary<Number, Symbol> = {
        0 => :createFrog, 
        1 => :createBat,
        2 => :createDemon,
        3 => :createOrc,
    };

    var dungeon_enemies as Array<Dictionary<Symbol, Numeric>> = [
        { :id => 0, :cost => 3, :weight => 8 },
        { :id => 1, :cost => 7, :weight => 8 },
        { :id => 2, :cost => 25, :weight => 4 },
        { :id => 3, :cost => 5, :weight => 8 }
    ];

    var total_weight as Numeric = 0;

    function init(player_id as Number) as Void {
        var enemy_specific_values = new EnemySpecificValues(player_id);
        var values = enemy_specific_values.getDungeonEnemyWeights();
        total_weight = 0;
        for (var i = 0; i < dungeon_enemies.size(); i++) {
            total_weight += dungeon_enemies[i][:weight];
        }
    }


    function createFrog() as Enemy {
        return new Frog();
    }

    function createBat() as Enemy {
        return new Bat();
    }

    function createDemon() as Enemy {
        return new Demon();
    }

    function createOrc() as Enemy {
        return new Orc();
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

    function createRandomWeightedEnemy() as Enemy? {
        var rand = MathUtil.random(0, total_weight - 1);
        var current_weight = 0;
        for (var i = 0; i < dungeon_enemies.size(); i++) {
            current_weight += dungeon_enemies[i][:weight];
            if (rand < current_weight) {
                var method = new Method(self, enemies[dungeon_enemies[i][:id]]);
                return method.invoke() as Enemy;
            }
        }
        return null;
    }
}