import Toybox.Lang;

class DemonSpell extends Spell {

    function initialize() {
        Spell.initialize();
        id = 76;
        name = "Demon Spell";
        description = "A hellbound grimoire that unleashes AoE waves of abyssal flame when fueled by mana.";
        slot = RIGHT_HAND;
        value = 1000;
        weight = 0.5;
        attribute_bonus = {
            :wisdom => 10
        };

        attack = 58;
        range = 3;
        cooldown = 1;
        attack_type = INTELLIGENCE;

        mana_loss = 50;
    }

    function activateSpell() as Void {
        Spell.activateSpell();
        attack = 18;
        range = 3;
        range_type = SURROUNDING;
    }

    function deactivateSpell() as Void {
        Spell.deactivateSpell();
        attack = 8;
        range = 1;
        range_type = DIRECTIONAL;
    }

    function onEquipItem(player as Player, slot as ItemSlot) as Void {
        Spell.onEquipItem(player, slot);
    }

    function onUnequipItem(player as Player) as Void {
        Spell.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.demon_spell;
    }

    function deepcopy() as Item {
        var spell = new DemonSpell();
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
