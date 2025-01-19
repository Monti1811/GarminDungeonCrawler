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

	public const ATT_SYMBOL_TO_STR = {
        :strength => "Strength",
        :constitution => "Constitution",
        :dexterity => "Dexterity",
        :intelligence => "Intelligence",
        :wisdom => "Wisdom",
        :charisma => "Charisma",
        :luck => "Luck"
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

	public const EQUIPSLOT_TO_STR as Dictionary<ItemSlot, String> = {
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
	};

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
}
