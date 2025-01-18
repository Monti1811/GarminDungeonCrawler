import Toybox.Lang;

module Enemies {

    var enemies as Dictionary<Number, Symbol>?;

    var weights as Dictionary<Number, Numeric>?;
    var total_weight as Numeric = 0;
    var character_enemies as Dictionary<Number, Dictionary<Number, [Numeric, Symbol]>> = {

        1 => {
            2 => [0.5, :createDemon],
        },
    };

    function init(player_id as Number) as Void {
        enemies = {
            0 => :createFrog, 
            1 => :createBat,
            2 => :createDemon,
        };
        weights = {
            0 => 5,
            1 => 3,
            2 => 1,
        };
        var character_changes = character_enemies[player_id]; 
        if (character_changes != null) {
            var enemy_keys = character_changes.keys();
            for (var j = 0; j < enemy_keys.size(); j++) {
                var enemy = character_changes[enemy_keys[j]];
                enemies[enemy_keys[j]] = enemy[1];
                weights[enemy_keys[j]] = enemy[0];
            }
        }
        var weight_keys = weights.keys();
        for (var i = 0; i < weight_keys.size(); i++) {
            total_weight += weights[weight_keys[i]];
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
        var weight_keys = weights.keys();
        for (var i = 0; i < weight_keys.size(); i++) {
            current_weight += weights[weight_keys[i]];
            if (rand < current_weight) {
                var method = new Method(self, enemies[weight_keys[i]]);
                return method.invoke() as Enemy;
            }
        }
        return null;
    }
}