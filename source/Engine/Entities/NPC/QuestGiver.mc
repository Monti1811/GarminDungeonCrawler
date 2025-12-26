import Toybox.Lang;
import Toybox.WatchUi;

class QuestGiver extends NPC {

	var quest_requested = false;
    var offers as Array<Quest> = [];

    function initialize() {
        NPC.initialize();
        id = 1;
        name = "Wandering Sage";
        description = "Offers challenges for worthy adventurers.";
        dialog = "Prove your worth and I shall reward you.";
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.Sage;
    }

    function onInteract() as Void {
        DCQuestDelegate.pushMenu(self);
    }

    function save() as Dictionary {
        var data = NPC.save();
        data["quest_requested"] = quest_requested;
        var serialized_offers = new Array<Dictionary>[offers.size()];
        for (var i = 0; i < offers.size(); i++) {
            serialized_offers[i] = offers[i].save();
        }
        data["offers"] = serialized_offers;
        return data;
    }

    function onLoad(save_data as Dictionary) as Void {
        NPC.onLoad(save_data);
        if (save_data["quest_requested"] != null) {
            quest_requested = save_data["quest_requested"] as Boolean;
        }
        offers = [];
        var stored_offers = save_data["offers"] as Array<Dictionary>?;
        if (stored_offers != null) {
            for (var i = 0; i < stored_offers.size(); i++) {
                var quest = Quest.load(stored_offers[i]);
                offers.add(quest);
            }
        }
    }

    function deepcopy() as Entity {
        var npc = new QuestGiver();
        npc.name = name;
        npc.pos = pos;
        npc.description = description;
        npc.dialog = dialog;
        npc.quest_requested = quest_requested;
        npc.offers = offers;
        return npc;
    }
}
