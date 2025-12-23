import Toybox.Lang;

module Enemies {

    var enemies as Dictionary<Number, Symbol> = {
        0 => :createFrog, 
        1 => :createBat,
        2 => :createDemon,
        3 => :createOrc,
        4 => :createImp,
        5 => :createSkeleton,
        6 => :createNecromancer,
        7 => :createZombieSmall,
        8 => :createZombie,
        9 => :createWogol,
        10 => :createOgre,
        11 => :createDarkKnight,
        12 => :createElementalAirSmall,
        13 => :createElementalEarthSmall,
        14 => :createElementalFireSmall,
        15 => :createElementalGoldSmall,
        16 => :createElementalGooSmall,
        30 => :createElementalPlantSmall,
        17 => :createElementalWaterSmall,
        18 => :createElementalAir,
        19 => :createElementalEarth,
        20 => :createElementalFire,
        21 => :createElementalGold,
        22 => :createElementalGoo,
        23 => :createElementalPlant,
        24 => :createElementalWater,
        25 => :createGoblin,
        26 => :createTentackle,
        27 => :createDemonolog,
        28 => :createChort,
        29 => :createBies,
        31 => :createOrcArmored,
        32 => :createOrcMasked,
        33 => :createOrcShaman,
        34 => :createOrcVeteran,
        35 => :createRokita,
    };

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

    function createImp() as Enemy {
        return new Imp();
    }

    function createSkeleton() as Enemy {
        return new Skeleton();
    }

    function createNecromancer() as Enemy {
        return new Necromancer();
    }

    function createZombieSmall() as Enemy {
        return new ZombieSmall();
    }

    function createZombie() as Enemy {
        return new Zombie();
    }

    function createWogol() as Enemy {
        return new Wogol();
    }

    function createOgre() as Enemy {
        return new Ogre();
    }

    function createDarkKnight() as Enemy {
        return new DarkKnight();
    }

    function createElementalAirSmall() as Enemy {
        return new ElementalAirSmall();
    }

    function createElementalEarthSmall() as Enemy {
        return new ElementalEarthSmall();
    }

    function createElementalFireSmall() as Enemy {
        return new ElementalFireSmall();
    }

    function createElementalGoldSmall() as Enemy {
        return new ElementalGoldSmall();
    }

    function createElementalGooSmall() as Enemy {
        return new ElementalGooSmall();
    }

    function createElementalPlantSmall() as Enemy {
        return new ElementalPlantSmall();
    }

    function createElementalWaterSmall() as Enemy {
        return new ElementalWaterSmall();
    }

    function createElementalAir() as Enemy {
        return new ElementalAir();
    }

    function createElementalEarth() as Enemy {
        return new ElementalEarth();
    }

    function createElementalFire() as Enemy {
        return new ElementalFire();
    }

    function createElementalGold() as Enemy {
        return new ElementalGold();
    }

    function createElementalGoo() as Enemy {
        return new ElementalGoo();
    }

    function createElementalPlant() as Enemy {
        return new ElementalPlant();
    }

    function createElementalWater() as Enemy {
        return new ElementalWater();
    }

    function createGoblin() as Enemy {
        return new Goblin();
    }

    function createTentackle() as Enemy {
        return new Tentackle();
    }

    function createDemonolog() as Enemy {
        return new Demonolog();
    }

    function createChort() as Enemy {
        return new Chort();
    }

    function createBies() as Enemy {
        return new Bies();
    }

    function createOrcArmored() as Enemy {
        return new OrcArmored();
    }

    function createOrcMasked() as Enemy {
        return new OrcMasked();
    }

    function createOrcShaman() as Enemy {
        return new OrcShaman();
    }

    function createOrcVeteran() as Enemy {
        return new OrcVeteran();
    }

    function createRokita() as Enemy {
        return new Rokita();
    }

    function createEnemyFromId(id as Number) as Enemy {
        var method = new Lang.Method(self, enemies[id]);
        return method.invoke() as Enemy;
    }

    function createRandomEnemy() as Enemy {
        var enemy_keys = enemies.keys();
        var rand = MathUtil.random(0, enemy_keys.size() - 1);
        var method = new Lang.Method(self, enemies[rand]);
        return method.invoke() as Enemy;
    }

    function createRandomWeightedEnemy() as Enemy? {
        var rand = MathUtil.random(0, total_weight - 1);
        var current_weight = 0;
        for (var i = 0; i < dungeon_enemies.size(); i++) {
            current_weight += dungeon_enemies[i][:weight];
            if (rand < current_weight) {
                var method = new Lang.Method(self, enemies[dungeon_enemies[i][:id]]);
                return method.invoke() as Enemy;
            }
        }
        return null;
    }
}