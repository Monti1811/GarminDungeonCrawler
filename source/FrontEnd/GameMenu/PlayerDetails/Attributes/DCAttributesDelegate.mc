import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class DCPlayerDetailsAttributesDelegate extends WatchUi.BehaviorDelegate {

    private const action_menu_area = [90, 260, 290, 360] as Array<Numeric>;

    public var changed_attributes as Dictionary<Symbol, Number>;

    function initialize() {
        BehaviorDelegate.initialize();
        var player = getApp().getPlayer();
        changed_attributes = {
            :strength => player.getAttribute(:strength),
            :constitution => player.getAttribute(:constitution),
            :dexterity => player.getAttribute(:dexterity),
            :intelligence => player.getAttribute(:intelligence),
            :wisdom => player.getAttribute(:wisdom),
            :charisma => player.getAttribute(:charisma),
            :luck => player.getAttribute(:luck),
            :total_used => 0,
            :available => player.getAttributePoints()
        };

        
    }

    function onBack() as Boolean {
        WatchUi.popView(SLIDE_DOWN);
        return true;
    }

    function onTap(clickEvent as ClickEvent) as Boolean {
        if (clickEvent.getType() == CLICK_TYPE_TAP) {
            var coord = clickEvent.getCoordinates();
            if (MathUtil.isInAreaArray(coord as Array<Numeric>, action_menu_area, 0.0)) {
                showActionMenu();
            }
            return true;
        }
        return false;
    }

    function showActionMenu() as Void{
        var points_available = changed_attributes[:available] - changed_attributes[:total_used];
        var actionMenu = new WatchUi.Menu2({:title=>"Attributes (" + points_available + " points)"});
        actionMenu.addItem(new WatchUi.MenuItem("Strength: " + changed_attributes[:strength], "Change Strength", :strength, null));
        actionMenu.addItem(new WatchUi.MenuItem("Constitution: " + changed_attributes[:constitution], "Change Constitution", :constitution, null));
        actionMenu.addItem(new WatchUi.MenuItem("Dexterity: " + changed_attributes[:dexterity], "Change Dexterity", :dexterity, null));
        actionMenu.addItem(new WatchUi.MenuItem("Intelligence: " + changed_attributes[:intelligence], "Change Intelligence", :intelligence, null));
        actionMenu.addItem(new WatchUi.MenuItem("Wisdom: " + changed_attributes[:wisdom], "Change Wisdom", :wisdom, null));
        actionMenu.addItem(new WatchUi.MenuItem("Charisma: " + changed_attributes[:charisma], "Change Charisma", :charisma, null));
        actionMenu.addItem(new WatchUi.MenuItem("Luck: " + changed_attributes[:luck], "Change Luck", :luck, null));

        WatchUi.pushView(actionMenu, new DCPlayerDetailsAttributesChangerDelegate(actionMenu, self), SLIDE_UP);
    }


}