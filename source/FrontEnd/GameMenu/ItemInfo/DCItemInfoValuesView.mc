import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCItemInfoValuesView extends WatchUi.View {

	private var _item as Item;
	private var _item_type as ItemType;

	private var distance_lines as Number;

	private var small_font as FontResource;

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
		distance_lines = ($.Constants.SCREEN_HEIGHT * 35 / 360).toNumber();
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
		var x_left = ($.Constants.SCREEN_WIDTH * 80 / 360).toNumber();
		var x_right = ($.Constants.SCREEN_WIDTH / 2).toNumber();
		var base_y = ($.Constants.SCREEN_HEIGHT * 70 / 360).toNumber();
		dc.drawText(x_left, base_y + distance * counter, Graphics.FONT_XTINY, text_left, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(x_right, base_y + distance * counter, Graphics.FONT_XTINY, text_right, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawAttributes(dc, text_left, text_right, counter, distance, x_axis as Number) as Void {
		var base_y = ($.Constants.SCREEN_HEIGHT * 230 / 360).toNumber();
		var offset_x = ($.Constants.SCREEN_WIDTH * 40 / 360).toNumber();
		dc.drawText(x_axis, base_y + distance * counter, small_font, text_left, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(x_axis + offset_x, base_y + distance * counter, small_font, text_right, Graphics.TEXT_JUSTIFY_LEFT);
	}

	function drawAttributeTable(dc as Dc) {
		var rect_x = ($.Constants.SCREEN_WIDTH * 90 / 360).toNumber();
		var rect_y = ($.Constants.SCREEN_HEIGHT * 230 / 360).toNumber();
		var rect_w = ($.Constants.SCREEN_WIDTH * 175 / 360).toNumber();
		var rect_h = ($.Constants.SCREEN_HEIGHT * 65 / 360).toNumber();
		dc.drawRectangle(rect_x, rect_y, rect_w, rect_h);

	}

	function showWeaponStats(dc) {
		var weapon = _item as WeaponItem;
		drawCommonAttributes(dc, "Damage", ": " + weapon.getBaseAttack(), 0, 30);
		drawCommonAttributes(dc, "Equip Slot", ": " + $.Constants.EQUIPSLOT_TO_STR[weapon.getItemSlot()], 1, 30);
		drawCommonAttributes(dc, "Value", ": " + weapon.getValue(), 2, 30);
		drawCommonAttributes(dc, "Weight", ": " + weapon.getWeight(), 3, 30);
		var attribute_bonus = weapon.getAllAttributeBonuses();
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		if (bonus_keys.size() > 0) {
			var title_x = ($.Constants.SCREEN_WIDTH / 2).toNumber();
			var title_y = ($.Constants.SCREEN_HEIGHT * 195 / 360).toNumber();
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
			var x_left = ($.Constants.SCREEN_WIDTH * 107 / 360).toNumber();
			var x_center = ($.Constants.SCREEN_WIDTH * 150 / 360).toNumber();
			var x_right = ($.Constants.SCREEN_WIDTH * 187 / 360).toNumber();
			for (var i = 0; i < attribute_keys.size(); i++) {
				var symbol = attribute_keys[i];
				var attribute_bonus_value = weapon.getAttributeBonus(symbol);
				if (attribute_bonus_value > 0) {
					attribute_bonus_value = "+" + attribute_bonus_value;
				}
				if (i == 6) {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, 3, 15, x_center);
				} else if (i < 3) {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, x_left);
				} else {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, x_right);
				}
			}
		}

	}

	function showArmorStats(dc) {
		var armor = _item as ArmorItem;
		drawCommonAttributes(dc, "Defense", ": " + armor.getBaseDefense(), 0, 30);
		drawCommonAttributes(dc, "Equip Slot", ": " + $.Constants.EQUIPSLOT_TO_STR[armor.getItemSlot()], 1, 30);
		drawCommonAttributes(dc, "Value", ": " + armor.getValue(), 2, 30);
		drawCommonAttributes(dc, "Weight", ": " + armor.getWeight(), 3, 30);
		var attribute_bonus = armor.getAllAttributeBonuses();
		var bonus_keys = attribute_bonus.keys() as Array<Symbol>;
		if (bonus_keys.size() > 0) {
			var title_x = ($.Constants.SCREEN_WIDTH / 2).toNumber();
			var title_y = ($.Constants.SCREEN_HEIGHT * 195 / 360).toNumber();
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
			var x_left = ($.Constants.SCREEN_WIDTH * 107 / 360).toNumber();
			var x_center = ($.Constants.SCREEN_WIDTH * 150 / 360).toNumber();
			var x_right = ($.Constants.SCREEN_WIDTH * 187 / 360).toNumber();
			for (var i = 0; i < attribute_keys.size(); i++) {
				var symbol = attribute_keys[i];
				var attribute_bonus_value = armor.getAttributeBonus(symbol);
				if (attribute_bonus_value > 0) {
					attribute_bonus_value = "+" + attribute_bonus_value;
				}
				if (i == 6) {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, 3, 15, x_center);
				} else if (i < 3) {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, x_left);
				} else {
					drawAttributes(dc, $.Constants.ATT_SYMBOL_TO_STR_SHORT[symbol], ": " + attribute_bonus_value, i % 3, 15, x_right);
				}
			}
		}
	}

	function showConsumableStats(dc) {
		var consumable = _item as ConsumableItem;
		drawCommonAttributes(dc, "Value", ": " + consumable.getValue(), 0, 30);
		drawCommonAttributes(dc, "Weight", ": " + consumable.getWeight(), 1, 30);
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