import Toybox.Lang;
import Toybox.WatchUi;



class DCItemInfoValuesView extends WatchUi.View {

	private var _item as Item;
	private var _item_type as ItemType;

	private const distance_lines as Number = 35;

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
	}


	function onUpdate(dc) {
		dc.clear();
		fn.invoke(dc);
	}

	function drawText(dc, text, counter) {
		dc.drawText(180, 90 + distance_lines * counter, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);
	}

	function showWeaponStats(dc) {
		var weapon = _item as WeaponItem;
		drawText(dc, "Damage: " + weapon.getAttack(), 0);
		drawText(dc, "Equip Slot: " + weapon.getItemSlot(), 1);
		drawText(dc, "Value: " + weapon.getValue(), 2);

	}

	function showArmorStats(dc) {
		var armor = _item as ArmorItem;
		drawText(dc, "Defense: " + armor.getDefense(), 0);
		drawText(dc, "Equip Slot: " + armor.getItemSlot(), 1);
		drawText(dc, "Value: " + armor.getValue(), 2);
	}

	function showConsumableStats(dc) {
		var consumable = _item as ConsumableItem;
		drawText(dc, "Effect: " + consumable.getEffectDescription(), 0);
		drawText(dc, "Value: " + consumable.getValue(), 1);

	}

	function showKeyStats(dc) {
		var questItem = _item as QuestItem;
		drawText(dc, "Key Item " + questItem.getName(), 0);


	}

	function showCustomStats(dc) {
	}

}