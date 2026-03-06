import Toybox.Lang;

module Enemies {

    var enemy_ids as Array<Number> = [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
        10, 11, 12, 13, 14, 15, 16, 17,
        18, 19, 20, 21, 22, 23, 24, 25,
        26, 27, 28, 29, 30, 31, 32, 33,
        34, 35
    ];

    var dungeon_enemies as Array<Dictionary<Symbol, Numeric>> = [
        { :id => 0, :cost => 3, :weight => 8 },
        { :id => 1, :cost => 7, :weight => 8 },
        { :id => 2, :cost => 25, :weight => 4 },
        { :id => 3, :cost => 5, :weight => 8 },
        { :id => 4, :cost => 5, :weight => 8 },
    ];

    var total_weight as Numeric = 0;

    function init(player_id as Number) as Void {
        var enemy_specific_values = new EnemySpecificValues(player_id);
        var values = enemy_specific_values.getDungeonEnemyWeights();
        dungeon_enemies = values[0];
        total_weight = 0;
        for (var i = 0; i < dungeon_enemies.size(); i++) {
            var enemy = dungeon_enemies[i] as Dictionary<Symbol, Numeric>;
            total_weight += enemy[:weight];
        }
    }

    function createEnemyFromId(id as Number) as Enemy {
        switch (id) {
            case 0: return new Frog();
            case 1: return new Bat();
            case 2: return new Demon();
            case 3: return new Orc();
            case 4: return new Imp();
            case 5: return new Skeleton();
            case 6: return new Necromancer();
            case 7: return new ZombieSmall();
            case 8: return new Zombie();
            case 9: return new Wogol();
            case 10: return new Ogre();
            case 11: return new DarkKnight();
            case 12: return new ElementalAirSmall();
            case 13: return new ElementalEarthSmall();
            case 14: return new ElementalFireSmall();
            case 15: return new ElementalGoldSmall();
            case 16: return new ElementalGooSmall();
            case 17: return new ElementalWaterSmall();
            case 18: return new ElementalAir();
            case 19: return new ElementalEarth();
            case 20: return new ElementalFire();
            case 21: return new ElementalGold();
            case 22: return new ElementalGoo();
            case 23: return new ElementalPlant();
            case 24: return new ElementalWater();
            case 25: return new Goblin();
            case 26: return new Tentackle();
            case 27: return new Demonolog();
            case 28: return new Chort();
            case 29: return new Bies();
            case 30: return new ElementalPlantSmall();
            case 31: return new OrcArmored();
            case 32: return new OrcMasked();
            case 33: return new OrcShaman();
            case 34: return new OrcVeteran();
            case 35: return new Rokita();
            default: return new Frog();
        }
    }

    function createRandomEnemy() as Enemy {
        var rand = MathUtil.random(0, enemy_ids.size() - 1);
        return createEnemyFromId(enemy_ids[rand]);
    }

    function createRandomWeightedEnemy() as Enemy? {
        var rand = MathUtil.random(0, total_weight - 1);
        var current_weight = 0;
        for (var i = 0; i < dungeon_enemies.size(); i++) {
            current_weight += dungeon_enemies[i][:weight];
            if (rand < current_weight) {
                return createEnemyFromId(dungeon_enemies[i][:id]);
            }
        }
        return null;
    }
}
