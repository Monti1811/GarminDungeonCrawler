import Toybox.Lang;

class BloodSpell extends Spell {

    function initialize() {
        Spell.initialize();
        id = 86;
        name = "Blood Spell";
        description = "A powerful blood spell. If the player has mana available, uses it to perform a more powerful AoE attack.";
        slot = RIGHT_HAND;
        value = 5000;
        weight = 0.5;
        attribute_bonus = {
            :wisdom => 20
        };

        attack = 64;
        range = 3;
        cooldown = 1;
        attack_type = INTELLIGENCE;

        mana_loss = 75;
    }

    function activateSpell() as Void {
        Spell.activateSpell();
        attack = 36;
        range = 3;
        range_type = SURROUNDING;
    }

    function deactivateSpell() as Void {
        Spell.deactivateSpell();
        attack = 16;
        range = 1;
        range_type = DIRECTIONAL;
    }

    function onEquipItem(player as Player) as Void {
        Spell.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        Spell.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_spell;
    }

    function deepcopy() as Item {
        var spell = new BloodSpell();
        // ...existing code...
        spell.attack = attack;
        spell.range = range;
        spell.range_type = range_type;
        spell.active = active;
        spell.current_cooldown = current_cooldown;
        return spell;
    }

    function onLoad(save_data as Dictionary) as Void {
        Spell.onLoad(save_data);
    }

    // ...existing code...
}
