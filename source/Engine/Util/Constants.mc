import Toybox.Lang;

module Constants {

	public const MAX_INT = 65535;



	public const MAX_ATTRIBUTE_POINTS = 500;
	public const MIN_ATTRIBUTE_POINTS = 0;

	public const COORDINATES_NEWGAME = [115, 245, 50, 100] as Array<Number>;
	public const COORDINATES_CONTINUE = [115, 245, 265, 315] as Array<Number>;
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

	public const EQUIPSLOT_TO_STR as Dictionary<ItemSlot, String> = {
		HEAD => "Head",
		CHEST => "Chest",
		BACK => "Back",
		LEGS => "Legs",
		FEET => "Feet",
		LEFT_HAND => "Left Hand",
		RIGHT_HAND => "Right Hand",
		ACCESSORY => "Accessory",
		NONE => "None"
	}
}
