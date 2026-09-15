import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

	class DCItemInfoValuesView extends WatchUi.View {

	private var _item as Item;
	private var _item_type as ItemType;

	private var distance_lines as Number;

	private var small_font as FontResource;

	// Common attributes layout
	private var _common_base_y as Number;
	private var _common_x_left as Number;
	private var _common_x_right as Number;

	// Attribute table layout
	private var _rect_x as Number;
	private var _rect_y as Number;
	private var _rect_w as Number;
	private var _rect_h as Number;
	private var _attr_row_dist as Number;
	private var _attr_x_left as Number;
	private var _attr_x_right as Number;
	private var _attr_x_center as Number;
	private var _attr_x_value_offset as Number;
	private var _attr_base_y as Number;

	private const item_fn = {
		WEAPON => :showWeaponStats,
		ARMOR => :showArmorStats,
		CONSUMABLE => :showConsumableStats,
		KEY => :showKeyStats,
		CUSTOM => :showCustomStats,
	} as Dictionary<ItemType, Symbol>;
	private var fn as Method;

    function initialize(item as Item) {
		View.initialize();
		_item = item;
		_item_type = item.getItemType();
		fn = method(item_fn[_item_type]);
		small_font = WatchUi.loadResource($.Rez.Fonts.small);

		var layout = computeLayout($.Constants.SCREEN_WIDTH, $.Constants.SCREEN_HEIGHT);
		distance_lines = layout[:distance_lines];
		_common_base_y = layout[:common_base_y];
		_common_x_left = layout[:common_x_left];
		_common_x_right = layout[:common_x_right];
		_rect_x = layout[:rect_x];
		_rect_y = layout[:rect_y];
		_rect_w = layout[:rect_w];
		_rect_h = layout[:rect_h];
		_attr_row_dist = layout[:attr_row_dist];
		_attr_x_left = layout[:attr_x_left];
		_attr_x_right = layout[:attr_x_right];
		_attr_x_center = layout[:attr_x_center];
		_attr_x_value_offset = layout[:attr_x_value_offset];
		_attr_base_y = layout[:attr_base_y];
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
		var base_y = ($.Constants.SCREEN_HEIGHT * 90 / 360).toNumber();
		dc.drawText(x_start, base_y + distance * counter, font, text, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawCommonAttributes(dc, text_left, text_right, counter, distance) as Void {
		dc.drawText(_common_x_left, _common_base_y + distance * counter, Graphics.FONT_XTINY, text_left, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(_common_x_right, _common_base_y + distance * counter, Graphics.FONT_XTINY, text_right, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function computeLayout(screen_w as Number, screen_h as Number) as Dictionary {
		var distance_lines = 0;
		var distance_small = 0;
		if (screen_h < 260) {
			distance_lines = (screen_h * 28 / 360).toNumber();
			distance_small = (screen_h * 22 / 360).toNumber();
		} else {
			distance_lines = (screen_h * 35 / 360).toNumber();
			distance_small = (screen_h * 15 / 360).toNumber();
		}

		var common_base_y = (screen_h * 70 / 360).toNumber();
		// On round displays, text near the edges gets clipped by the circle.
		// Move left margin right on larger screens to keep "Equip Slot" visible.
		var common_x_left = (screen_w * 80 / 360).toNumber();
		if (screen_w > 400) {
			common_x_left = (screen_w * 100 / 360).toNumber();
		}
		var common_x_right = (screen_w / 2).toNumber();

		var attr_row_dist = distance_small > 14 ? distance_small : 14;

		// rect_h: fit exactly 4 rows of attributes + minimal padding
		var rect_h = attr_row_dist * 4 + 5;

		// rect_w: proportional, capped at 360px values
		var raw_rect_w = (screen_w * 175 / 360).toNumber();
		var rect_w = raw_rect_w > 175 ? 175 : raw_rect_w;
		var rect_x = ((screen_w - rect_w) / 2).toNumber();

		// rect_y: clearly below "Attribute Bonus:" title
		var title_y = common_base_y + 4 * distance_lines;
		var title_gap = distance_lines > 28 ? distance_lines : 28;
		var rect_y = title_y + title_gap;

		var raw_left = (screen_w * 17 / 360).toNumber();
		var raw_right = (screen_w * 97 / 360).toNumber();
		var raw_voffset = (screen_w * 40 / 360).toNumber();
		var attr_x_left = rect_x + (raw_left > 17 ? 17 : raw_left);
		var attr_x_right = rect_x + (raw_right > 97 ? 97 : raw_right);
		var attr_x_center = rect_x + rect_w / 2;
		var attr_x_value_offset = raw_voffset > 40 ? 40 : raw_voffset;

		var attr_base_y = rect_y;

		return {
			:distance_lines => distance_lines,
			:distance_small => distance_small,
			:common_base_y => common_base_y,
			:common_x_left => common_x_left,
			:common_x_right => common_x_right,
			:rect_x => rect_x,
			:rect_y => rect_y,
			:rect_w => rect_w,
			:rect_h => rect_h,
			:attr_row_dist => attr_row_dist,
			:attr_x_left => attr_x_left,
			:attr_x_right => attr_x_right,
			:attr_x_center => attr_x_center,
			:attr_x_value_offset => attr_x_value_offset,
			:attr_base_y => attr_base_y
		};
	}

	function drawAttributes(dc, text_left, text_right, counter, x_axis as Number) as Void {
		dc.drawText(x_axis, _attr_base_y + _attr_row_dist * counter, small_font, text_left, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(x_axis + _attr_x_value_offset, _attr_base_y + _attr_row_dist * counter, small_font, text_right, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawAttributeTable(dc as Dc) {
		dc.drawRectangle(_rect_x, _rect_y, _rect_w, _rect_h);
	}

	function showWeaponStats(dc) {
		var weapon = _item as WeaponItem;
		drawCommonAttributes(dc, "Damage", ": " + weapon.getBaseAttack(), 0, distance_lines);
		drawCommonAttributes(dc, "Equip Slot", ": " + $.Constants.EQUIPSLOT_TO_STR[weapon.getItemSlot()], 1, distance_lines);
		drawCommonAttributes(dc, "Value", ": " + weapon.getValue(), 2, distance_lines);
		drawCommonAttributes(dc, "Weight", ": " + weapon.getWeight(), 3, distance_lines);
		var attribute_bonus = weapon.getAllAttributeBonuses();
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		if (bonus_keys.size() > 0) {
			var title_x = ($.Constants.SCREEN_WIDTH / 2).toNumber();
			var title_y = _common_base_y + 4 * distance_lines;
			dc.drawText(title_x, title_y, Graphics.FONT_XTINY, "Attribute Bonus: ", Graphics.TEXT_JUSTIFY_CENTER);
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
					dc.drawText(_attr_x_center, _attr_base_y + _attr_row_dist * 3, small_font, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol] + " : " + attribute_bonus_value, Graphics.TEXT_JUSTIFY_CENTER);
				} else if (i < 3) {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, _attr_x_left);
				} else {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, _attr_x_right);
				}
			}
		}

	}

	function showArmorStats(dc) {
		var armor = _item as ArmorItem;
		drawCommonAttributes(dc, "Defense", ": " + armor.getBaseDefense(), 0, distance_lines);
		drawCommonAttributes(dc, "Equip Slot", ": " + $.Constants.EQUIPSLOT_TO_STR[armor.getItemSlot()], 1, distance_lines);
		drawCommonAttributes(dc, "Value", ": " + armor.getValue(), 2, distance_lines);
		drawCommonAttributes(dc, "Weight", ": " + armor.getWeight(), 3, distance_lines);
		var attribute_bonus = armor.getAllAttributeBonuses();
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		if (bonus_keys.size() > 0) {
			var title_x = ($.Constants.SCREEN_WIDTH / 2).toNumber();
			var title_y = _common_base_y + 4 * distance_lines;
			dc.drawText(title_x, title_y, Graphics.FONT_XTINY, "Attribute Bonus: ", Graphics.TEXT_JUSTIFY_CENTER);
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
					dc.drawText(_attr_x_center, _attr_base_y + _attr_row_dist * 3, small_font, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol] + " : " + attribute_bonus_value, Graphics.TEXT_JUSTIFY_CENTER);
				} else if (i < 3) {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, _attr_x_left);
				} else {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, _attr_x_right);
				}
			}
		}
	}

	function showConsumableStats(dc) {
		var consumable = _item as ConsumableItem;
		drawCommonAttributes(dc, "Value", ": " + consumable.getValue(), 0, distance_lines);
		drawCommonAttributes(dc, "Weight", ": " + consumable.getWeight(), 1, distance_lines);
		var text_x = ($.Constants.SCREEN_WIDTH / 2).toNumber();
		var text_y1 = ($.Constants.SCREEN_HEIGHT * 155 / 360).toNumber();
		var text_y2 = ($.Constants.SCREEN_HEIGHT / 2).toNumber();
		var area_w = ($.Constants.SCREEN_WIDTH * 260 / 360).toNumber();
		var area_h = ($.Constants.SCREEN_HEIGHT * 130 / 360).toNumber();
		dc.drawText(text_x, text_y1, Graphics.FONT_XTINY, "Effect: ", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		var formatted_text = Graphics.fitTextToArea(consumable.getEffectDescription(), Graphics.FONT_XTINY, area_w, area_h, false);
		dc.drawText(text_x, text_y2, Graphics.FONT_XTINY, formatted_text, Graphics.TEXT_JUSTIFY_CENTER);

	}

	function showKeyStats(dc) {
		var keyItem = _item as KeyItem;
		var x_start = ($.Constants.SCREEN_WIDTH * 60 / 360).toNumber();
		drawText(dc, "Key Item " + keyItem.getName(), 0, x_start, null, null);


	}

	function showCustomStats(dc) {
	}

}