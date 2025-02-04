import Toybox.Lang;

class GrassSpell extends Spell {

    function initialize() {
        Spell.initialize();
        id = 46;
        name = "Grass Spell";
        description = "A powerful grass spell. If the player has mana available, uses it to perform a more powerful AoE attack.";
        slot = RIGHT_HAND;
        value = 100;
        weight = 1;
        attribute_bonus = {
			:wisdom => 3,
            :charisma => 3,
            :luck => 2
        };

        attack = 14;
        range = 3;
        cooldown = 1;
        attack_type = INTELLIGENCE;

        mana_loss = 34;
    }

    function activateSpell() as Void {
        Spell.activateSpell();
        attack = 14;
        range = 3;
        range_type = SURROUNDING;
    }

    function deactivateSpell() as Void {
        Spell.deactivateSpell();
        attack = 3;
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
        return $.Rez.Drawables.grass_spell;
    }

    function deepcopy() as Item {
        var spell = new GrassSpell();
        spell.name = name;
        spell.description = description;
        spell.value = value;
        spell.amount = amount;
        spell.attribute_bonus = attribute_bonus;
        spell.pos = pos;
        spell.equipped = equipped;
        spell.in_inventory = in_inventory;
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
