import Toybox.Lang;

/*
IDs for items

0-999: Weapons
1000-1999: Armor
2000-2999: Consumables
3000-3999: Key Items

*/

enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	KEY,
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
	EITHER_HAND = 7,  // Represents items equippable in either hand
	ACCESSORY = 8,
	AMMUNITION = 9,
	NONE = 10
}

enum WeaponType {
	MELEE,
	TWOHAND,
	RANGED
}

enum AttackType {
	STRENGTH,
	DEXTERITY,
	INTELLIGENCE,
}

enum DefenseType {
	CONSTITUTION,
	WISDOM,
	CHARISMA
}

enum AmmunitionType {
	ARROW,
	FIRE_ARROW,
	ICE_ARROW
}