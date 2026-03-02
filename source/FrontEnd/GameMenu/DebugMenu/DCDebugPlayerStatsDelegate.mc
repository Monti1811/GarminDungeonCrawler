import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugPlayerStatsDelegate extends WatchUi.Menu2InputDelegate {

    private var _pending_attribute as Symbol?;

    function initialize() {
        Menu2InputDelegate.initialize();
        _pending_attribute = null;
    }

	function pushNumberPicker(label as String, start as Number, stop as Number, step as Number, current as Number, callback as Method) as Void {
        var picker = new DCDebugNumberPicker(label, start, stop, step, current);
        WatchUi.pushView(picker, new DCDebugNumberPickerDelegate(callback), WatchUi.SLIDE_UP);
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        var player = $.getApp().getPlayer();
        if (player == null) {
            WatchUi.showToast("No player", {:icon=>Rez.Drawables.cancelToastIcon});
            return;
        }
        if (id == :set_health) {
            pushNumberPicker("Health", 0, 9999, 1, player.getHealth(), new Lang.Method(self, :onHealthPicked));
        } else if (id == :set_max_health) {
            pushNumberPicker("Max Health", 1, 9999, 1, player.getMaxHealth(), new Lang.Method(self, :onMaxHealthPicked));
        } else if (id == :set_mana) {
            var max_mana = player.getMaxMana();
            pushNumberPicker("Mana", 0, MathUtil.max(max_mana, 1), 1, player.getCurrentMana(), new Lang.Method(self, :onManaPicked));
        } else if (id == :set_max_mana) {
            pushNumberPicker("Max Mana", 0, 9999, 1, player.getMaxMana(), new Lang.Method(self, :onMaxManaPicked));
        } else if (id == :set_gold) {
            pushNumberPicker("Gold", 0, 50000, 10, player.getGold(), new Lang.Method(self, :onGoldPicked));
        } else if (id == :attribute_points) {
            pushNumberPicker("Attribute Points", 0, 999, 1, player.getAttributePoints(), new Lang.Method(self, :onAttributePointsPicked));
        } else if (id instanceof Symbol && $.Constants.ATT_SYMBOL_TO_STR[id] != null) {
            _pending_attribute = id as Symbol;
            var current = player.getAttribute(_pending_attribute);
            var label = $.Constants.ATT_SYMBOL_TO_STR[_pending_attribute];
            pushNumberPicker(label, $.Constants.MIN_ATTRIBUTE_POINTS, $.Constants.MAX_ATTRIBUTE_POINTS, 1, current, new Lang.Method(self, :onAttributePicked));
        }
    }


    function onHealthPicked(value as Number) {
        setHealth(value);
    }

    function onMaxHealthPicked(value as Number) {
        setMaxHealth(value);
    }

    function onManaPicked(value as Number) {
        setMana(value);
    }

    function onMaxManaPicked(value as Number) {
        setMaxMana(value);
    }

    function onGoldPicked(value as Number) {
        setGold(value);
    }

    function onAttributePointsPicked(value as Number) {
        setAttributePoints(value);
    }

    function onAttributePicked(value as Number) {
        if (_pending_attribute != null) {
            setAttribute(_pending_attribute as Symbol, value);
            _pending_attribute = null;
        }
    }


    function setHealth(value as Number) as Void {
        var player = $.getApp().getPlayer();
        if (player == null) {
            return;
        }
        var bounded = $.MathUtil.clamp(value, 0, player.getMaxHealth());
        player.current_health = bounded;
        WatchUi.showToast("Health set to " + bounded, {:icon=>Rez.Drawables.aboutToastIcon});
    }

    function setMaxHealth(value as Number) as Void {
        var player = $.getApp().getPlayer();
        if (player == null) {
            return;
        }
        var bounded = $.MathUtil.clamp(value, 1, $.Constants.MAX_INT);
        player.maxHealth = bounded;
        if (player.getHealth() > bounded) {
            player.current_health = bounded;
        }
        WatchUi.showToast("Max health set to " + bounded, {:icon=>Rez.Drawables.aboutToastIcon});
    }

    function setMana(value as Number) as Void {
        var player = $.getApp().getPlayer();
        if (player != null && (player has :getCurrentMana)) {
			var bounded = $.MathUtil.clamp(value, 0, player.getMaxMana());
			if (player has :doManaDelta) {
				var delta = bounded - player.getCurrentMana();
				player.doManaDelta(delta);
			} else if (player has :current_mana) {
				player.current_mana = bounded;
			}
			WatchUi.showToast("Mana set to " + bounded, {:icon=>Rez.Drawables.aboutToastIcon});
		}
    }

    function setMaxMana(value as Number) as Void {
        var player = $.getApp().getPlayer();
        if (player == null || !(player has :getMaxMana)) {
            return;
        }
        var bounded = $.MathUtil.clamp(value, 0, $.Constants.MAX_INT);
        if (player has :maxMana) {
            player.maxMana = bounded;
        }
        if (player.getCurrentMana() > bounded) {
            setMana(bounded);
        }
        WatchUi.showToast("Max mana set to " + bounded, {:icon=>Rez.Drawables.aboutToastIcon});
    }

    function setGold(value as Number) as Void {
        var player = $.getApp().getPlayer();
        if (player == null) {
            return;
        }
        player.gold = $.MathUtil.clamp(value, 0, $.Constants.MAX_INT);
        WatchUi.showToast("Gold set to " + player.getGold(), {:icon=>Rez.Drawables.aboutToastIcon});
    }

    function setAttribute(attribute as Symbol, value as Number) as Void {
        var player = $.getApp().getPlayer();
        if (player == null) {
            return;
        }
        var bounded = $.MathUtil.clamp(value, $.Constants.MIN_ATTRIBUTE_POINTS, $.Constants.MAX_ATTRIBUTE_POINTS);
        player.setAttribute(attribute, bounded);
        WatchUi.showToast($.Constants.ATT_SYMBOL_TO_STR[attribute] + " set to " + bounded, {:icon=>Rez.Drawables.aboutToastIcon});
    }

    function setAttributePoints(value as Number) as Void {
        var player = $.getApp().getPlayer();
        if (player == null) {
            return;
        }
        player.setAttributePoints($.MathUtil.clamp(value, 0, $.Constants.MAX_INT));
        WatchUi.showToast("Attribute points set", {:icon=>Rez.Drawables.aboutToastIcon});
    }
}