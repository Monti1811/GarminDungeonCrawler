import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCItemInfoValuesView extends WatchUi.View {

	private var _item as Item;
	private var _item_type as ItemType;

	private var _bgBitmap as BitmapReference;
	private var _itemIcon as BitmapReference;
	private var _small_font as FontResource;
	private var _overlayTop as BitmapReference?;
	private var _overlayBottom as BitmapReference?;

	private const GOLD_COLOR = 0xFFD700;

	private const ATTR_LEFT = [
		:strength,
		:constitution,
		:dexterity
	] as Array<Symbol>;

	private const ATTR_RIGHT = [
		:intelligence,
		:wisdom,
		:charisma
	] as Array<Symbol>;

	private const item_fn = {
		WEAPON => :showWeaponStats,
		ARMOR => :showArmorStats,
		CONSUMABLE => :showConsumableStats,
		KEY => :showKeyStats,
		CUSTOM => :showCustomStats,
	} as Dictionary<ItemType, Symbol>;
	private var _fn as Method;

	function initialize(item as Item) {
		View.initialize();
		_item = item;
		_item_type = item.getItemType();
		_fn = method(item_fn[_item_type]);

		// Hintergrundbild je nach Item-Typ laden
		if (_item_type == CONSUMABLE) {
			_bgBitmap = WatchUi.loadResource($.Rez.Drawables.itemInfoMenuConsumable) as BitmapReference;
		} else if (_item_type == WEAPON) {
			_bgBitmap = WatchUi.loadResource($.Rez.Drawables.itemInfoMenuEmptyRound) as BitmapReference;
			_overlayTop = WatchUi.loadResource($.Rez.Drawables.itemInfoMenuWeaponIcon) as BitmapReference;
			_overlayBottom = WatchUi.loadResource($.Rez.Drawables.itemInfoMenuDamageIcon) as BitmapReference;
		} else if (_item_type == ARMOR) {
			_bgBitmap = WatchUi.loadResource($.Rez.Drawables.itemInfoMenuEmptyRound) as BitmapReference;
			_overlayTop = WatchUi.loadResource($.Rez.Drawables.itemInfoMenuShieldIcon) as BitmapReference;
			_overlayBottom = WatchUi.loadResource($.Rez.Drawables.itemInfoMenuShieldIcon) as BitmapReference;
		} else {
			_bgBitmap = WatchUi.loadResource($.Rez.Drawables.itemInfoMenu) as BitmapReference;
		}

		_itemIcon = WatchUi.loadResource(item.getSprite()) as BitmapReference;
		_small_font = WatchUi.loadResource($.Rez.Fonts.small) as FontResource;
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();

		dc.drawScaledBitmap(0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, _bgBitmap);

		// Overlays für Waffen/Rüstung zeichnen
		if (_overlayTop != null) {
			var top_x = (Constants.SCREEN_WIDTH * 164 / 360).toNumber();
			var top_y = (Constants.SCREEN_HEIGHT * 28 / 360).toNumber();
			dc.drawBitmap(top_x, top_y, _overlayTop);
		}
		if (_overlayBottom != null) {
			var bot_x = (Constants.SCREEN_WIDTH * 159 / 360).toNumber();
			var bot_y = (Constants.SCREEN_HEIGHT * 102 / 360).toNumber();
			dc.drawBitmap(bot_x, bot_y, _overlayBottom);
		}

		drawItemIcon(dc);
		drawHeader(dc);
		_fn.invoke(dc);
	}

	// --- Header: Item Name + Item Type ---
	function drawHeader(dc) {
		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var name_y = (Constants.SCREEN_HEIGHT * 72 / 360).toNumber();
		var type_y = (Constants.SCREEN_HEIGHT * 93 / 360).toNumber();

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(text_x, name_y, Graphics.FONT_TINY, _item.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		var type_str = $.Constants.ITEMTYPE_TO_STR[_item_type] as String;
		dc.setColor(GOLD_COLOR, Graphics.COLOR_TRANSPARENT);
		dc.drawText(text_x, type_y, _small_font, type_str, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	// --- Item-Icon im blauen Rahmen ---
	function drawItemIcon(dc) {
		var x = (Constants.SCREEN_WIDTH * 68 / 360).toNumber();
		var y = (Constants.SCREEN_HEIGHT * 116 / 360).toNumber();
		var size = (Constants.SCREEN_WIDTH * 64 / 360).toNumber();
		dc.drawScaledBitmap(x, y, size, size, _itemIcon);
	}

	// --- 3 Stat-Werte rechts (nur Werte) ---
	function drawStats(dc) {
		var x_val = (Constants.SCREEN_WIDTH * 305 / 360).toNumber();
		var y1 = (Constants.SCREEN_HEIGHT * 119 / 360).toNumber();
		var y2 = (Constants.SCREEN_HEIGHT * 148 / 360).toNumber();
		var y3 = (Constants.SCREEN_HEIGHT * 175 / 360).toNumber();

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		if (_item_type == WEAPON) {
			var weapon = _item as WeaponItem;
			dc.drawText(x_val, y1, Graphics.FONT_XTINY, "" + weapon.getBaseAttack(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(x_val, y2, Graphics.FONT_XTINY, "" + weapon.getValue(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(x_val, y3, Graphics.FONT_XTINY, "" + weapon.getWeight(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		} else if (_item_type == ARMOR) {
			var armor = _item as ArmorItem;
			dc.drawText(x_val, y1, Graphics.FONT_XTINY, "" + armor.getBaseDefense(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(x_val, y2, Graphics.FONT_XTINY, "" + armor.getValue(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(x_val, y3, Graphics.FONT_XTINY, "" + armor.getWeight(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		} else if (_item_type == CONSUMABLE) {
			var consumable = _item as ConsumableItem;
			// Zeile 1: Type (Health/Mana)
			var consumable_type = "None";
			switch (_item.tag) {
				case :mana:
					consumable_type = "Mana";
					break;
				case :health:
					consumable_type = "Health";
					break;
				default:
					consumable_type = "None";
			}
			if (_item.tag == :mana) {
				consumable_type = "Mana";
			}
			dc.drawText(x_val, y1, Graphics.FONT_XTINY, consumable_type, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
			// Zeile 2: Value
			dc.drawText(x_val, y2, Graphics.FONT_XTINY, "" + consumable.getValue(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
			// Zeile 3: Weight
			dc.drawText(x_val, y3, Graphics.FONT_XTINY, "" + consumable.getWeight(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		} else if (_item_type == KEY) {
			dc.drawText(x_val, y1, Graphics.FONT_XTINY, _item.getName(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}

	// --- Equip Slot unter dem Icon ---
	function drawEquipSlot(dc) {
		var x = (Constants.SCREEN_WIDTH * 109 / 360).toNumber();
		var y = (Constants.SCREEN_HEIGHT * 198 / 360).toNumber();

		var slot_name = "";
		if (_item_type == WEAPON) {
			slot_name = $.Constants.EQUIPSLOT_TO_STR[(_item as WeaponItem).getItemSlot()];
		} else if (_item_type == ARMOR) {
			slot_name = $.Constants.EQUIPSLOT_TO_STR[(_item as ArmorItem).getItemSlot()];
		}

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(x, y, _small_font, slot_name, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	// --- Attribute Bonus (nur Werte) ---
	function drawAttributeBonuses(dc) {
		if (_item_type != WEAPON && _item_type != ARMOR) {
			return;
		}
		var equippable = _item as EquippableItem;
		var bonus = equippable.getAllAttributeBonuses();
		if (bonus == null || bonus.size() == 0) {
			return;
		}

		var x_left = (Constants.SCREEN_WIDTH * 158 / 360).toNumber();
		var x_right = (Constants.SCREEN_WIDTH * 284 / 360).toNumber();

		var y_rows = [
			(Constants.SCREEN_HEIGHT * 245 / 360).toNumber(),
			(Constants.SCREEN_HEIGHT * 263 / 360).toNumber(),
			(Constants.SCREEN_HEIGHT * 281 / 360).toNumber()
		] as Array<Number>;
		var y_lck = (Constants.SCREEN_HEIGHT * 305 / 360).toNumber();

		// Linke Spalte: STR, CON, DEX
		for (var i = 0; i < 3; i++) {
			var val = equippable.getAttributeBonus(ATTR_LEFT[i]);
			var val_str = "" + val;
			if (val > 0) {
				val_str = "+" + val;
				dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			} else if (val < 0) {
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			}
			dc.drawText(x_left, y_rows[i], _small_font, val_str, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		}

		// Rechte Spalte: INT, WIS, CHA
		for (var i = 0; i < 3; i++) {
			var val = equippable.getAttributeBonus(ATTR_RIGHT[i]);
			var val_str = "" + val;
			if (val > 0) {
				val_str = "+" + val;
				dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			} else if (val < 0) {
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			}
			dc.drawText(x_right, y_rows[i], _small_font, val_str, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		}

		// LCK zentriert unten
		var lck_val = equippable.getAttributeBonus(:luck);
		var lck_str = "" + lck_val;
		if (lck_val > 0) {
			lck_str = "+" + lck_val;
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		} else if (lck_val < 0) {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		} else {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		}
		var lck_x = (Constants.SCREEN_WIDTH * 214 / 360).toNumber();
		dc.drawText(lck_x, y_lck, _small_font, lck_str, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	// --- Effect Description für Consumables ---
	function drawEffectDescription(dc) {
		if (_item_type != CONSUMABLE) {
			return;
		}
		var consumable = _item as ConsumableItem;
		var effect = consumable.getEffectDescription();

		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var text_y = (Constants.SCREEN_HEIGHT * 265 / 360).toNumber();
		var area_w = (Constants.SCREEN_WIDTH * 280 / 360).toNumber();
		var area_h = (Constants.SCREEN_HEIGHT * 80 / 360).toNumber();

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		var formatted = Graphics.fitTextToArea(effect, _small_font, area_w, area_h, false);
		dc.drawText(text_x, text_y, _small_font, formatted, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	// --- Typspezifische Stats ---
	function showWeaponStats(dc) {
		drawStats(dc);
		drawEquipSlot(dc);
		drawAttributeBonuses(dc);
	}

	function showArmorStats(dc) {
		drawStats(dc);
		drawEquipSlot(dc);
		drawAttributeBonuses(dc);
	}

	function showConsumableStats(dc) {
		drawStats(dc);
		drawEquipSlot(dc);
		drawEffectDescription(dc);
	}

	function showKeyStats(dc) {
		drawStats(dc);
	}

	function showCustomStats(dc) {
	}

}
