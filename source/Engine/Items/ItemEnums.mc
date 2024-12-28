import Toybox.Lang;

enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	QUEST,
	CUSTOM
}

enum ItemSlot {
	HEAD = 0,
	CHEST = 1,
	BACK = 2,
	LEGS = 3,
	FEET = 4,
	LEFT_HAND = 5,
	RIGHT_HAND = 6,
	ACCESSORY = 7,
	NONE = 8
}

/*
IDs for items

0-999: Weapons
1000-1999: Armor
2000-2999: Consumables
3000-3999: Quest Items

*/