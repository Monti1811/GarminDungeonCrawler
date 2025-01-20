import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCItemInfoValuesView extends WatchUi.View {

	private var _item as Item;
	private var _item_type as ItemType;

	private const distance_lines as Number = 35;

	private var small_font as FontResource;

	private const item_fn as Dictionary<ItemType, Symbol> = {
		WEAPON=> :showWeaponStats,
		ARMOR=> :showArmorStats,
		CONSUMABLE=> :showConsumableStats,
		QUEST=> :showKeyStats,
		CUSTOM=> :showCustomStats,
	};
	private var fn as Method;

    function initialize(item as Item) {
		View.initialize();
		_item = item;
		_item_type = item.getItemType();
		fn = method(item_fn[_item_type]);
		small_font = WatchUi.loadResource($.Rez.Fonts.small);
	}


	function onUpdate(dc) {
		dc.clear();
		fn.invoke(dc);
	}

	function drawText(dc, text, counter, x_start, font as Graphics.FontType?, distance as Number?) {
		if (font == null) {
			font = Graphics.FONT_XTINY;
		}
		if (distance == null) {
			distance = distance_lines;
		}
		dc.drawText(x_start, 90 + distance * counter, font, text, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawCommonAttributes(dc, text_left, text_right, counter, distance) as Void {
		dc.drawText(120, 70 + distance * counter, Graphics.FONT_XTINY, text_left, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(220, 70 + distance * counter, Graphics.FONT_XTINY, text_right, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawAttributes(dc, text_left, text_right, counter, distance, left as Boolean) as Void {
		if (left) {
			dc.drawText(60, 180 + distance * counter, small_font, text_left, Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(140, 180 + distance * counter, small_font, text_right, Graphics.TEXT_JUSTIFY_LEFT);
		} else {
			dc.drawText(180, 180 + distance * counter, small_font, text_left, Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(260, 180 + distance * counter, small_font, text_right, Graphics.TEXT_JUSTIFY_LEFT);
		}
	}

	function showWeaponStats(dc) {
		var weapon = _item as WeaponItem;
		drawCommonAttributes(dc, "Damage", ": " + weapon.getAttack(null), 0, 25);
		drawCommonAttributes(dc, "Equip Slot", ": " + Constants.EQUIPSLOT_TO_STR[weapon.getItemSlot()], 1, 25);
		drawCommonAttributes(dc, "Value", ": " + weapon.getValue(), 2, 25);
		var attribute_bonus = weapon.getAllAttributeBonuses();
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		if (bonus_keys.size() > 0) {
			dc.drawText(180, 165, Graphics.FONT_XTINY, "Attribute Bonus: ", Graphics.TEXT_JUSTIFY_CENTER);
			var attribute_keys = Constants.ATT_SYMBOL_TO_STR.keys() as Array<Symbol>;
			for (var i = 0; i < attribute_keys.size(); i++) {
				var symbol = attribute_keys[i];
				var attribute_bonus_value = weapon.getAttributeBonus(symbol);
				drawAttributes(dc, Constants.ATT_SYMBOL_TO_STR[symbol], ": " + attribute_bonus_value, i % 3, 15, i < 3);
			}
		}

	}

	function showArmorStats(dc) {
		var armor = _item as ArmorItem;
		drawText(dc, "Defense: " + armor.getDefense(null), 0, 60, null, null);
		drawText(dc, "Equip Slot: " + Constants.EQUIPSLOT_TO_STR[armor.getItemSlot()], 1, 60, null, null);
		drawText(dc, "Value: " + armor.getValue(), 2, 60, null, null);
	}

	function showConsumableStats(dc) {
		var consumable = _item as ConsumableItem;
		drawText(dc, "Effect: " + consumable.getEffectDescription(), 0, 60, null, null);
		drawText(dc, "Value: " + consumable.getValue(), 1, 60, null, null);

	}

	function showKeyStats(dc) {
		var questItem = _item as QuestItem;
		drawText(dc, "Key Item " + questItem.getName(), 0, 60, null, null);


	}

	function showCustomStats(dc) {
	}

}