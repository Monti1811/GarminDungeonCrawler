import Toybox.Lang;

module Constants {

	public const MAX_INT = 65535;

	public const MAX_ATTRIBUTE_POINTS = 500;
	public const MIN_ATTRIBUTE_POINTS = 0;

	public const COORDINATES_NEWGAME = [180, 75, 150, 50] as Array<Number>;
	public const COORDINATES_LOADGAME = [180, 290, 150, 50] as Array<Number>;
	public const TAP_TOLERANCE = 0.10;

	public const COORDINATES_KNIGHT = [220, 120] as Array<Number>;

	public const TILE_SIZE = 16;

	public const ITEMTYPE_TO_STR = {
		WEAPON => "Weapon",
		ARMOR => "Armor",
		CONSUMABLE => "Consumable",
		KEY => "Key"
	};

	public const ATT_SYMBOL_TO_STR = {
        :strength => "Strength",
        :constitution => "Constitution",
        :dexterity => "Dexterity",
        :intelligence => "Intelligence",
        :wisdom => "Wisdom",
        :charisma => "Charisma",
        :luck => "Luck"
    };

	public const ATT_SYMBOL_TO_STR_SHORT = {
        :strength => "STR",
        :constitution => "CON",
        :dexterity => "DEX",
        :intelligence => "INT",
        :wisdom => "WIS",
        :charisma => "CHA",
        :luck => "LCK"
    };

	public const ATT_STR_TO_SYMBOL = {
		"Strength" => :strength,
		"Constitution" => :constitution,
		"Dexterity" => :dexterity,
		"Intelligence" => :intelligence,
		"Wisdom" => :wisdom,
		"Charisma" => :charisma,
		"Luck" => :luck
	};

	public const EQUIPSLOT_TO_STR = {
		HEAD => "Head",
		CHEST => "Chest",
		BACK => "Back",
		LEGS => "Legs",
		FEET => "Feet",
		LEFT_HAND => "Left Hand",
		RIGHT_HAND => "Right Hand",
		ACCESSORY => "Accessory",
		AMMUNITION => "Ammunition",
		NONE => "None"
	} as Dictionary<ItemSlot, String>;

	public const STR_TO_EQUIPSLOT as Dictionary<String, ItemSlot> = {
		"Head" => HEAD,
		"Chest" => CHEST,
		"Back" => BACK,
		"Legs" => LEGS,
		"Feet" => FEET,
		"Left Hand" => LEFT_HAND,
		"Right Hand" => RIGHT_HAND,
		"Accessory" => ACCESSORY,
		"Ammunition" => AMMUNITION,
		"None" => NONE
	};

	public const ATTRIBUTE_WEIGHTS = {
		STRENGTH => {
			:strength => 1.0,
			:constitution => 0.5,
			:dexterity => 0.25,
			:intelligence => 0.1,
			:wisdom => 0.05,
			:charisma => 0.01,
			:luck => 0.1
		},
		CONSTITUTION => {
			:strength => 0.5,
			:constitution => 1.0,
			:dexterity => 0.25,
			:intelligence => 0.1,
			:wisdom => 0.05,
			:charisma => 0.01,
			:luck => 0.1
		},
		DEXTERITY => {
			:strength => 0.25,
			:constitution => 0.5,
			:dexterity => 1.0,
			:intelligence => 0.25,
			:wisdom => 0.1,
			:charisma => 0.05,
			:luck => 0.1
		},
		CHARISMA => {
			:strength => 0.01,
			:constitution => 0.05,
			:dexterity => 0.1,
			:intelligence => 0.25,
			:wisdom => 0.5,
			:charisma => 1.0,
			:luck => 0.25
		},
		INTELLIGENCE => {
			:strength => 0.1,
			:constitution => 0.25,
			:dexterity => 0.5,
			:intelligence => 1.0,
			:wisdom => 0.5,
			:charisma => 0.25,
			:luck => 1.0
		},
		WISDOM => {
			:strength => 0.05,
			:constitution => 0.1,
			:dexterity => 0.25,
			:intelligence => 0.5,
			:wisdom => 1.0,
			:charisma => 0.5,
			:luck => 0.25
		},
	} as Dictionary<AttackType | DefenseType, Dictionary>;
}
