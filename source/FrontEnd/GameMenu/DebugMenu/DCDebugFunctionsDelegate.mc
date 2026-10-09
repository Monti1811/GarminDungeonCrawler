import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugFunctionsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as Symbol;
        switch (id) {
            case :action_materials:
                giveAllMaterials();
                break;
            case :reset_achievements:
                resetAchievements();
                break;
        }
    }

    function resetAchievements() as Void {
        $.Achievements.resetAchievements();
        WatchUi.showToast("Achievements reset", {:icon=>Rez.Drawables.aboutToastIcon});
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function giveAllMaterials() as Void {
        var player = $.getApp().getPlayer();
        if (player == null) {
            WatchUi.showToast("No player", {:icon=>Rez.Drawables.cancelToastIcon});
            return;
        }
        var added = 0;
        for (var id = $.MaterialUtil.MATERIAL_STEEL; id <= $.MaterialUtil.MATERIAL_BLOOD; id++) {
            var item = $.Items.createItemFromId(id);
            if (item == null) {
                continue;
            }
            item.amount = 6;
            if (player.addInventoryItem(item)) {
                added += 1;
            }
        }
        if (added == 9) {
            WatchUi.showToast("Added 6x of all 9 materials", {:icon=>Rez.Drawables.aboutToastIcon});
        } else {
            WatchUi.showToast("Added " + added + "/9 material stacks", {:icon=>Rez.Drawables.cancelToastIcon});
        }
        if (added > 0) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }
}
