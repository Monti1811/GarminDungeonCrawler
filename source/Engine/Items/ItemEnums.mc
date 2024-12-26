import Toybox.Lang;

enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	QUEST,
	CUSTOM
}

enum ItemSlot {
	HEAD = "head",
	CHEST = "chest",
	BACK = "back",
	LEGS = "legs",
	FEET = "feet",
	LEFT_HAND = "left_hand",
	RIGHT_HAND = "right_hand",
	ACCESSORY = "accessory",
	NONE = "none"
}

/*
IDs for items

0-999: Weapons
1000-1999: Armor
2000-2999: Consumables
3000-3999: Quest Items

*/