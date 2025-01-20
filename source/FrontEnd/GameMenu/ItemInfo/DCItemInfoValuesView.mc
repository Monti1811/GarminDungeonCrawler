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
		dc.drawText(80, 70 + distance * counter, Graphics.FONT_XTINY, text_left, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(180, 70 + distance * counter, Graphics.FONT_XTINY, text_right, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawAttributes(dc, text_left, text_right, counter, distance, x_axis as Number) as Void {
		dc.drawText(x_axis, 200 + distance * counter, small_font, text_left, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(x_axis + 40, 200 + distance * counter, small_font, text_right, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawAttributeTable(dc as Dc) {
		dc.drawRectangle(90, 200, 175, 65);

	}

	function showWeaponStats(dc) {
		var weapon = _item as WeaponItem;
		drawCommonAttributes(dc, "Damage", ": " + weapon.getAttack(null), 0, 30);
		drawCommonAttributes(dc, "Equip Slot", ": " + Constants.EQUIPSLOT_TO_STR[weapon.getItemSlot()], 1, 30);
		drawCommonAttributes(dc, "Value", ": " + weapon.getValue(), 2, 30);
		var attribute_bonus = weapon.getAllAttributeBonuses();
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		if (bonus_keys.size() > 0) {
			dc.drawText(180, 165, Graphics.FONT_XTINY, "Attribute Bonus: ", Graphics.TEXT_JUSTIFY_CENTER);
			drawAttributeTable(dc);
			var attribute_keys = [
				:strength,
				:constitution,
				:dexterity,
				:intelligence,
				:wisdom,
				:charisma,
				:luck
			];
			for (var i = 0; i < attribute_keys.size(); i++) {
				var symbol = attribute_keys[i];
				var attribute_bonus_value = weapon.getAttributeBonus(symbol);
				if (attribute_bonus_value > 0) {
					attribute_bonus_value = "+" + attribute_bonus_value;
				}
				if (i == 6) {
					drawAttributes(dc, Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, 3, 15, 150);
				} else if (i < 3) {
					drawAttributes(dc, Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, 107);
				} else {
					drawAttributes(dc, Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, 187);
				}
			}
		}

	}

	function showArmorStats(dc) {
		var armor = _item as ArmorItem;
		drawCommonAttributes(dc, "Defense", ": " + armor.getDefense(null), 0, 30);
		drawCommonAttributes(dc, "Equip Slot", ": " + Constants.EQUIPSLOT_TO_STR[armor.getItemSlot()], 1, 30);
		drawCommonAttributes(dc, "Value", ": " + armor.getValue(), 2, 30);
		var attribute_bonus = armor.getAllAttributeBonuses();
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		if (bonus_keys.size() > 0) {
			dc.drawText(180, 165, Graphics.FONT_XTINY, "Attribute Bonus: ", Graphics.TEXT_JUSTIFY_CENTER);
			drawAttributeTable(dc);
			var attribute_keys = [
				:strength,
				:constitution,
				:dexterity,
				:intelligence,
				:wisdom,
				:charisma,
				:luck
			];
			for (var i = 0; i < attribute_keys.size(); i++) {
				var symbol = attribute_keys[i];
				var attribute_bonus_value = armor.getAttributeBonus(symbol);
				if (attribute_bonus_value > 0) {
					attribute_bonus_value = "+" + attribute_bonus_value;
				}
				if (i == 6) {
					drawAttributes(dc, Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, 3, 15, 150);
				} else if (i < 3) {
					drawAttributes(dc, Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, 107);
				} else {
					drawAttributes(dc, Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, 187);
				}
			}
		}
	}

	function showConsumableStats(dc) {
		var consumable = _item as ConsumableItem;
		drawCommonAttributes(dc, "Value", ": " + consumable.getValue(), 0, 30);
		dc.drawText(180, 125, Graphics.FONT_XTINY, "Effect: ", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		var formatted_text = Graphics.fitTextToArea(consumable.getEffectDescription(), Graphics.FONT_XTINY, 260, 150, false);
		dc.drawText(180, 150, Graphics.FONT_XTINY, formatted_text, Graphics.TEXT_JUSTIFY_CENTER);

	}

	function showKeyStats(dc) {
		var questItem = _item as QuestItem;
		drawText(dc, "Key Item " + questItem.getName(), 0, 60, null, null);


	}

	function showCustomStats(dc) {
	}

}